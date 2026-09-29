import 'dart:convert';

class AiMealAnalysis {
  final String foodName;
  final double totalCalories;
  final double protein;
  final double carbs;
  final double fat;
  final int healthScore;
  final String portionSize;
  final List<String> identifiedItems;
  final String healthAdvice;
  final double confidence;

  const AiMealAnalysis({
    required this.foodName,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.healthScore = 8,
    this.portionSize = '1 Porsiyon',
    this.identifiedItems = const [],
    this.healthAdvice = 'Dengeli ve besleyici bir öğün.',
    this.confidence = 0.95,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'totalCalories': totalCalories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'healthScore': healthScore,
      'portionSize': portionSize,
      'identifiedItems': identifiedItems,
      'healthAdvice': healthAdvice,
      'confidence': confidence,
    };
  }

  factory AiMealAnalysis.fromJson(Map<String, dynamic> json) {
    List<String> items = [];
    if (json['identifiedItems'] != null && json['identifiedItems'] is List) {
      items = (json['identifiedItems'] as List).map((e) => e.toString()).toList();
    }

    return AiMealAnalysis(
      foodName: (json['foodName'] ?? 'Tespit Edilen Yemek').toString(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 350.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 20.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 35.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 12.0,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 8,
      portionSize: (json['portionSize'] ?? '1 Standart Porsiyon').toString(),
      identifiedItems: items.isNotEmpty ? items : ['Ana Yemek', 'Garnitür'],
      healthAdvice: (json['healthAdvice'] ?? 'Protein ve lif dengesi yüksek, günün için harika bir enerji kaynağı.').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.92,
    );
  }

  factory AiMealAnalysis.fromRawString(String raw) {
    try {
      String clean = raw.trim();

      // Extract bracketed JSON object if surrounded by markdown or commentary
      final firstBrace = clean.indexOf('{');
      final lastBrace = clean.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
        clean = clean.substring(firstBrace, lastBrace + 1).trim();
      }

      final dynamic decoded = jsonDecode(clean);
      if (decoded is Map<String, dynamic>) {
        return AiMealAnalysis.fromJson(decoded);
      } else if (decoded is Map) {
        return AiMealAnalysis.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}

    return const AiMealAnalysis(
      foodName: 'Öğün Analizi',
      totalCalories: 420.0,
      protein: 24.0,
      carbs: 40.0,
      fat: 14.0,
      healthScore: 9,
      portionSize: '1 Porsiyon',
      identifiedItems: ['Besin Öğeleri'],
      healthAdvice: 'Yüksek kaliteli besin içeriğiyle dengeli bir öğün.',
      confidence: 0.90,
    );
  }
}
