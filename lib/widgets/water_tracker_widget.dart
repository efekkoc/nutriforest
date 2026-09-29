import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';
import 'glass_card.dart';

class WaterTrackerWidget extends StatelessWidget {
  const WaterTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, calorieProvider, child) {
        final currentMl = calorieProvider.waterMl;
        const targetMl = 2500;
        final ratio = (currentMl / targetMl).clamp(0.0, 1.0);
        final percent = (ratio * 100).toInt();

        return GlassCard(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Color(0xFF38BDF8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günlük Su Takibi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Hedef: 2.500 ml (Adana Can Suyu)',
                            style: TextStyle(
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
                      color: const Color(0xFF0284C7).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF38BDF8).withAlpha(80)),
                    ),
                    child: Text(
                      '%$percent',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Animated Water Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 12,
                  width: double.infinity,
                  color: AppColors.surfaceLight,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Current Amount & Quick Add Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$currentMl',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const Text(
                        ' / 2.500 ml',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _WaterAddButton(
                        label: '+250 ml',
                        icon: '🥛',
                        onTap: () => calorieProvider.addWater(250),
                      ),
                      const SizedBox(width: 8),
                      _WaterAddButton(
                        label: '+500 ml',
                        icon: '💧',
                        onTap: () => calorieProvider.addWater(500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaterAddButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _WaterAddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      scaleFactor: 0.90,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0284C7).withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF38BDF8).withAlpha(60)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF38BDF8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
