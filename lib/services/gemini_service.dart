import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_meal_analysis.dart';

class GeminiService {
  static const String defaultPrompt = '''
Sen dünya standartlarında uzman bir diyetisyen ve yapay zeka besin analisti olarak görev yapıyorsun.
Sana verilen yemek/tabak fotoğrafını dikkatle ve gerçekten analiz et. Görselde ne görüyorsan (örneğin Pizza, Lahmacun, Hamburger, Salata, Çorba, Makarna, vb.) onu doğru tespit et.

Aşağıdaki JSON formatında kesin ve geçerli bir JSON yanıt döndür:
{
  "foodName": "Görseldeki yemeğin Türkçe adı (Örn: Dilim Karışık Pizza, Izgara Köfte, vb.)",
  "totalCalories": 750,
  "protein": 28,
  "carbs": 85,
  "fat": 32,
  "healthScore": 6,
  "portionSize": "Porsiyon veya dilim bilgisi (Örn: 2 Dilim Pizza / 1 Porsiyon)",
  "identifiedItems": ["Pizza Hamuru", "Kaşar / Mozzarella Peyniri", "Sucuk / Sosis", "Domates Sosu"],
  "healthAdvice": "Bu yemekle ilgili kısa, profesyonel ve motive edici Türkçe diyetisyen tavsiyesi.",
  "confidence": 0.95
}

Önemli Kurallar:
- Yanıtın SADECE JSON formatında olmalıdır. Markdown veya ekstra açıklama yazma.
- Sayısal değerler (totalCalories, protein, carbs, fat, healthScore, confidence) sayı (number) formatında olmalı.
- Görseldeki yemeğe göre gerçekçi kalori ve makro (protein, karbonhidrat, yağ) tahmini yap.
- Sağlık skoru (healthScore) 1 ile 10 arasında bir tam sayı olmalı.
- Dil Türkçe olmalıdır.
''';

  /// Analyzes food photo bytes (Uint8List) using Gemini Vision REST API with auto-fallback
  static Future<AiMealAnalysis> analyzeFoodImage({
    required Uint8List imageBytes,
    required String apiKey,
    String? mimeType = 'image/jpeg',
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw Exception(
        'Gemini API anahtarı bulunamadı. Lütfen Ayarlar ekranından Google AI Studio API anahtarınızı girin.',
      );
    }

    final modelsToTry = [
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-pro',
      'gemini-2.5-flash',
    ];

    final base64Image = base64Encode(imageBytes);
    String lastError = '';

    for (final modelName in modelsToTry) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$key',
        );

        final payload = {
          "contents": [
            {
              "parts": [
                {"text": defaultPrompt},
                {
                  "inline_data": {
                    "mime_type": mimeType ?? "image/jpeg",
                    "data": base64Image,
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "response_mime_type": "application/json",
            "temperature": 0.1,
          }
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
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
          debugPrint('Gemini Model $modelName başarısız: $lastError');
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Gemini Model $modelName bağlantı hatası: $e');
      }
    }

    throw Exception('Gemini API Hatası: $lastError');
  }
}
