import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_record.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class ForestGridWidget extends StatelessWidget {
  final List<DayRecord> records;

  const ForestGridWidget({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Henüz orman verisi bulunmuyor.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Forest Grid (5 cols x 6 rows for 30 days)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _ForestDayTile(
              record: record,
              onTap: () => _showDayDetailModal(context, record),
            );
          },
        ),
      ],
    );
  }

  void _showDayDetailModal(BuildContext context, DayRecord record) {
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('yyyy-MM-dd').parse(record.dateString);
    } catch (_) {}

    final dateFormatted = parsedDate != null
        ? DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(parsedDate)
        : record.dateString;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Tree icon & Stage
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: record.treeStage.color.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: record.treeStage.color.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    record.treeStage.icon,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                dateFormatted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                record.treeStage.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: record.treeStage.color,
                ),
              ),
              const SizedBox(height: 20),

              // Macro stats
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam Kalori',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          '${record.totalCalories.toStringAsFixed(0)} / ${record.targetCalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MacroSummaryChip(
                          label: 'Protein',
                          val: '${record.totalProtein.toStringAsFixed(0)}g',
                          color: AppColors.protein,
                        ),
                        _MacroSummaryChip(
                          label: 'Karb',
                          val: '${record.totalCarbs.toStringAsFixed(0)}g',
                          color: AppColors.carbs,
                        ),
                        _MacroSummaryChip(
                          label: 'Yağ',
                          val: '${record.totalFat.toStringAsFixed(0)}g',
                          color: AppColors.fat,
                        ),
                        _MacroSummaryChip(
                          label: 'Öğün',
                          val: '${record.mealsCount} Adet',
                          color: AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ForestDayTile extends StatelessWidget {
  final DayRecord record;
  final VoidCallback onTap;

  const _ForestDayTile({
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? dt;
    try {
      dt = DateFormat('yyyy-MM-dd').parse(record.dateString);
    } catch (_) {}

    final dayText = dt != null ? '${dt.day}' : '';
    final monthText = dt != null ? DateFormat('MMM', 'tr_TR').format(dt) : '';

    final isToday = dt != null &&
        dt.year == DateTime.now().year &&
        dt.month == DateTime.now().month &&
        dt.day == DateTime.now().day;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? AppColors.primary
                : record.treeStage.color.withAlpha(50),
            width: isToday ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: record.treeStage.color.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '$dayText $monthText',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            Text(
              record.treeStage.icon,
              style: const TextStyle(fontSize: 22),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: record.treeStage.color.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                record.totalCalories.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: record.treeStage.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroSummaryChip extends StatelessWidget {
  final String label;
  final String val;
  final Color color;

  const _MacroSummaryChip({
    required this.label,
    required this.val,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
