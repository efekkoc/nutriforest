import 'package:flutter/material.dart';
import '../models/meal_item.dart';
import '../models/day_record.dart';
import '../services/storage_service.dart';

enum IslandBiome {
  emerald('Zümrüt Ada', '🌲', 'Doğal yeşil orman & şelale', Color(0xFF10B981)),
  sakura('Sakura Vadisi', '🌸', 'Japon kiraz çiçekleri & pembe sis', Color(0xFFF472B6)),
  tropical('Tropikal Cennet', '🏝️', 'Palmiyeler, turkuaz sular & altın kumsal', Color(0xFF06B6D4)),
  goldValley('Altın Güneş Tepesi', '☀️', 'Güneş ışığıyla parıldayan altın meşeler', Color(0xFFF59E0B));

  final String displayName;
  final String emoji;
  final String description;
  final Color themeColor;
  const IslandBiome(this.displayName, this.emoji, this.description, this.themeColor);
}

class CalorieProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  DateTime _selectedDate = DateTime.now();
  bool _isAutoToday = true;
  List<MealItem> _meals = [];
  List<DayRecord> _forestRecords = [];
  int _waterMl = 0;
  IslandBiome _currentBiome = IslandBiome.emerald;

  double _targetCalories = 2000.0;
  double _targetProtein = 130.0;
  double _targetCarbs = 220.0;
  double _targetFat = 65.0;

  CalorieProvider() {
    refreshData();
  }

  void _checkDayRollover() {
    if (_isAutoToday) {
      final now = DateTime.now();
      if (_selectedDate.year != now.year ||
          _selectedDate.month != now.month ||
          _selectedDate.day != now.day) {
        _selectedDate = now;
        _loadMeals();
        _loadWater();
        _loadForestRecords();
      }
    }
  }

  DateTime get selectedDate {
    _checkDayRollover();
    return _selectedDate;
  }

  List<MealItem> get meals {
    _checkDayRollover();
    return _meals;
  }

  List<DayRecord> get forestRecords {
    _checkDayRollover();
    return _forestRecords;
  }

  List<DayRecord> get history {
    _checkDayRollover();
    return _forestRecords;
  }

  int get waterMl {
    _checkDayRollover();
    try {
      return _waterMl;
    } catch (_) {
      return 0;
    }
  }

  IslandBiome get currentBiome {
    try {
      return _currentBiome;
    } catch (_) {
      return IslandBiome.emerald;
    }
  }

  double get targetCalories => _targetCalories;
  double get targetProtein => _targetProtein;
  double get targetCarbs => _targetCarbs;
  double get targetFat => _targetFat;

  bool get isToday {
    _checkDayRollover();
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  double get totalCalories => _meals.fold(0.0, (sum, m) => sum + m.calories);
  double get totalProtein => _meals.fold(0.0, (sum, m) => sum + m.protein);
  double get totalCarbs => _meals.fold(0.0, (sum, m) => sum + m.carbs);
  double get totalFat => _meals.fold(0.0, (sum, m) => sum + m.fat);

  double get remainingCalories => (_targetCalories - totalCalories);
  
  double get calorieRatio => _targetCalories > 0
      ? (totalCalories / _targetCalories).clamp(0.0, 2.0)
      : 0.0;

  double get proteinRatio => _targetProtein > 0
      ? (totalProtein / _targetProtein).clamp(0.0, 1.5)
      : 0.0;

  double get carbsRatio => _targetCarbs > 0
      ? (totalCarbs / _targetCarbs).clamp(0.0, 1.5)
      : 0.0;

  double get fatRatio => _targetFat > 0
      ? (totalFat / _targetFat).clamp(0.0, 1.5)
      : 0.0;

  TreeStage get currentTreeStage =>
      DayRecord.calculateTreeStage(totalCalories, _targetCalories);

  // --- WATER TRACKING ---
  double get waterRatio => (_waterMl / 2500.0).clamp(0.0, 1.5);

  Future<void> addWater(int ml) async {
    _waterMl = (_waterMl + ml).clamp(0, 10000);
    await _storage.setWaterMlForDate(_selectedDate, _waterMl);
    notifyListeners();
  }

  Future<void> setWater(int ml) async {
    _waterMl = ml.clamp(0, 10000);
    await _storage.setWaterMlForDate(_selectedDate, _waterMl);
    notifyListeners();
  }

  void setBiome(IslandBiome biome) {
    _currentBiome = biome;
    notifyListeners();
  }

  // --- FOREST STATS ---
  int get currentStreak {
    int streak = 0;
    final reversed = _forestRecords.reversed.toList();
    for (var rec in reversed) {
      if (rec.isSuccessful || rec.treeStage == TreeStage.goldenTree || rec.treeStage == TreeStage.lushTree) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalTreesPlanted {
    return _forestRecords.where((r) =>
        r.treeStage == TreeStage.lushTree ||
        r.treeStage == TreeStage.goldenTree ||
        r.treeStage == TreeStage.sapling).length;
  }

  double get forestHealthPercentage {
    if (_forestRecords.isEmpty) return 100.0;
    int healthy = _forestRecords.where((r) =>
        r.treeStage == TreeStage.lushTree ||
        r.treeStage == TreeStage.goldenTree ||
        r.treeStage == TreeStage.sapling).length;
    return ((healthy / _forestRecords.length) * 100).clamp(0, 100).toDouble();
  }

  void updateTargets({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
  }) {
    _targetCalories = targetCalories;
    _targetProtein = targetProtein;
    _targetCarbs = targetCarbs;
    _targetFat = targetFat;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    final now = DateTime.now();
    _isAutoToday = (date.year == now.year && date.month == now.month && date.day == now.day);
    _selectedDate = date;
    _loadMeals();
    _loadWater();
    _loadForestRecords();
    notifyListeners();
  }

  void goToToday() {
    _isAutoToday = true;
    _selectedDate = DateTime.now();
    _loadMeals();
    _loadWater();
    _loadForestRecords();
    notifyListeners();
  }

  void previousDay() {
    _isAutoToday = false;
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    _loadMeals();
    _loadWater();
    _loadForestRecords();
    notifyListeners();
  }

  void nextDay() {
    final now = DateTime.now();
    final next = _selectedDate.add(const Duration(days: 1));
    _isAutoToday = (next.year == now.year && next.month == now.month && next.day == now.day);
    _selectedDate = next;
    _loadMeals();
    _loadWater();
    _loadForestRecords();
    notifyListeners();
  }

  void refreshData() {
    _checkDayRollover();
    _targetCalories = _storage.getTargetCalories();
    _targetProtein = _storage.getTargetProtein();
    _targetCarbs = _storage.getTargetCarbs();
    _targetFat = _storage.getTargetFat();
    _loadMeals();
    _loadWater();
    _loadForestRecords();
    notifyListeners();
  }

  void _loadMeals() {
    _meals = _storage.getMealsForDate(_selectedDate);
  }

  void _loadWater() {
    _waterMl = _storage.getWaterMlForDate(_selectedDate);
  }

  void _loadForestRecords() {
    _forestRecords = _storage.get30DayForestRecords();
  }

  Future<void> addMeal(MealItem meal) async {
    await _storage.saveMeal(meal);
    _checkDayRollover();
    _loadMeals();
    _loadForestRecords();
    notifyListeners();
  }

  Future<void> updateMeal(MealItem meal) async {
    await _storage.saveMeal(meal);
    _loadMeals();
    _loadForestRecords();
    notifyListeners();
  }

  Future<void> deleteMeal(String mealId) async {
    await _storage.deleteMeal(mealId, _selectedDate);
    _loadMeals();
    _loadForestRecords();
    notifyListeners();
  }
}
