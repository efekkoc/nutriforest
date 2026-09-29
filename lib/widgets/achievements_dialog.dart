import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';
import 'glass_card.dart';

class AchievementsDialog extends StatelessWidget {
  const AchievementsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, calorieProvider, child) {
        final mealsCount = calorieProvider.meals.length;
        final streak = calorieProvider.currentStreak;
        final totalTrees = calorieProvider.totalTreesPlanted;
        final water = calorieProvider.waterMl;

        final badges = [
          _BadgeData(
            title: 'İlk Filiz',
            desc: 'İlk öğününü günlüğe kaydet',
            icon: '🌱',
            isUnlocked: mealsCount > 0,
          ),
          _BadgeData(
            title: '3 Günlük Alev',
            desc: '3 gün ardışık hedefini tuttur',
            icon: '🔥',
            isUnlocked: streak >= 3,
          ),
          _BadgeData(
            title: 'Su Muhafızı',
            desc: 'Günlük 2.500 ml su hedefine ulaş',
            icon: '💧',
            isUnlocked: water >= 2500,
          ),
          _BadgeData(
            title: 'Orman Ustası',
            desc: 'Adanda en az 5 canlı ağaç büyüt',
            icon: '🌳',
            isUnlocked: totalTrees >= 5,
          ),
          _BadgeData(
            title: 'Protein Şampiyonu',
            desc: 'Günlük hedefini %100 karşıla',
            icon: '🥩',
            isUnlocked: calorieProvider.totalProtein >= calorieProvider.targetProtein,
          ),
          _BadgeData(
            title: 'Altın Meşe',
            desc: 'Kusursuz kalori dengesi sağla',
            icon: '🌟',
            isUnlocked: calorieProvider.calorieRatio >= 0.9 && calorieProvider.calorieRatio <= 1.05,
          ),
        ];

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 28,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🏆', style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ada Başarımları & Rozetler',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Her başarım ada ormanını güçlendirir',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Biome Selector Section
                  const Text(
                    'Ada Teması & Biyom Seçici 🏝️',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: IslandBiome.values.map((biome) {
                      final isSel = calorieProvider.currentBiome == biome;
                      return Expanded(
                        child: BouncyButton(
                          scaleFactor: 0.88,
                          onTap: () => calorieProvider.setBiome(biome),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSel ? biome.themeColor.withAlpha(40) : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel ? biome.themeColor : AppColors.glassBorder,
                                width: isSel ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(biome.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                  biome.displayName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel ? biome.themeColor : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Badges Grid
                  const Text(
                    'Kazanılan Rozetler',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final b = badges[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: b.isUnlocked
                              ? AppColors.primary.withAlpha(20)
                              : AppColors.surfaceLight.withAlpha(50),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: b.isUnlocked
                                ? AppColors.primary.withAlpha(80)
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              b.icon,
                              style: TextStyle(
                                fontSize: 24,
                                color: b.isUnlocked ? null : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    b.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: b.isUnlocked
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.desc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BadgeData {
  final String title;
  final String desc;
  final String icon;
  final bool isUnlocked;

  const _BadgeData({
    required this.title,
    required this.desc,
    required this.icon,
    required this.isUnlocked,
  });
}
