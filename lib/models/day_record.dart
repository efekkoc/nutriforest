import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TreeStage {
  seed('Tohum & Filiz', '🌱', 'Güne yeni başlıyorsun. Tohum uyanıyor.', AppColors.primaryLight),
  sapling('Genç Fidan', '🌿', 'Enerjin yükseliyor, fidan boy atıyor.', AppColors.primary),
  lushTree('Görkemli Ağaç', '🌳', 'Harika denge! Ormanın yeşerdi ve çiçek açtı.', AppColors.primary),
  goldenTree('Altın Meşe', '🌟', 'Kusursuz kalori ve makro dengesi!', AppColors.gold),
  warning('Aşırı Yükleme', '🍂', 'Hedefin biraz üzerindesin, yapraklar sarardı.', AppColors.warning),
  withered('Kurumuş Dal', '🥀', 'Kalori sınırı aşıldı! Ada dinlenmeye geçti.', AppColors.withered);

  final String title;
  final String icon;
  final String description;
  final Color color;

  const TreeStage(this.title, this.icon, this.description, this.color);
}

class DayRecord {
  final String dateString; // 'yyyy-MM-dd'
  final double totalCalories;
  final double targetCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealsCount;
  final TreeStage treeStage;

  const DayRecord({
    required this.dateString,
    required this.totalCalories,
    required this.targetCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealsCount,
    required this.treeStage,
  });

  double get caloriePercentage => targetCalories > 0
      ? ((totalCalories / targetCalories) * 100).clamp(0, 200).toDouble()
      : 0.0;

  bool get isSuccessful =>
      totalCalories >= (targetCalories * 0.75) &&
      totalCalories <= (targetCalories * 1.15);

  static TreeStage calculateTreeStage(double consumed, double target) {
    if (target <= 0) return TreeStage.seed;
    final ratio = consumed / target;

    if (ratio < 0.30) {
      return TreeStage.seed;
    } else if (ratio < 0.75) {
      return TreeStage.sapling;
    } else if (ratio >= 0.75 && ratio <= 1.08) {
      // If right on target
      if (ratio >= 0.92 && ratio <= 1.04) {
        return TreeStage.goldenTree;
      }
      return TreeStage.lushTree;
    } else if (ratio > 1.08 && ratio <= 1.25) {
      return TreeStage.warning;
    } else {
      return TreeStage.withered;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'dateString': dateString,
      'totalCalories': totalCalories,
      'targetCalories': targetCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'mealsCount': mealsCount,
      'treeStage': treeStage.name,
    };
  }

  factory DayRecord.fromMap(Map<dynamic, dynamic> map) {
    final consumed = (map['totalCalories'] as num?)?.toDouble() ?? 0.0;
    final target = (map['targetCalories'] as num?)?.toDouble() ?? 2000.0;
    
    TreeStage stage = DayRecord.calculateTreeStage(consumed, target);
    if (map['treeStage'] != null) {
      try {
        final stageStr = map['treeStage'].toString();
        stage = TreeStage.values.firstWhere(
          (e) => e.name == stageStr,
          orElse: () => DayRecord.calculateTreeStage(consumed, target),
        );
      } catch (_) {
        stage = DayRecord.calculateTreeStage(consumed, target);
      }
    }

    return DayRecord(
      dateString: map['dateString']?.toString() ?? '',
      totalCalories: consumed,
      targetCalories: target,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ?? 0.0,
      mealsCount: (map['mealsCount'] as num?)?.toInt() ?? 0,
      treeStage: stage,
    );
  }
}
