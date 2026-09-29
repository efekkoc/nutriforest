import 'dart:math';
import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class InteractiveTreeWidget extends StatefulWidget {
  final TreeStage stage;
  final IslandBiome biome;
  final double currentCalories;
  final double targetCalories;
  final VoidCallback? onTap;

  const InteractiveTreeWidget({
    super.key,
    required this.stage,
    this.biome = IslandBiome.emerald,
    required this.currentCalories,
    required this.targetCalories,
    this.onTap,
  });

  @override
  State<InteractiveTreeWidget> createState() => _InteractiveTreeWidgetState();
}

class _InteractiveTreeWidgetState extends State<InteractiveTreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.targetCalories > 0
        ? (widget.currentCalories / widget.targetCalories).clamp(0.0, 2.0)
        : 0.0;
    final percentage = (ratio * 100).toInt();
    final activeBiome = widget.biome;

    return GlassCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      hasGlow: widget.stage == TreeStage.lushTree || widget.stage == TreeStage.goldenTree,
      glowColor: widget.stage == TreeStage.goldenTree ? AppColors.gold : activeBiome.themeColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.stage.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.stage.color.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.stage.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.stage.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.stage.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Calorie percentage pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  '%$percentage Hedef',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.stage.color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Custom 3D Living Tree Canvas
          SizedBox(
            height: 190,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _TreeIslandPainter(
                    stage: widget.stage,
                    biome: activeBiome,
                    animationValue: _animController.value,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Tree Motivational Subtitle
          Text(
            widget.stage.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeIslandPainter extends CustomPainter {
  final TreeStage stage;
  final IslandBiome biome;
  final double animationValue;

  _TreeIslandPainter({
    required this.stage,
    required this.biome,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.80;
    final sway = sin(animationValue * 2 * pi) * 3.5;
    final pulse = sin(animationValue * 2 * pi) * 0.08 + 1.0;

    // 1. Distant Mountain Backdrop & Sun
    _drawBackdrop(canvas, centerX, centerY, size);

    // 2. Floating Island Base
    _drawIsland(canvas, centerX, centerY, size);

    // 3. Stage & Biome Specific Botanical Tree
    switch (stage) {
      case TreeStage.seed:
        _drawSeedling(canvas, centerX, centerY, sway, pulse);
        break;
      case TreeStage.sapling:
        _drawSapling(canvas, centerX, centerY, sway, pulse);
        break;
      case TreeStage.lushTree:
        _drawBiomeHeroTree(canvas, centerX, centerY, sway, pulse, isGolden: false);
        break;
      case TreeStage.goldenTree:
        _drawBiomeHeroTree(canvas, centerX, centerY, sway, pulse, isGolden: true);
        break;
      case TreeStage.warning:
        _drawWarningTree(canvas, centerX, centerY, sway, pulse);
        break;
      case TreeStage.withered:
        _drawWitheredTree(canvas, centerX, centerY, sway);
        break;
    }
  }

  void _drawBackdrop(Canvas canvas, double cx, double cy, Size size) {
    switch (biome) {
      case IslandBiome.sakura:
        final fuji = Path()
          ..moveTo(cx - 70, cy - 30)
          ..lineTo(cx - 15, cy - 90)
          ..lineTo(cx + 15, cy - 90)
          ..lineTo(cx + 70, cy - 30)
          ..close();
        canvas.drawPath(fuji, Paint()..color = const Color(0xFF4C1D95).withAlpha(160));
        final snow = Path()..moveTo(cx - 15, cy - 90)..lineTo(cx + 15, cy - 90)..lineTo(cx + 25, cy - 76)..lineTo(cx - 25, cy - 76)..close();
        canvas.drawPath(snow, Paint()..color = Colors.white.withAlpha(210));
        break;
      case IslandBiome.tropical:
        final stack = Path()..moveTo(cx - 85, cy - 30)..lineTo(cx - 70, cy - 75)..lineTo(cx - 55, cy - 30)..close();
        canvas.drawPath(stack, Paint()..color = const Color(0xFF155E75).withAlpha(160));
        break;
      case IslandBiome.goldValley:
        final ridge = Path()..moveTo(cx - 90, cy - 30)..lineTo(cx - 40, cy - 85)..lineTo(cx + 30, cy - 50)..lineTo(cx + 80, cy - 80)..lineTo(cx + 100, cy - 30)..close();
        canvas.drawPath(ridge, Paint()..color = const Color(0xFFB45309).withAlpha(160));
        break;
      case IslandBiome.emerald:
        final peak = Path()..moveTo(cx - 80, cy - 30)..lineTo(cx - 30, cy - 85)..lineTo(cx + 20, cy - 45)..lineTo(cx + 70, cy - 75)..lineTo(cx + 90, cy - 30)..close();
        canvas.drawPath(peak, Paint()..color = const Color(0xFF1E293B).withAlpha(180));
        break;
    }
  }

  void _drawIsland(Canvas canvas, double cx, double cy, Size size) {
    // Glowing Island Aura
    final auraPaint = Paint()
      ..color = biome.themeColor.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 200, height: 48),
      auraPaint,
    );

    // Rock underlayer
    final rockPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
      ).createShader(Rect.fromLTWH(cx - 85, cy, 170, 44));

    final rockPath = Path()
      ..moveTo(cx - 85, cy)
      ..quadraticBezierTo(cx, cy + 42, cx + 85, cy)
      ..close();
    canvas.drawPath(rockPath, rockPaint);

    // Top Grass Disc based on Biome
    List<Color> grassColors;
    switch (biome) {
      case IslandBiome.sakura:
        grassColors = [const Color(0xFF15803D), const Color(0xFF3B1D4B)];
        break;
      case IslandBiome.tropical:
        grassColors = [const Color(0xFF0D9488), const Color(0xFFD97706)];
        break;
      case IslandBiome.goldValley:
        grassColors = [const Color(0xFFB45309), const Color(0xFF78350F)];
        break;
      case IslandBiome.emerald:
        grassColors = [const Color(0xFF15803D), const Color(0xFF064E3B)];
        break;
    }

    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: grassColors,
      ).createShader(Rect.fromLTWH(cx - 90, cy - 16, 180, 32));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 175, height: 30),
      grassPaint,
    );

    // Sand Rim for Tropical
    if (biome == IslandBiome.tropical) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 173, height: 28),
        Paint()..color = const Color(0xFFFBBF24).withAlpha(140)..style = PaintingStyle.stroke..strokeWidth = 3,
      );
    }

    // Grass border edge
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = biome.themeColor.withAlpha(120);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 175, height: 30),
      borderPaint,
    );
  }

  void _drawBiomeHeroTree(Canvas canvas, double cx, double cy, double sway, double pulse, {required bool isGolden}) {
    switch (biome) {
      case IslandBiome.sakura:
        _drawHeroSakura(canvas, cx, cy, sway, pulse, isGolden);
        break;
      case IslandBiome.tropical:
        _drawHeroPalm(canvas, cx, cy, sway, pulse, isGolden);
        break;
      case IslandBiome.goldValley:
        _drawHeroAutumnOak(canvas, cx, cy, sway, pulse, isGolden);
        break;
      case IslandBiome.emerald:
        _drawHeroEmeraldOak(canvas, cx, cy, sway, pulse, isGolden);
        break;
    }
  }

  // 🌸 HERO SAKURA TREE (Japanese Bonsai)
  void _drawHeroSakura(Canvas canvas, double cx, double cy, double sway, double pulse, bool isGolden) {
    // Curved Bonsai Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 15, cy - 35, cx + 18 + sway * 0.5, cy - 65, cx + sway, cy - 90);
    canvas.drawPath(trunkPath, trunkPaint);

    // Sakura Canopy Clouds
    final pinkDark = isGolden ? AppColors.gold : const Color(0xFFF472B6);
    final pinkMid = isGolden ? const Color(0xFFFEF08A) : const Color(0xFFFBCFE8);
    final pinkLight = isGolden ? Colors.white : const Color(0xFFFDF2F8);

    final p1 = Paint()..color = pinkDark.withAlpha(230);
    final p2 = Paint()..color = pinkMid.withAlpha(240);
    final p3 = Paint()..color = pinkLight.withAlpha(220);

    canvas.drawCircle(Offset(cx + sway - 28, cy - 85), 24 * pulse, p1);
    canvas.drawCircle(Offset(cx + sway + 28, cy - 80), 22 * pulse, p1);
    canvas.drawCircle(Offset(cx + sway, cy - 98), 28 * pulse, p2);
    canvas.drawCircle(Offset(cx + sway - 12, cy - 108), 20 * pulse, p2);
    canvas.drawCircle(Offset(cx + sway + 14, cy - 104), 18 * pulse, p3);

    // Falling Sakura Petals
    final petalPaint = Paint()..color = pinkMid.withAlpha(200);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 35 + sway * 1.2, cy - 40), width: 6, height: 4), petalPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 40 + sway * 0.8, cy - 50), width: 5, height: 3), petalPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 10 + sway * 1.5, cy - 20), width: 6, height: 3), petalPaint);
  }

  // 🏝️ HERO TROPICAL PALM TREE
  void _drawHeroPalm(Canvas canvas, double cx, double cy, double sway, double pulse, bool isGolden) {
    // Sweeping Palm Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + 20, cy - 35, cx + 15 + sway * 0.5, cy - 70, cx + sway, cy - 98);
    canvas.drawPath(trunkPath, trunkPaint);

    final top = Offset(cx + sway, cy - 98);
    final frondPaint = Paint()
      ..color = isGolden ? AppColors.gold : const Color(0xFF10B981)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Radiating Drooping Palm Fronds
    final fronds = [
      Offset(-36, 12),
      Offset(36, 12),
      Offset(-44, -8),
      Offset(44, -8),
      Offset(-26, -26),
      Offset(26, -26),
      Offset(0, -32),
    ];

    for (var f in fronds) {
      final frondPath = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(top.dx + f.dx * 0.5, top.dy + f.dy - 12, top.dx + f.dx, top.dy + f.dy);
      canvas.drawPath(frondPath, frondPaint);
    }

    // Coconut cluster
    final nutPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawCircle(Offset(top.dx - 4, top.dy + 4), 4.5, nutPaint);
    canvas.drawCircle(Offset(top.dx + 4, top.dy + 4), 4.5, nutPaint);
    canvas.drawCircle(Offset(top.dx, top.dy + 8), 4.5, nutPaint);
  }

  // ☀️ HERO AUTUMN OAK / REDWOOD
  void _drawHeroAutumnOak(Canvas canvas, double cx, double cy, double sway, double pulse, bool isGolden) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx, cy), Offset(cx + sway, cy - 90), trunkPaint);

    final o1 = isGolden ? AppColors.gold : const Color(0xFFEA580C);
    final o2 = isGolden ? const Color(0xFFFEF08A) : const Color(0xFFFBBF24);
    final o3 = isGolden ? Colors.white : const Color(0xFFF97316);

    final p1 = Paint()..color = o1.withAlpha(240);
    final p2 = Paint()..color = o2.withAlpha(240);
    final p3 = Paint()..color = o3.withAlpha(220);

    canvas.drawCircle(Offset(cx + sway - 25, cy - 85), 24 * pulse, p1);
    canvas.drawCircle(Offset(cx + sway + 25, cy - 80), 22 * pulse, p1);
    canvas.drawCircle(Offset(cx + sway, cy - 100), 28 * pulse, p2);
    canvas.drawCircle(Offset(cx + sway - 10, cy - 108), 20 * pulse, p3);
    canvas.drawCircle(Offset(cx + sway + 12, cy - 105), 18 * pulse, p3);
  }

  // 🌲 HERO EMERALD BROADLEAF OAK
  void _drawHeroEmeraldOak(Canvas canvas, double cx, double cy, double sway, double pulse, bool isGolden) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx, cy), Offset(cx + sway, cy - 90), trunkPaint);

    final c1 = isGolden ? AppColors.gold : AppColors.primary;
    final c2 = isGolden ? const Color(0xFFFEF08A) : AppColors.primaryLight;
    final c3 = isGolden ? Colors.white : const Color(0xFF6EE7B7);

    final p1 = Paint()..color = c1.withAlpha(240);
    final p2 = Paint()..color = c2.withAlpha(240);
    final p3 = Paint()..color = c3.withAlpha(220);

    canvas.drawCircle(Offset(cx + sway - 25, cy - 85), 24 * pulse, p1);
    canvas.drawCircle(Offset(cx + sway + 25, cy - 80), 22 * pulse, p1);
    canvas.drawCircle(Offset(cx + sway, cy - 100), 28 * pulse, p2);
    canvas.drawCircle(Offset(cx + sway - 10, cy - 108), 20 * pulse, p3);
    canvas.drawCircle(Offset(cx + sway + 12, cy - 105), 18 * pulse, p3);
  }

  void _drawSeedling(Canvas canvas, double cx, double cy, double sway, double pulse) {
    // 1. Soft glowing aura around the new sprout
    final aura = Paint()
      ..color = biome.themeColor.withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(Offset(cx + sway * 0.5, cy - 25), 26 * pulse, aura);

    // 2. Rich dark fertile soil mound
    final soilPaint = Paint()..color = const Color(0xFF271B11);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2), width: 32, height: 10), soilPaint);

    // 3. Curved jade sprout stem
    final stemPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [const Color(0xFF15803D), biome.themeColor],
      ).createShader(Rect.fromLTWH(cx - 10, cy - 42, 20, 44))
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 6, cy - 14, cx + sway * 0.8, cy - 28, cx + sway * 1.2, cy - 42);
    canvas.drawPath(stemPath, stemPaint);

    // 4. Two delicate curving organic leaves
    final leafPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [biome.themeColor, const Color(0xFFBBF7D0)],
      ).createShader(Rect.fromLTWH(cx - 20, cy - 50, 40, 20));

    // Left leaf
    final leftLeaf = Path()
      ..moveTo(cx + sway * 1.2, cy - 38)
      ..quadraticBezierTo(cx + sway * 1.2 - 18, cy - 50, cx + sway * 1.2 - 22, cy - 38)
      ..quadraticBezierTo(cx + sway * 1.2 - 10, cy - 32, cx + sway * 1.2, cy - 38);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right leaf
    final rightLeaf = Path()
      ..moveTo(cx + sway * 1.2, cy - 40)
      ..quadraticBezierTo(cx + sway * 1.2 + 18, cy - 54, cx + sway * 1.2 + 24, cy - 42)
      ..quadraticBezierTo(cx + sway * 1.2 + 10, cy - 34, cx + sway * 1.2, cy - 40);
    canvas.drawPath(rightLeaf, leafPaint);
  }

  void _drawSapling(Canvas canvas, double cx, double cy, double sway, double pulse) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkPath = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx - 4, cy - 30, cx + sway, cy - 65);
    canvas.drawPath(trunkPath, trunkPaint);

    final folPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [biome.themeColor, const Color(0xFF86EFAC)],
      ).createShader(Rect.fromLTWH(cx - 30, cy - 90, 60, 40));

    canvas.drawCircle(Offset(cx + sway, cy - 72), 20 * pulse, folPaint);
    canvas.drawCircle(Offset(cx - 16 + sway, cy - 60), 14 * pulse, folPaint);
    canvas.drawCircle(Offset(cx + 16 + sway, cy - 64), 15 * pulse, folPaint);
  }

  void _drawWarningTree(Canvas canvas, double cx, double cy, double sway, double pulse) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx + sway, cy - 80), trunkPaint);

    final folPaint = Paint()..color = AppColors.warning;
    canvas.drawCircle(Offset(cx + sway, cy - 85), 24 * pulse, folPaint);
  }

  void _drawWitheredTree(Canvas canvas, double cx, double cy, double sway) {
    final dryPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx + sway * 0.4, cy - 70), dryPaint);
    canvas.drawLine(Offset(cx + sway * 0.4, cy - 45), Offset(cx - 24, cy - 65), dryPaint);
    canvas.drawLine(Offset(cx + sway * 0.4, cy - 52), Offset(cx + 26, cy - 72), dryPaint);
  }

  @override
  bool shouldRepaint(covariant _TreeIslandPainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.biome != biome ||
        oldDelegate.animationValue != animationValue;
  }
}
