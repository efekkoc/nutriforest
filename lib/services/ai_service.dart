import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_meal_analysis.dart';

enum AiProviderType {
  gemini('Google Gemini', '⚡ En Hızlı & Ücretsiz'),
  chatgpt('OpenAI ChatGPT', '🧠 GPT-4o Vision');

  final String displayName;
  final String description;
  const AiProviderType(this.displayName, this.description);
}

class AiService {
  // Exhaustive fallback models in priority order
  static const List<String> _fallbackGeminiModels = [
    'gemini-1.5-flash-002',
    'gemini-1.5-flash-001',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-2.0-flash-exp',
    'gemini-2.0-flash',
    'gemini-1.5-pro-002',
    'gemini-1.5-pro-001',
    'gemini-1.5-pro',
  ];

  static String? _cachedModelName;
  static String? _cachedModelApiKey;

  static const String defaultPrompt = '''
Sen dünya standartlarında uzman bir diyetisyen ve yapay zeka besin analisti olarak görev yapıyorsun.
Sana verilen yemek/tabak fotoğrafını veya açıklamasını dikkatle analiz et.
Yemeği (örneğin Izgara Tavuk Göğsü, Pizza, Mercimek Çorbası, Salata, vb.) doğru tespit et.

Aşağıdaki JSON formatında kesin ve geçerli bir JSON yanıt döndür:
{
  "foodName": "Yemeğin Türkçe adı (Örn: 1 Kase Mercimek Çorbası ve 1 Dilim Ekmek)",
  "totalCalories": 280,
  "protein": 14,
  "carbs": 44,
  "fat": 5,
  "healthScore": 9,
  "portionSize": "1 Kase Çorba + 1 Dilim Ekmek",
  "identifiedItems": ["Kırmızı Mercimek Çorbası", "Tam Buğday Ekmeği", "Limon"],
  "healthAdvice": "Yüksek lif ve bitkisel protein içeren, sindirimi kolay ve doyurucu harika bir öğün.",
  "confidence": 0.96
}

Önemli Kurallar:
- Yanıtın SADECE JSON formatında olmalıdır. Markdown veya ekstra açıklama yazma.
- Sayısal değerler (totalCalories, protein, carbs, fat, healthScore, confidence) sayı (number) formatında olmalı.
- Gerçekçi kalori ve makro (protein, karbonhidrat, yağ) tahmini yap.
- Sağlık skoru (healthScore) 1 ile 10 arasında bir tam sayı olmalı.
- Dil Türkçe olmalıdır.
''';

  /// Dynamically discovers and caches the best supported model for the given Gemini API key
  static Future<List<String>> _resolveGeminiModels(String apiKey) async {
    if (_cachedModelApiKey == apiKey && _cachedModelName != null) {
      return [_cachedModelName!, ..._fallbackGeminiModels];
    }

    try {
      final listUrl = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
      );
      final res = await http.get(listUrl).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        final modelsList = data['models'] as List?;
        if (modelsList != null && modelsList.isNotEmpty) {
          final supported = <String>[];
          for (var m in modelsList) {
            final methods = m['supportedGenerationMethods'] as List?;
            if (methods != null && methods.contains('generateContent')) {
              String name = m['name'] ?? '';
              if (name.startsWith('models/')) {
                name = name.substring('models/'.length);
              }
              if (name.isNotEmpty) {
                supported.add(name);
              }
            }
          }

          // Prioritize fastest flash models
          supported.sort((a, b) {
            int score(String s) {
              if (s.contains('2.0-flash')) return 100;
              if (s.contains('1.5-flash-002')) return 90;
              if (s.contains('1.5-flash-001')) return 80;
              if (s.contains('1.5-flash')) return 70;
              if (s.contains('flash')) return 60;
              if (s.contains('1.5-pro')) return 50;
              return 10;
            }
            return score(b).compareTo(score(a));
          });

          if (supported.isNotEmpty) {
            _cachedModelApiKey = apiKey;
            _cachedModelName = supported.first;
            return supported;
          }
        }
      }
    } catch (e) {
      debugPrint('Gemini ListModels error: $e');
    }

    return _fallbackGeminiModels;
  }

  /// Analyzes food image with selected AI Provider (Gemini or ChatGPT)
  static Future<AiMealAnalysis> analyzeFoodImage({
    required Uint8List imageBytes,
    required String apiKey,
    required AiProviderType providerType,
    String? mimeType = 'image/jpeg',
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw Exception(
        '${providerType.displayName} API anahtarı bulunamadı. Lütfen Ayarlar veya açılan pencereden API anahtarınızı girin.',
      );
    }

    if (providerType == AiProviderType.chatgpt) {
      return _analyzeImageWithOpenAi(imageBytes: imageBytes, apiKey: key, mimeType: mimeType);
    } else {
      return _analyzeImageWithGemini(imageBytes: imageBytes, apiKey: key, mimeType: mimeType);
    }
  }

  /// Analyzes food description text (e.g. "1 kase mercimek çorbası ve 1 dilim ekmek")
  static Future<AiMealAnalysis> analyzeFoodText({
    required String textDescription,
    required String apiKey,
    required AiProviderType providerType,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw Exception(
        '${providerType.displayName} API anahtarı bulunamadı. Lütfen Ayarlar veya açılan pencereden API anahtarınızı girin.',
      );
    }

    final prompt = '''
$defaultPrompt

Kullanıcının yediği yemek/menü açıklaması:
"$textDescription"

Bu açıklamaya göre yemeğin tam adını, gerçekçi kalori ve makro değerlerini JSON formatında döndür.
''';

    if (providerType == AiProviderType.chatgpt) {
      return _analyzeTextWithOpenAi(prompt: prompt, apiKey: key);
    } else {
      return _analyzeTextWithGemini(prompt: prompt, apiKey: key);
    }
  }

  // --- BULLETPROOF GEMINI TEXT ANALYSIS ---
  static Future<AiMealAnalysis> _analyzeTextWithGemini({
    required String prompt,
    required String apiKey,
  }) async {
    final models = await _resolveGeminiModels(apiKey);
    String lastError = '';

    for (final rawModel in models) {
      final model = rawModel.startsWith('models/') ? rawModel.substring(7) : rawModel;
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final payload = {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
          }
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          // Success! Save this working model in cache
          _cachedModelApiKey = apiKey;
          _cachedModelName = model;

          final Map<String, dynamic> data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.isNotEmpty) {
                return AiMealAnalysis.fromRawString(text);
              }
            }
          }
        } else {
          lastError = 'HTTP ${response.statusCode}: ${response.body}';
          debugPrint('Gemini Text $model failed: $lastError');
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Gemini Text $model exception: $e');
      }
    }

    throw Exception('Gemini Metin Analiz Hatası: $lastError');
  }

  // --- BULLETPROOF GEMINI IMAGE ANALYSIS ---
  static Future<AiMealAnalysis> _analyzeImageWithGemini({
    required Uint8List imageBytes,
    required String apiKey,
    String? mimeType,
  }) async {
    final models = await _resolveGeminiModels(apiKey);
    final base64Image = base64Encode(imageBytes);
    final mType = (mimeType != null && mimeType.isNotEmpty) ? mimeType : 'image/jpeg';
    String lastError = '';

    for (final rawModel in models) {
      final model = rawModel.startsWith('models/') ? rawModel.substring(7) : rawModel;
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final payload = {
          "contents": [
            {
              "parts": [
                {"text": defaultPrompt},
                {
                  "inlineData": {
                    "mimeType": mType,
                    "data": base64Image,
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
          }
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          // Success! Save working model in cache
          _cachedModelApiKey = apiKey;
          _cachedModelName = model;

          final Map<String, dynamic> data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.isNotEmpty) {
                return AiMealAnalysis.fromRawString(text);
              }
            }
          }
        } else {
          lastError = 'HTTP ${response.statusCode}: ${response.body}';
          debugPrint('Gemini Image $model failed: $lastError');
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Gemini Image $model exception: $e');
      }
    }

    throw Exception('Gemini Görsel Analiz Hatası: $lastError');
  }

  // --- OPENAI TEXT ANALYSIS ---
  static Future<AiMealAnalysis> _analyzeTextWithOpenAi({
    required String prompt,
    required String apiKey,
  }) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final payload = {
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "response_format": {"type": "json_object"},
      "temperature": 0.1,
    };

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      if (content != null && content.isNotEmpty) {
        return AiMealAnalysis.fromRawString(content);
      }
    }
    throw Exception('OpenAI Metin Analiz Hatası: HTTP ${res.statusCode} ${res.body}');
  }

  // --- OPENAI IMAGE ANALYSIS ---
  static Future<AiMealAnalysis> _analyzeImageWithOpenAi({
    required Uint8List imageBytes,
    required String apiKey,
    String? mimeType,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final mType = (mimeType != null && mimeType.isNotEmpty) ? mimeType : 'image/jpeg';
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final payload = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": defaultPrompt},
            {
              "type": "image_url",
              "image_url": {
                "url": "data:$mType;base64,$base64Image",
                "detail": "high"
              }
            }
          ]
        }
      ],
      "response_format": {"type": "json_object"},
      "temperature": 0.1,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      if (content != null && content.isNotEmpty) {
        return AiMealAnalysis.fromRawString(content);
      }
    }

    throw Exception('OpenAI Görsel Analiz Hatası: HTTP ${response.statusCode} ${response.body}');
  }
}
