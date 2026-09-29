import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/day_record.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class HistoryAnalyticsDialog extends StatelessWidget {
  const HistoryAnalyticsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 720),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(160),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withAlpha(70)),
                    ),
                    child: const Icon(Icons.insights_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Geçmiş ve İstatistikler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Beslenme geçmişin ve kalori trendin',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.glassBorder, height: 1),

            // Body
            Expanded(
              child: Consumer<CalorieProvider>(
                builder: (context, provider, child) {
                  final history = provider.history;
                  final activeRecords = history.where((r) => r.totalCalories > 0 || r.mealsCount > 0).toList();

                  // Summary calculations
                  double totalCalories = 0;
                  double totalProtein = 0;
                  double totalCarbs = 0;
                  double totalFat = 0;
                  int completedDays = 0;

                  for (var r in activeRecords) {
                    totalCalories += r.totalCalories;
                    totalProtein += r.totalProtein;
                    totalCarbs += r.totalCarbs;
                    totalFat += r.totalFat;
                    if (r.treeStage == TreeStage.lushTree || r.treeStage == TreeStage.goldenTree) {
                      completedDays++;
                    }
                  }

                  final daysCount = activeRecords.isEmpty ? 1 : activeRecords.length;
                  final avgCalories = (totalCalories / daysCount).round();
                  final avgProtein = (totalProtein / daysCount).round();
                  final avgCarbs = (totalCarbs / daysCount).round();
                  final avgFat = (totalFat / daysCount).round();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // 1. KPI Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Günlük Ort. Kalori',
                              value: '$avgCalories',
                              unit: 'kcal',
                              icon: Icons.local_fire_department_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Başarılı Günler',
                              value: '$completedDays / ${activeRecords.length}',
                              unit: 'gün',
                              icon: Icons.park_rounded,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Ort. Protein',
                              value: '$avgProtein',
                              unit: 'g',
                              icon: Icons.fitness_center_rounded,
                              color: AppColors.protein,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Ort. Karb',
                              value: '$avgCarbs',
                              unit: 'g',
                              icon: Icons.grain_rounded,
                              color: AppColors.carbs,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Ort. Yağ',
                              value: '$avgFat',
                              unit: 'g',
                              icon: Icons.water_drop_rounded,
                              color: AppColors.fat,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 2. 7-Day Trend Chart
                      const Text(
                        'Son 7 Günlük Kalori Trendi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _build7DayChart(history, provider.targetCalories),

                      const SizedBox(height: 24),

                      // 3. Day by Day Archive
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Geçmiş Günlük Kayıtlar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${activeRecords.length} gün kaydedildi',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (activeRecords.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 32, color: AppColors.textMuted),
                              SizedBox(height: 10),
                              Text(
                                'Henüz geçmiş veri bulunmuyor',
                                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Öğünlerini kaydettikçe günlük dökümlerin burada arşivlenecek.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        )
                      else
                        ...activeRecords.reversed.map((record) {
                          return _buildDayRecordTile(context, record);
                        }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build7DayChart(List<DayRecord> history, double targetCalories) {
    final recent7 = history.length > 7 ? history.sublist(history.length - 7) : history;
    final maxCal = (targetCalories * 1.3).clamp(2000.0, 4000.0);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      borderRadius: 20,
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recent7.map((day) {
                final ratio = (day.totalCalories / maxCal).clamp(0.05, 1.0);
                final isTargetMet = day.totalCalories >= (targetCalories * 0.85) && day.totalCalories <= (targetCalories * 1.15);
                final isOver = day.totalCalories > (targetCalories * 1.15);

                Color barColor = AppColors.surfaceElevated;
                if (day.totalCalories > 0) {
                  if (isTargetMet) {
                    barColor = AppColors.primary;
                  } else if (isOver) {
                    barColor = AppColors.warning;
                  } else {
                    barColor = AppColors.gold;
                  }
                }

                DateTime? date;
                try {
                  date = DateFormat('yyyy-MM-dd').parse(day.dateString);
                } catch (_) {}

                final dayLabel = date != null ? DateFormat('E', 'tr_TR').format(date) : day.dateString.substring(8);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day.totalCalories > 0)
                          Text(
                            '${day.totalCalories.round()}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: barColor,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: (80 * ratio).toDouble(),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: day.totalCalories > 0
                                ? [
                                    BoxShadow(
                                      color: barColor.withAlpha(60),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLabel,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.primary, 'Hedefe Uygun'),
              const SizedBox(width: 12),
              _buildLegend(AppColors.gold, 'Hedef Altı'),
              const SizedBox(width: 12),
              _buildLegend(AppColors.warning, 'Hedef Üstü'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildDayRecordTile(BuildContext context, DayRecord record) {
    DateTime? date;
    try {
      date = DateFormat('yyyy-MM-dd').parse(record.dateString);
    } catch (_) {}

    final formattedDate = date != null ? DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date) : record.dateString;
    final percent = (record.totalCalories / record.targetCalories * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 16,
        child: Row(
          children: [
            // Tree badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Center(
                child: Text(
                  record.treeStage.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Date and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${record.mealsCount} öğün',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                      Text(
                        'P: ${record.totalProtein.round()}g  K: ${record.totalCarbs.round()}g  Y: ${record.totalFat.round()}g',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Calorie total badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${record.totalCalories.round()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(
                        text: ' kcal',
                        style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '%$percent Hedef',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
