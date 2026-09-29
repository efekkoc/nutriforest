import 'dart:convert';
import 'dart:typed_data';

enum MealType {
  breakfast('Kahvaltı', '🍳'),
  lunch('Öğle Yemeği', '🥗'),
  dinner('Akşam Yemeği', '🍲'),
  snack('Ara Öğün', '🍎');

  final String displayName;
  final String emoji;
  const MealType(this.displayName, this.emoji);

  static MealType fromString(String? value) {
    if (value == null) return MealType.lunch;
    return MealType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => MealType.lunch,
    );
  }
}

class MealItem {
  final String id;
  final String name;
  final double calories;
  final double protein; // in grams
  final double carbs;   // in grams
  final double fat;     // in grams
  final DateTime dateTime;
  final MealType mealType;
  final int healthScore; // 1 - 10
  final String notes;
  final Uint8List? imageBytes;

  const MealItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dateTime,
    this.mealType = MealType.lunch,
    this.healthScore = 8,
    this.notes = '',
    this.imageBytes,
  });

  MealItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? dateTime,
    MealType? mealType,
    int? healthScore,
    String? notes,
    Uint8List? imageBytes,
  }) {
    return MealItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      dateTime: dateTime ?? this.dateTime,
      mealType: mealType ?? this.mealType,
      healthScore: healthScore ?? this.healthScore,
      notes: notes ?? this.notes,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType.name,
      'healthScore': healthScore,
      'notes': notes,
      'imageBytesBase64': imageBytes != null ? base64Encode(imageBytes!) : null,
    };
  }

  factory MealItem.fromMap(Map<dynamic, dynamic> map) {
    Uint8List? bytes;
    if (map['imageBytesBase64'] != null && map['imageBytesBase64'] is String) {
      try {
        bytes = base64Decode(map['imageBytesBase64'] as String);
      } catch (_) {
        bytes = null;
      }
    }

    return MealItem(
      id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      name: (map['name'] ?? 'Yemek').toString(),
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      dateTime: map['dateTime'] != null
          ? DateTime.tryParse(map['dateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      mealType: MealType.fromString(map['mealType']?.toString()),
      healthScore: (map['healthScore'] as num?)?.toInt() ?? 8,
      notes: (map['notes'] ?? '').toString(),
      imageBytes: bytes,
    );
  }
}
