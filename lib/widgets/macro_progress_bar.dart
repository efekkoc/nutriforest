import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class MacroRowWidget extends StatelessWidget {
  final double currentProtein;
  final double targetProtein;
  final double currentCarbs;
  final double targetCarbs;
  final double currentFat;
  final double targetFat;

  const MacroRowWidget({
    super.key,
    required this.currentProtein,
    required this.targetProtein,
    required this.currentCarbs,
    required this.targetCarbs,
    required this.currentFat,
    required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroItemCard(
            label: 'Protein',
            current: currentProtein,
            target: targetProtein,
            unit: 'g',
            color: AppColors.protein,
            glowColor: AppColors.proteinGlow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MacroItemCard(
            label: 'Karbonhidrat',
            current: currentCarbs,
            target: targetCarbs,
            unit: 'g',
            color: AppColors.carbs,
            glowColor: AppColors.carbsGlow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MacroItemCard(
            label: 'Yağ',
            current: currentFat,
            target: targetFat,
            unit: 'g',
            color: AppColors.fat,
            glowColor: AppColors.fatGlow,
          ),
        ),
      ],
    );
  }
}

class _MacroItemCard extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final Color glowColor;

  const _MacroItemCard({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toInt();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '%$percentage',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${current.toStringAsFixed(0)} ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: '/ ${target.toStringAsFixed(0)}$unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar track
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(90),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
