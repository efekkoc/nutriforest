import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/meal_item.dart';
import '../models/day_record.dart';

class StorageService {
  static const String mealsBoxName = 'nutriforest_meals';
  static const String settingsBoxName = 'nutriforest_settings';
  static const String historyBoxName = 'nutriforest_history';

  late Box _mealsBox;
  late Box _settingsBox;
  late Box _historyBox;

  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    _mealsBox = await Hive.openBox(mealsBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _historyBox = await Hive.openBox(historyBoxName);

    // Clear any previous seeded demo data
    if (_settingsBox.containsKey('is_seeded')) {
      await _mealsBox.clear();
      await _historyBox.clear();
      await _settingsBox.delete('is_seeded');
    }

    // If first launch, initialize clean settings
    if (!_settingsBox.containsKey('is_initialized')) {
      await _initializeCleanSettings();
    }
  }

  // --- SETTINGS ---
  String getApiKey() {
    final val = _settingsBox.get('gemini_api_key', defaultValue: '');
    return val != null ? val.toString() : '';
  }
  Future<void> setApiKey(String key) => _settingsBox.put('gemini_api_key', key);

  String getOpenAiApiKey() {
    final val = _settingsBox.get('openai_api_key', defaultValue: '');
    return val != null ? val.toString() : '';
  }
  Future<void> setOpenAiApiKey(String key) => _settingsBox.put('openai_api_key', key);

  String getAiProvider() {
    final val = _settingsBox.get('ai_provider', defaultValue: 'gemini');
    return val != null ? val.toString() : 'gemini';
  }
  Future<void> setAiProvider(String provider) => _settingsBox.put('ai_provider', provider);

  double getTargetCalories() => (_settingsBox.get('target_calories', defaultValue: 2000.0) as num).toDouble();
  Future<void> setTargetCalories(double val) => _settingsBox.put('target_calories', val);

  double getTargetProtein() => (_settingsBox.get('target_protein', defaultValue: 130.0) as num).toDouble();
  Future<void> setTargetProtein(double val) => _settingsBox.put('target_protein', val);

  double getTargetCarbs() => (_settingsBox.get('target_carbs', defaultValue: 220.0) as num).toDouble();
  Future<void> setTargetCarbs(double val) => _settingsBox.put('target_carbs', val);

  double getTargetFat() => (_settingsBox.get('target_fat', defaultValue: 65.0) as num).toDouble();
  Future<void> setTargetFat(double val) => _settingsBox.put('target_fat', val);

  // --- MEALS ---
  List<MealItem> getMealsForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final List<MealItem> list = [];

    for (var key in _mealsBox.keys) {
      final data = _mealsBox.get(key);
      if (data is Map) {
        final meal = MealItem.fromMap(data);
        final mealDateStr = DateFormat('yyyy-MM-dd').format(meal.dateTime);
        if (mealDateStr == dateStr) {
          list.add(meal);
        }
      }
    }

    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  Future<void> saveMeal(MealItem meal) async {
    await _mealsBox.put(meal.id, meal.toMap());
    await _updateDayArchive(meal.dateTime);
  }

  Future<void> deleteMeal(String mealId, DateTime mealDate) async {
    await _mealsBox.delete(mealId);
    await _updateDayArchive(mealDate);
  }

  // --- 30-DAY FOREST HISTORY ---
  List<DayRecord> get30DayForestRecords() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DayRecord> records = [];

    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      final dayMeals = getMealsForDate(day);
      final target = getTargetCalories();

      if (dayMeals.isNotEmpty) {
        double cal = dayMeals.fold(0, (sum, m) => sum + m.calories);
        double p = dayMeals.fold(0, (sum, m) => sum + m.protein);
        double c = dayMeals.fold(0, (sum, m) => sum + m.carbs);
        double f = dayMeals.fold(0, (sum, m) => sum + m.fat);
        records.add(DayRecord(
          dateString: dayKey,
          totalCalories: cal,
          targetCalories: target,
          totalProtein: p,
          totalCarbs: c,
          totalFat: f,
          mealsCount: dayMeals.length,
          treeStage: DayRecord.calculateTreeStage(cal, target),
        ));
      } else if (_historyBox.containsKey(dayKey)) {
        final data = _historyBox.get(dayKey);
        if (data is Map) {
          records.add(DayRecord.fromMap(data));
        } else {
          records.add(DayRecord(
            dateString: dayKey,
            totalCalories: 0,
            targetCalories: target,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            mealsCount: 0,
            treeStage: TreeStage.seed,
          ));
        }
      } else {
        // Clean empty day state (Seed stage)
        records.add(DayRecord(
          dateString: dayKey,
          totalCalories: 0,
          targetCalories: target,
          totalProtein: 0,
          totalCarbs: 0,
          totalFat: 0,
          mealsCount: 0,
          treeStage: TreeStage.seed,
        ));
      }
    }

    return records;
  }

  Future<void> _updateDayArchive(DateTime date) async {
    final dayKey = DateFormat('yyyy-MM-dd').format(date);
    final meals = getMealsForDate(date);
    final target = getTargetCalories();

    double cal = meals.fold(0, (sum, m) => sum + m.calories);
    double p = meals.fold(0, (sum, m) => sum + m.protein);
    double c = meals.fold(0, (sum, m) => sum + m.carbs);
    double f = meals.fold(0, (sum, m) => sum + m.fat);

    final record = DayRecord(
      dateString: dayKey,
      totalCalories: cal,
      targetCalories: target,
      totalProtein: p,
      totalCarbs: c,
      totalFat: f,
      mealsCount: meals.length,
      treeStage: DayRecord.calculateTreeStage(cal, target),
    );

    await _historyBox.put(dayKey, record.toMap());
  }

  // --- WATER TRACKING ---
  int getWaterMlForDate(DateTime date) {
    final dayKey = 'water_${DateFormat('yyyy-MM-dd').format(date)}';
    final val = _settingsBox.get(dayKey, defaultValue: 0);
    return val is num ? val.toInt() : 0;
  }

  Future<void> setWaterMlForDate(DateTime date, int ml) async {
    final dayKey = 'water_${DateFormat('yyyy-MM-dd').format(date)}';
    await _settingsBox.put(dayKey, ml);
  }

  Future<void> _initializeCleanSettings() async {
    await _settingsBox.put('is_initialized', true);
    await _settingsBox.put('target_calories', 2000.0);
    await _settingsBox.put('target_protein', 130.0);
    await _settingsBox.put('target_carbs', 220.0);
    await _settingsBox.put('target_fat', 65.0);
  }

  /// Resets meals and history data while SAFEGUARDING user API keys and custom targets
  Future<void> resetAll() async {
    final savedGeminiKey = getApiKey();
    final savedOpenAiKey = getOpenAiApiKey();
    final savedProvider = getAiProvider();

    await _mealsBox.clear();
    await _historyBox.clear();

    // Clear all water entries
    final keysToRemove = _settingsBox.keys.where((k) => k.toString().startsWith('water_')).toList();
    for (var k in keysToRemove) {
      await _settingsBox.delete(k);
    }

    // Keep API keys completely safe while restoring default healthy macro goals
    await setApiKey(savedGeminiKey);
    await setOpenAiApiKey(savedOpenAiKey);
    await setAiProvider(savedProvider);
    await setTargetCalories(2000.0);
    await setTargetProtein(130.0);
    await setTargetCarbs(220.0);
    await setTargetFat(65.0);
  }
}
