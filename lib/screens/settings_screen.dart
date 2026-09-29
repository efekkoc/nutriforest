import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ayarlar & Hedefler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer2<SettingsProvider, CalorieProvider>(
        builder: (context, settings, calorie, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gemini Vision API Card
                GlassCard(
                  hasGlow: settings.hasApiKey,
                  glowColor: AppColors.primary,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.aiProvider.displayName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    settings.aiProvider.description,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: settings.hasApiKey
                                  ? AppColors.primary.withAlpha(25)
                                  : AppColors.warning.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: settings.hasApiKey
                                    ? AppColors.primary.withAlpha(80)
                                    : AppColors.warning.withAlpha(80),
                              ),
                            ),
                            child: Text(
                              settings.hasApiKey ? 'Aktif ⚡' : 'Anahtar Bekleniyor 🔑',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: settings.hasApiKey
                                    ? AppColors.primary
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        settings.hasApiKey
                            ? '${settings.aiProvider.displayName} API anahtarınız tanımlandı. Yemek fotoğrafları anlık analiz ediliyor.'
                            : 'Google Gemini (Ücretsiz) veya OpenAI ChatGPT (GPT-4o) API anahtarınızı tanımlayarak yapay zeka ile yemek analizini aktifleştirebilirsiniz.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      BouncyButton(
                        scaleFactor: 0.94,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ApiKeyDialog(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                settings.hasApiKey ? Icons.edit : Icons.key,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                settings.hasApiKey ? 'API Anahtarını Değiştir' : 'API Anahtarı Tanımla',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Daily Calorie Target Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Günlük Kalori Hedefi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${settings.targetCalories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: settings.targetCalories,
                        min: 1200,
                        max: 4000,
                        divisions: 56, // 50 kcal steps
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.surfaceLight,
                        onChanged: (val) {
                          settings.setTargetCalories(val);
                          calorie.updateTargets(
                            targetCalories: val,
                            targetProtein: settings.targetProtein,
                            targetCarbs: settings.targetCarbs,
                            targetFat: settings.targetFat,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Macro Targets Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Günlük Makro Hedefleri (Gram)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Protein Slider
                      _buildMacroSlider(
                        label: 'Protein',
                        val: settings.targetProtein,
                        color: AppColors.protein,
                        min: 40,
                        max: 250,
                        onChanged: (val) {
                          settings.setMacros(
                            protein: val,
                            carbs: settings.targetCarbs,
                            fat: settings.targetFat,
                          );
                          calorie.updateTargets(
                            targetCalories: settings.targetCalories,
                            targetProtein: val,
                            targetCarbs: settings.targetCarbs,
                            targetFat: settings.targetFat,
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Carbs Slider
                      _buildMacroSlider(
                        label: 'Karbonhidrat',
                        val: settings.targetCarbs,
                        color: AppColors.carbs,
                        min: 50,
                        max: 400,
                        onChanged: (val) {
                          settings.setMacros(
                            protein: settings.targetProtein,
                            carbs: val,
                            fat: settings.targetFat,
                          );
                          calorie.updateTargets(
                            targetCalories: settings.targetCalories,
                            targetProtein: settings.targetProtein,
                            targetCarbs: val,
                            targetFat: settings.targetFat,
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Fat Slider
                      _buildMacroSlider(
                        label: 'Yağ',
                        val: settings.targetFat,
                        color: AppColors.fat,
                        min: 20,
                        max: 150,
                        onChanged: (val) {
                          settings.setMacros(
                            protein: settings.targetProtein,
                            carbs: settings.targetCarbs,
                            fat: val,
                          );
                          calorie.updateTargets(
                            targetCalories: settings.targetCalories,
                            targetProtein: settings.targetProtein,
                            targetCarbs: settings.targetCarbs,
                            targetFat: val,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Data Reset / Seed Actions
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Veritabanı & Sıfırlama',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Yerel Hive veritabanındaki 30 günlük ada kayıtlarını ve öğünleri fabrika ayarlarına sıfırlayabilirsiniz.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      BouncyButton(
                        scaleFactor: 0.94,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: AppColors.glassBorder),
                              ),
                              title: const Text('Veriler Sıfırlansın mı?'),
                              content: const Text(
                                'Tüm öğün geçmişiniz ve ada ormanı örnek başlangıç verilerine sıfırlanacaktır.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Sıfırla'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await settings.resetAllData();
                            calorie.refreshData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veritabanı ve ada ormanı başarıyla sıfırlandı.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.danger.withAlpha(80)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 16, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text(
                                'Örnek Verileri Sıfırla ve Yenile',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // App version & Architecture info
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'NutriForest v1.0.0 (Apple Glassmorphism)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Flutter & Gemini Vision AI • iOS HIG Standartları',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroSlider({
    required String label,
    required double val,
    required Color color,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            Text(
              '${val.toStringAsFixed(0)}g',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: val.clamp(min, max),
          min: min,
          max: max,
          activeColor: color,
          inactiveColor: AppColors.surfaceLight,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
