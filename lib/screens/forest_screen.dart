import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/day_record.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/achievements_dialog.dart';
import '../widgets/forest_grid_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/living_forest_island_widget.dart';

class ForestScreen extends StatelessWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '30 Günlük Ada Ormanı',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
            tooltip: 'Başarımlar & Temalar',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AchievementsDialog(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CalorieProvider>(
        builder: (context, calorieProvider, child) {
          final records = calorieProvider.forestRecords;
          final streak = calorieProvider.currentStreak;
          final totalTrees = calorieProvider.totalTreesPlanted;
          final healthScore = calorieProvider.forestHealthPercentage;
          final goldenTrees = records.where((r) => r.treeStage == TreeStage.goldenTree).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3D Living Forest Island (Accumulated Community Trees)
                LivingForestIslandWidget(
                  records: records,
                  biome: calorieProvider.currentBiome,
                  onIslandTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AchievementsDialog(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Island Level & Health Overview Card
                GlassCard(
                  hasGlow: true,
                  glowColor: AppColors.primary,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ada Orman Sağlığı',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '%${healthScore.toStringAsFixed(0)} Canlılık',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gold.withAlpha(80)),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  '$streak Günlük Seri',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Health bar
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (healthScore / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryDark, AppColors.primaryLight],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3 Mini stats in row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MiniStat(
                            label: 'Dikilen Ağaç',
                            val: '$totalTrees',
                            icon: '🌳',
                          ),
                          _MiniStat(
                            label: 'Altın Meşe',
                            val: '$goldenTrees',
                            icon: '🌟',
                          ),
                          _MiniStat(
                            label: 'Hedef Süresi',
                            val: '30 Gün',
                            icon: '🗓️',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 30 Days Grid Section
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son 30 Günlük Harita',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Detay için dokun',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ForestGridWidget(records: records),

                const SizedBox(height: 24),

                // Badges & Achievements Section
                const Text(
                  'Orman Başarıları & Rozetler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _AchievementCard(
                  title: 'Yeşil Parmak',
                  desc: 'Gemini Vision ile ilk yemeğini tara ve ada ormanına tohum ek.',
                  icon: '🌱',
                  isUnlocked: true,
                ),
                const SizedBox(height: 8),

                _AchievementCard(
                  title: 'Orman Muhafızı',
                  desc: '7 gün boyunca günlük kalori hedefini %15 sapma sınırında tut.',
                  icon: '🛡️',
                  isUnlocked: streak >= 7,
                  progressText: '$streak / 7 Gün',
                ),
                const SizedBox(height: 8),

                _AchievementCard(
                  title: 'Altın Denge Ustası',
                  desc: 'Protein, Karbonhidrat ve Yağ makrolarını kusursuz oranda tamamla.',
                  icon: '👑',
                  isUnlocked: goldenTrees >= 3,
                  progressText: '$goldenTrees / 3 Kez',
                ),
                const SizedBox(height: 8),

                _AchievementCard(
                  title: 'Efsanevi Ada Ormanı',
                  desc: '30 günlük döngüyü en az %80 canlılık oranıyla tamamla.',
                  icon: '🏝️',
                  isUnlocked: healthScore >= 80 && records.length >= 30,
                  progressText: '%${healthScore.toStringAsFixed(0)} Canlılık',
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String val;
  final String icon;

  const _MiniStat({
    required this.label,
    required this.val,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String desc;
  final String icon;
  final bool isUnlocked;
  final String? progressText;

  const _AchievementCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.isUnlocked,
    this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      backgroundColor: isUnlocked ? null : AppColors.surfaceLight.withAlpha(50),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.primary.withAlpha(30)
                  : AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? AppColors.primary.withAlpha(90)
                    : AppColors.glassBorder,
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 22,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(Icons.check_circle, size: 16, color: AppColors.primary)
                    else if (progressText != null)
                      Text(
                        progressText!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
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
