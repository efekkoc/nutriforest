import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal_item.dart';
import '../providers/ai_scan_provider.dart';
import '../providers/calorie_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/achievements_dialog.dart';
import '../widgets/ai_analysis_sheet.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/history_dialog.dart';
import '../widgets/interactive_tree_widget.dart';
import '../widgets/macro_progress_bar.dart';
import '../widgets/text_ai_meal_dialog.dart';
import '../widgets/water_tracker_widget.dart';
import 'add_meal_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer3<CalorieProvider, SettingsProvider, AiScanProvider>(
          builder: (context, calorieProvider, settingsProvider, aiScanProvider, child) {
            final isAnalyzing = aiScanProvider.isAnalyzing;

            return Stack(
              children: [
                // Main Scrollable Content
                RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    calorieProvider.refreshData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header: Date Navigator & Streak
                        _buildHeader(context, calorieProvider),
                        const SizedBox(height: 16),

                        // Gamified Central Island & Tree Widget
                        InteractiveTreeWidget(
                          stage: calorieProvider.currentTreeStage,
                          biome: calorieProvider.currentBiome,
                          currentCalories: calorieProvider.totalCalories,
                          targetCalories: calorieProvider.targetCalories,
                          onTap: () {
                            _showTreeInfoDialog(context, calorieProvider);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Calorie Quick Stats (Consumed, Target, Remaining)
                        _buildCalorieStatRow(calorieProvider),
                        const SizedBox(height: 16),

                        // Macro Breakdown (Protein, Carbs, Fat)
                        MacroRowWidget(
                          currentProtein: calorieProvider.totalProtein,
                          targetProtein: calorieProvider.targetProtein,
                          currentCarbs: calorieProvider.totalCarbs,
                          targetCarbs: calorieProvider.targetCarbs,
                          currentFat: calorieProvider.totalFat,
                          targetFat: calorieProvider.targetFat,
                        ),
                        const SizedBox(height: 16),

                        // Smart Hydration Tracker (Water Glass & Can Suyu)
                        const WaterTrackerWidget(),
                        const SizedBox(height: 20),

                        // Meals Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Günün Öğünleri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${calorieProvider.meals.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddMealScreen()),
                                );
                              },
                              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                              label: const Text(
                                'Manuel Ekle',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Meals List
                        if (calorieProvider.meals.isEmpty)
                          _buildEmptyMealPrompt(context, settingsProvider, aiScanProvider)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: calorieProvider.meals.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final meal = calorieProvider.meals[index];
                              return _buildMealCard(context, meal, calorieProvider);
                            },
                          ),

                        const SizedBox(height: 100), // Space for floating button
                      ],
                    ),
                  ),
                ),

                // Floating AI Camera Scan Trigger
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildAiScanButton(context, settingsProvider, aiScanProvider),
                ),

                // Fullscreen Analyzing Shimmer Overlay
                if (isAnalyzing)
                  _buildAnalyzingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CalorieProvider calorie) {
    final now = DateTime.now();
    final isToday = calorie.isToday;
    final dateStr = isToday
        ? 'Bugün, ${DateFormat('d MMMM', 'tr_TR').format(calorie.selectedDate)}'
        : DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(calorie.selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date Selector Pill
        BouncyButton(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: calorie.selectedDate,
              firstDate: now.subtract(const Duration(days: 90)),
              lastDate: now.add(const Duration(days: 7)),
              builder: (ctx, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      surface: AppColors.surface,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              calorie.selectDate(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),

        // Actions: History & Analytics, Streak, Trophy & Settings
        Row(
          children: [
            // History & Analytics Button
            BouncyButton(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const HistoryAnalyticsDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.insights_rounded, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Geçmiş',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Streak Badge
            BouncyButton(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withAlpha(70)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${calorie.currentStreak}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Achievements Trophy
            BouncyButton(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AchievementsDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 4),

            // Settings Button
            BouncyButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Icon(Icons.tune, color: AppColors.textPrimary, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieStatRow(CalorieProvider calorie) {
    final remaining = calorie.remainingCalories;
    final isExceeded = remaining < 0;

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            title: 'Alınan Kalori',
            value: calorie.totalCalories.toStringAsFixed(0),
            unit: 'kcal',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            title: isExceeded ? 'Aşılan Kalori' : 'Kalan Kalori',
            value: isExceeded ? '+${(-remaining).toStringAsFixed(0)}' : remaining.toStringAsFixed(0),
            unit: 'kcal',
            color: isExceeded ? AppColors.danger : AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            title: 'Günlük Hedef',
            value: calorie.targetCalories.toStringAsFixed(0),
            unit: 'kcal',
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, MealItem meal, CalorieProvider provider) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sil',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
            ),
            SizedBox(width: 6),
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (_) {
        provider.deleteMeal(meal.id);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 2500),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.glassBorder),
            ),
            content: Row(
              children: [
                const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${meal.name} silindi.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'Geri Al',
              textColor: AppColors.primary,
              onPressed: () => provider.addMeal(meal),
            ),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 20,
        child: Row(
          children: [
            // Meal Image Thumbnail or Emoji
            if (meal.imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  meal.imageBytes!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getMealGradientColors(meal.mealType),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getMealAccentColor(meal.mealType).withAlpha(90),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getMealVectorIcon(meal.mealType),
                    color: _getMealAccentColor(meal.mealType),
                    size: 24,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // Meal Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${meal.calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Macros mini text
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(meal.dateTime),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Protein: ${meal.protein.toStringAsFixed(0)}g',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.protein,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Karb: ${meal.carbs.toStringAsFixed(0)}g',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.carbs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Yağ: ${meal.fat.toStringAsFixed(0)}g',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.fat,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealPrompt(
    BuildContext context,
    SettingsProvider settings,
    AiScanProvider aiScan,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      borderRadius: 22,
      child: Column(
        children: [
          const Text('🥗', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Henüz Öğün Eklenmedi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tabağının fotoğrafını çekerek yapay zeka ile otomatik kalori ve makro analizi yapabilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openImagePickerModal(context, settings, aiScan),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Fotoğraf Çek ve Analiz Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealVectorIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_rounded;
      case MealType.lunch:
        return Icons.restaurant_rounded;
      case MealType.dinner:
        return Icons.nights_stay_rounded;
      case MealType.snack:
        return Icons.local_cafe_rounded;
    }
  }

  Color _getMealAccentColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return const Color(0xFFFBBF24);
      case MealType.lunch:
        return AppColors.primary;
      case MealType.dinner:
        return const Color(0xFF818CF8);
      case MealType.snack:
        return const Color(0xFFF43F5E);
    }
  }

  List<Color> _getMealGradientColors(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return [const Color(0xFF78350F).withAlpha(80), const Color(0xFFD97706).withAlpha(40)];
      case MealType.lunch:
        return [const Color(0xFF064E3B).withAlpha(80), const Color(0xFF059669).withAlpha(40)];
      case MealType.dinner:
        return [const Color(0xFF312E81).withAlpha(80), const Color(0xFF4F46E5).withAlpha(40)];
      case MealType.snack:
        return [const Color(0xFF881337).withAlpha(80), const Color(0xFFE11D48).withAlpha(40)];
    }
  }

  Widget _buildAiScanButton(
    BuildContext context,
    SettingsProvider settings,
    AiScanProvider aiScan,
  ) {
    return Row(
      children: [
        // Main Photo AI Scan Button
        Expanded(
          flex: 3,
          child: BouncyButton(
            scaleFactor: 0.94,
            onTap: () => _openImagePickerModal(context, settings, aiScan),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(120),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 20, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Fotoğrafla Tara',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Text AI Meal Logger Button
        BouncyButton(
          scaleFactor: 0.90,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const TextAiMealDialog(),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary.withAlpha(120), width: 1.5),
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
          ),
        ),
      ],
    );
  }

  static void openScanModal(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final aiScan = Provider.of<AiScanProvider>(context, listen: false);
    _openImagePickerModalStatic(context, settings, aiScan);
  }

  static void openTextModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const TextAiMealDialog(),
    );
  }

  static void _openImagePickerModalStatic(
    BuildContext context,
    SettingsProvider settings,
    AiScanProvider aiScan,
  ) {
    if (!settings.hasApiKey) {
      showDialog(
        context: context,
        builder: (ctx) => const ApiKeyDialog(),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Yemek Görselini Yükle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gemini Vision tabağınızdaki yiyecekleri tespit edip besin değerlerini hesaplar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ScanOptionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Kamera',
                      onTap: () async {
                        Navigator.pop(ctx);
                        final success = await aiScan.pickAndAnalyzeImage(
                          source: ImageSource.camera,
                          apiKey: settings.apiKey,
                          providerType: settings.aiProvider,
                        );
                        if (context.mounted) {
                          if (success && aiScan.analysisResult != null) {
                            _openAnalysisSheetStatic(context, aiScan);
                          } else if (aiScan.errorMessage != null) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(aiScan.errorMessage!),
                                backgroundColor: AppColors.danger,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScanOptionCard(
                      icon: Icons.photo_library_rounded,
                      title: 'Galeri',
                      onTap: () async {
                        Navigator.pop(ctx);
                        final success = await aiScan.pickAndAnalyzeImage(
                          source: ImageSource.gallery,
                          apiKey: settings.apiKey,
                          providerType: settings.aiProvider,
                        );
                        if (context.mounted) {
                          if (success && aiScan.analysisResult != null) {
                            _openAnalysisSheetStatic(context, aiScan);
                          } else if (aiScan.errorMessage != null) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(aiScan.errorMessage!),
                                backgroundColor: AppColors.danger,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static void _openAnalysisSheetStatic(BuildContext context, AiScanProvider aiScan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AiAnalysisSheet(
          analysis: aiScan.analysisResult!,
          imageBytes: aiScan.imageBytes,
          onSaved: () {
            aiScan.clear();
          },
        );
      },
    ).then((_) {
      aiScan.clear();
    });
  }

  void _openImagePickerModal(
    BuildContext context,
    SettingsProvider settings,
    AiScanProvider aiScan,
  ) {
    _openImagePickerModalStatic(context, settings, aiScan);
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black.withAlpha(190),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gemini Vision Analiz Ediyor...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Porsiyon, kalori ve makro değerleri hesaplanıyor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTreeInfoDialog(BuildContext context, CalorieProvider calorie) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.glassBorder),
        ),
        title: Row(
          children: [
            Text(calorie.currentTreeStage.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              calorie.currentTreeStage.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: calorie.currentTreeStage.color,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              calorie.currentTreeStage.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ağaç Evreleri Mantığı:',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text('🌱 Tohum: Gün başı (0 - %30)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Text('🌿 Fidan: Gelişme evresi (%30 - %75)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Text('🌳 Görkemli Ağaç: Dengeli kalori (%75 - %108)', style: TextStyle(fontSize: 12, color: AppColors.primary)),
            const Text('🌟 Altın Meşe: Kusursuz makro ve kalori dengesi', style: TextStyle(fontSize: 12, color: AppColors.gold)),
            const Text('🍂 Aşırı Besleme: Hedef üzeri (%108 - %125)', style: TextStyle(fontSize: 12, color: AppColors.warning)),
            const Text('🥀 Kurumuş Dal: Sınır aşıldı (> %125)', style: TextStyle(fontSize: 12, color: AppColors.withered)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;

  const _StatPill({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ScanOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      scaleFactor: 0.92,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
