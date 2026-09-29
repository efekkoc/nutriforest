import 'dart:math';
import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class LivingForestIslandWidget extends StatefulWidget {
  final List<DayRecord> records;
  final IslandBiome biome;
  final VoidCallback? onIslandTap;

  const LivingForestIslandWidget({
    super.key,
    required this.records,
    this.biome = IslandBiome.emerald,
    this.onIslandTap,
  });

  @override
  State<LivingForestIslandWidget> createState() => _LivingForestIslandWidgetState();
}

class _LivingForestIslandWidgetState extends State<LivingForestIslandWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeBiome = widget.biome;
    final successfulTrees = widget.records.where((r) =>
        r.treeStage == TreeStage.lushTree ||
        r.treeStage == TreeStage.goldenTree ||
        r.treeStage == TreeStage.sapling).length;

    return GlassCard(
      onTap: widget.onIslandTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 30,
      hasGlow: true,
      glowColor: activeBiome.themeColor,
      child: Column(
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: activeBiome.themeColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: activeBiome.themeColor.withAlpha(110)),
                ),
                child: Row(
                  children: [
                    Text(activeBiome.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      '$successfulTrees Ağaç Yaşıyor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: activeBiome.themeColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  activeBiome.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3D Isometric Living Forest Canvas (310px rich volumetric depth)
          SizedBox(
            height: 310,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LivingIslandPainter(
                    records: widget.records,
                    biome: activeBiome,
                    animValue: _animController.value,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle & Tap to Customize Prompt
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, size: 14, color: activeBiome.themeColor.withAlpha(180)),
              const SizedBox(width: 6),
              Text(
                '${activeBiome.description} • Temayı Değiştirmek İçin Dokun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary.withAlpha(220),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LivingIslandPainter extends CustomPainter {
  final List<DayRecord> records;
  final IslandBiome biome;
  final double animValue;

  _LivingIslandPainter({
    required this.records,
    required this.biome,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.65;
    final sway = sin(animValue * 2 * pi) * 3.0;
    final floatOffset = sin(animValue * 2 * pi) * 4.5;

    // 1. Distant Horizon, Mountains & Sun
    _drawBackdropScenery(canvas, cx, cy, size, floatOffset);

    // 2. Cascading Waterfall Spray & Mist (Back layer)
    _drawWaterfallMist(canvas, cx, cy + floatOffset, size);

    // 3. Volumetric 3D Floating Island Body with Stratified Rocks
    _draw3DIsland(canvas, cx, cy + floatOffset, size);

    // 4. Waterfall Cascading over the island edge into the clouds
    _drawCascadingWaterfall(canvas, cx, cy + floatOffset);

    // 5. Environmental Props (Zen Bridge, Palm Coast, Stone Lanterns, etc.)
    _drawBiomeEnvironmentalProps(canvas, cx, cy + floatOffset, sway);

    // 6. Plant Accumulated & Base Botanical Trees
    _drawAccumulatedTrees(canvas, cx, cy + floatOffset, sway);

    // 7. Dynamic Atmosphere (Sakura Petals, Gulls, Fireflies, Sunbeams)
    _drawAtmosphere(canvas, cx, cy + floatOffset, size);
  }

  void _drawBackdropScenery(Canvas canvas, double cx, double cy, Size size, double floatOffset) {
    switch (biome) {
      // 🌸 SAKURA VADİSİ: Mount Fuji & Twilight Sunset
      case IslandBiome.sakura:
        final fujiBasePaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B21A8), Color(0xFF2E1065)],
          ).createShader(Rect.fromLTWH(cx - 100, cy - 170, 200, 110));

        final fujiPath = Path()
          ..moveTo(cx - 95, cy - 60)
          ..lineTo(cx - 20, cy - 145)
          ..lineTo(cx + 20, cy - 145)
          ..lineTo(cx + 95, cy - 60)
          ..close();
        canvas.drawPath(fujiPath, fujiBasePaint);

        // Snow Crest on Mount Fuji
        final snowCapPaint = Paint()..color = const Color(0xFFFAF5FF).withAlpha(240);
        final snowPath = Path()
          ..moveTo(cx - 20, cy - 145)
          ..lineTo(cx + 20, cy - 145)
          ..lineTo(cx + 34, cy - 125)
          ..quadraticBezierTo(cx, cy - 118, cx - 34, cy - 125)
          ..close();
        canvas.drawPath(snowPath, snowCapPaint);

        // Pink Twilight Sun
        final sunPaint = Paint()
          ..color = const Color(0xFFF472B6).withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
        canvas.drawCircle(Offset(cx + 70, cy - 110), 50, sunPaint);
        break;

      // 🏝️ TROPİKAL CENNET: Ocean Horizon, Volcanic Monoliths & Radiant Lagoon Sky
      case IslandBiome.tropical:
        // Ocean horizon glow
        final oceanSkyPaint = Paint()
          ..color = const Color(0xFF0891B2).withAlpha(70)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy - 80), width: size.width * 0.95, height: 50),
          oceanSkyPaint,
        );

        // Distant Volcanic Sea Stacks (Rocky ocean islands)
        final stackPaint = Paint()..color = const Color(0xFF155E75);
        final s1 = Path()
          ..moveTo(cx - 120, cy - 60)
          ..lineTo(cx - 100, cy - 115)
          ..lineTo(cx - 80, cy - 60)
          ..close();
        canvas.drawPath(s1, stackPaint);

        final s2 = Path()
          ..moveTo(cx + 70, cy - 60)
          ..lineTo(cx + 90, cy - 105)
          ..lineTo(cx + 115, cy - 60)
          ..close();
        canvas.drawPath(s2, stackPaint);

        // Tropical Turquoise Sun
        final sunPaint = Paint()
          ..color = const Color(0xFF06B6D4).withAlpha(70)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
        canvas.drawCircle(Offset(cx - 50, cy - 110), 55, sunPaint);
        break;

      // ☀️ ALTIN GÜNEŞ TEPESİ: Golden Alpine Peaks & God Rays
      case IslandBiome.goldValley:
        final mountainPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD97706), Color(0xFF451A03)],
          ).createShader(Rect.fromLTWH(cx - 140, cy - 150, 280, 100));

        final ridgePath = Path()
          ..moveTo(cx - 140, cy - 60)
          ..lineTo(cx - 60, cy - 135)
          ..lineTo(cx + 10, cy - 85)
          ..lineTo(cx + 85, cy - 140)
          ..lineTo(cx + 150, cy - 60)
          ..close();
        canvas.drawPath(ridgePath, mountainPaint);

        // Golden Sunrise Sun
        final sunPaint = Paint()
          ..color = const Color(0xFFFBBF24).withAlpha(80)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
        canvas.drawCircle(Offset(cx, cy - 100), 60, sunPaint);
        break;

      // 🌲 ZÜMRÜT ADA: Jagged Snow-Crested Alps & Emerald Sun
      case IslandBiome.emerald:
        final peakPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF334155), Color(0xFF0F172A)],
          ).createShader(Rect.fromLTWH(cx - 130, cy - 140, 260, 90));

        final peakPath = Path()
          ..moveTo(cx - 135, cy - 60)
          ..lineTo(cx - 50, cy - 130)
          ..lineTo(cx + 25, cy - 75)
          ..lineTo(cx + 95, cy - 125)
          ..lineTo(cx + 140, cy - 60)
          ..close();
        canvas.drawPath(peakPath, peakPaint);

        // Snow Tips
        final snowPaint = Paint()..color = Colors.white.withAlpha(200);
        final tip1 = Path()..moveTo(cx - 50, cy - 130)..lineTo(cx - 38, cy - 110)..lineTo(cx - 62, cy - 110)..close();
        final tip2 = Path()..moveTo(cx + 95, cy - 125)..lineTo(cx + 105, cy - 108)..lineTo(cx + 85, cy - 108)..close();
        canvas.drawPath(tip1, snowPaint);
        canvas.drawPath(tip2, snowPaint);

        final sunPaint = Paint()
          ..color = const Color(0xFF10B981).withAlpha(50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
        canvas.drawCircle(Offset(cx + 65, cy - 105), 50, sunPaint);
        break;
    }
  }

  void _draw3DIsland(Canvas canvas, double cx, double cy, Size size) {
    // 1. Deep Floating Island Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 68), width: size.width * 0.88, height: 46),
      shadowPaint,
    );

    // 2. Stratified 3D Rock Base (Jagged cliff faces & crystal strata)
    final rockPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(cx - 165, cy, 330, 85));

    final rockPath = Path()
      ..moveTo(cx - 155, cy)
      ..cubicTo(cx - 120, cy + 55, cx - 60, cy + 85, cx, cy + 88)
      ..cubicTo(cx + 60, cy + 85, cx + 120, cy + 55, cx + 155, cy)
      ..close();
    canvas.drawPath(rockPath, rockPaint);

    // Rock Strata Cracks & Highlight Facets
    final facetPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 80, cy + 20), Offset(cx - 40, cy + 65), facetPaint);
    canvas.drawLine(Offset(cx + 70, cy + 22), Offset(cx + 30, cy + 68), facetPaint);
    canvas.drawLine(Offset(cx - 15, cy + 25), Offset(cx, cy + 85), facetPaint);

    // 3. Biome Terrain Surface Grass Disk
    List<Color> terrainColors;
    switch (biome) {
      case IslandBiome.sakura:
        terrainColors = [const Color(0xFF15803D), const Color(0xFF166534), const Color(0xFF4C1D95)];
        break;
      case IslandBiome.tropical:
        terrainColors = [const Color(0xFF059669), const Color(0xFF0D9488), const Color(0xFFD97706)];
        break;
      case IslandBiome.goldValley:
        terrainColors = [const Color(0xFFD97706), const Color(0xFFB45309), const Color(0xFF78350F)];
        break;
      case IslandBiome.emerald:
        terrainColors = [const Color(0xFF10B981), const Color(0xFF059669), const Color(0xFF064E3B)];
        break;
    }

    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: terrainColors,
      ).createShader(Rect.fromLTWH(cx - 160, cy - 42, 320, 84));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 310, height: 78),
      grassPaint,
    );

    // 4. Golden Sand Beach Rim (Only on Tropical Biome)
    if (biome == IslandBiome.tropical) {
      final sandPaint = Paint()
        ..color = const Color(0xFFFBBF24).withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 308, height: 76),
        sandPaint,
      );

      // Turquoise Ocean Foam
      final foamPaint = Paint()
        ..color = const Color(0xFFE0F2FE).withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 312, height: 80),
        foamPaint,
      );
    }

    // Glowing Biome Edge Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = biome.themeColor.withAlpha(140);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 310, height: 78),
      borderPaint,
    );

    // 5. Flowing River Stream Cutting across the surface
    Color riverColor1 = const Color(0xFF38BDF8);
    Color riverColor2 = const Color(0xFF0284C7);
    if (biome == IslandBiome.sakura) {
      riverColor1 = const Color(0xFF67E8F9);
      riverColor2 = const Color(0xFF3B82F6);
    } else if (biome == IslandBiome.tropical) {
      riverColor1 = const Color(0xFF2DD4BF);
      riverColor2 = const Color(0xFF0D9488);
    }

    final riverPaint = Paint()
      ..shader = LinearGradient(
        colors: [riverColor1, riverColor2],
      ).createShader(Rect.fromLTWH(cx - 70, cy - 30, 140, 60));

    final riverPath = Path()
      ..moveTo(cx - 35, cy - 34)
      ..quadraticBezierTo(cx - 5, cy, cx - 20, cy + 34)
      ..lineTo(cx + 10, cy + 36)
      ..quadraticBezierTo(cx + 20, cy, cx - 12, cy - 34)
      ..close();
    canvas.drawPath(riverPath, riverPaint);
  }

  void _drawCascadingWaterfall(Canvas canvas, double cx, double cy) {
    // Water stream spilling off the southern cliff face
    final waterfallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFFE0F2FE), Colors.transparent],
      ).createShader(Rect.fromLTWH(cx - 20, cy + 34, 30, 60));

    final fallPath = Path()
      ..moveTo(cx - 20, cy + 34)
      ..lineTo(cx - 15, cy + 85)
      ..lineTo(cx + 5, cy + 85)
      ..lineTo(cx + 10, cy + 36)
      ..close();
    canvas.drawPath(fallPath, waterfallPaint);

    // White foam streaks in the fall
    final foamPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - 10, cy + 36), Offset(cx - 7, cy + 80), foamPaint);
    canvas.drawLine(Offset(cx - 2, cy + 36), Offset(cx + 1, cy + 75), foamPaint);
  }

  void _drawWaterfallMist(Canvas canvas, double cx, double cy, Size size) {
    // Soft glowing mist under the waterfall
    final mistPaint = Paint()
      ..color = const Color(0xFFBAE6FD).withAlpha(45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(cx - 5, cy + 85), 24, mistPaint);
  }

  void _drawBiomeEnvironmentalProps(Canvas canvas, double cx, double cy, double sway) {
    switch (biome) {
      // 🌸 SAKURA PROPS: Red Zen Arched Bridge across the koi river & Petals
      case IslandBiome.sakura:
        final bridgePaint = Paint()
          ..color = const Color(0xFFDC2626)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final bridgePath = Path()
          ..moveTo(cx - 30, cy + 2)
          ..quadraticBezierTo(cx - 5, cy - 10, cx + 15, cy + 4);
        canvas.drawPath(bridgePath, bridgePaint);
        break;

      // 🏝️ TROPICAL PROPS: Tropical Hibiscus Flowers
      case IslandBiome.tropical:
        final flowerPaint = Paint()..color = const Color(0xFFF43F5E);
        canvas.drawCircle(Offset(cx - 110, cy + 2), 3.5, flowerPaint);
        canvas.drawCircle(Offset(cx + 105, cy + 4), 3.5, flowerPaint);
        canvas.drawCircle(Offset(cx + 45, cy + 18), 3.0, flowerPaint);
        break;

      // ☀️ GOLDEN SUN PROPS: Natural Moss Rocks
      case IslandBiome.goldValley:
        final mossRock = Paint()..color = const Color(0xFF78350F);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 95, cy - 6), width: 14, height: 8), mossRock);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 85, cy - 4), width: 12, height: 7), mossRock);
        break;

      // 🌲 EMERALD PROPS: Mountain Wildflowers & Mossy Boulders
      case IslandBiome.emerald:
        final flowerPaint = Paint()..color = const Color(0xFFF472B6);
        canvas.drawCircle(Offset(cx - 100, cy + 2), 3.0, flowerPaint);
        canvas.drawCircle(Offset(cx + 90, cy + 5), 3.0, flowerPaint);
        final mossRock = Paint()..color = const Color(0xFF475569);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 55, cy + 12), width: 12, height: 7), mossRock);
        break;
    }
  }

  void _drawAccumulatedTrees(Canvas canvas, double cx, double cy, double sway) {
    // 20 rich strategic plots across the 3D surface
    final List<Offset> plots = [
      Offset(cx - 105, cy - 10),
      Offset(cx + 100, cy - 8),
      Offset(cx - 65, cy - 22),
      Offset(cx + 60, cy - 24),
      Offset(cx - 25, cy - 28),
      Offset(cx + 25, cy - 26),
      Offset(cx - 85, cy + 10),
      Offset(cx + 80, cy + 12),
      Offset(cx - 45, cy + 14),
      Offset(cx + 45, cy + 16),
      Offset(cx, cy + 20),
      Offset(cx - 125, cy - 2),
      Offset(cx + 120, cy - 4),
      Offset(cx - 50, cy - 6),
      Offset(cx + 45, cy - 8),
      Offset(cx - 15, cy + 4),
      Offset(cx + 15, cy + 6),
      Offset(cx - 70, cy + 22),
      Offset(cx + 65, cy + 24),
      Offset(cx - 95, cy - 20),
    ];

    final activeRecords = records.where((r) => r.mealsCount > 0 || r.totalCalories > 0).toList();

    // When 0 records, the pristine island awaits user's first trees
    if (activeRecords.isEmpty) {
      return;
    }

    for (int i = 0; i < min(activeRecords.length, plots.length); i++) {
      final record = activeRecords[i];
      final plot = plots[i];
      final scale = 0.90 + (i % 3) * 0.15;
      _drawMiniTree(canvas, plot, record.treeStage, sway, scale);
    }
  }

  void _drawMiniTree(Canvas canvas, Offset pos, TreeStage stage, double sway, double scale) {
    final px = pos.dx;
    final py = pos.dy;

    switch (biome) {
      // 🌸 SAKURA BOTANICAL TREE (Layered Cherry Blossom Clouds)
      case IslandBiome.sakura:
        _drawSakuraTree(canvas, px, py, stage, sway, scale);
        break;

      // 🏝️ TROPICAL BOTANICAL TREE (Real Curved Coconut Palms)
      case IslandBiome.tropical:
        _drawPalmTree(canvas, px, py, stage, sway, scale);
        break;

      // ☀️ GOLDEN SUN BOTANICAL TREE (Amber Redwoods & Autumn Oaks)
      case IslandBiome.goldValley:
        _drawAutumnTree(canvas, px, py, stage, sway, scale);
        break;

      // 🌲 EMERALD BOTANICAL TREE (Alpine Evergreens & Emerald Oaks)
      case IslandBiome.emerald:
        _drawEmeraldTree(canvas, px, py, stage, sway, scale);
        break;
    }
  }

  // 🌸 SAKURA TREE PAINTER
  void _drawSakuraTree(Canvas canvas, double px, double py, TreeStage stage, double sway, double scale) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 3.6 * scale
      ..strokeCap = StrokeCap.round;

    final pinkDark = const Color(0xFFF472B6);
    final pinkMid = const Color(0xFFFBCFE8);
    final pinkLight = const Color(0xFFFDF4FF);

    if (stage == TreeStage.goldenTree || stage == TreeStage.lushTree) {
      final path = Path()
        ..moveTo(px, py)
        ..quadraticBezierTo(px + 4 * scale, py - 16 * scale, px + sway * 0.4, py - 32 * scale);
      canvas.drawPath(path, trunkPaint);

      final foliagePaint = Paint()
        ..color = (stage == TreeStage.goldenTree) ? const Color(0xFFFDE047) : pinkDark;
      canvas.drawCircle(Offset(px + sway * 0.4 - 7 * scale, py - 35 * scale), 14 * scale, foliagePaint);
      canvas.drawCircle(Offset(px + sway * 0.4 + 7 * scale, py - 33 * scale), 13 * scale, foliagePaint);

      foliagePaint.color = (stage == TreeStage.goldenTree) ? AppColors.gold : pinkMid;
      canvas.drawCircle(Offset(px + sway * 0.4, py - 40 * scale), 16 * scale, foliagePaint);

      foliagePaint.color = (stage == TreeStage.goldenTree) ? Colors.white : pinkLight;
      canvas.drawCircle(Offset(px + sway * 0.4 - 3 * scale, py - 44 * scale), 9 * scale, foliagePaint);
    } else if (stage == TreeStage.sapling) {
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.5, py - 20 * scale), trunkPaint);
      final fol = Paint()..color = pinkDark;
      canvas.drawCircle(Offset(px + sway * 0.5, py - 24 * scale), 9 * scale, fol);
    } else if (stage == TreeStage.seed) {
      final stemPaint = Paint()..color = pinkDark..strokeWidth = 2.0 * scale;
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.3, py - 12 * scale), stemPaint);
      canvas.drawCircle(Offset(px + sway * 0.3, py - 14 * scale), 4.0 * scale, stemPaint);
    } else {
      _drawWitheredBranches(canvas, px, py, sway, scale);
    }
  }

  // 🏝️ TROPICAL COCONUT PALM TREE PAINTER
  void _drawPalmTree(Canvas canvas, double px, double py, TreeStage stage, double sway, double scale) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 3.6 * scale
      ..strokeCap = StrokeCap.round;

    if (stage == TreeStage.goldenTree || stage == TreeStage.lushTree) {
      // Curved Palm Trunk
      final path = Path()
        ..moveTo(px, py)
        ..quadraticBezierTo(px + 10 * scale, py - 18 * scale, px + 6 * scale + sway * 0.5, py - 36 * scale);
      canvas.drawPath(path, trunkPaint);

      final top = Offset(px + 6 * scale + sway * 0.5, py - 36 * scale);
      final frondPaint = Paint()
        ..color = (stage == TreeStage.goldenTree) ? AppColors.gold : const Color(0xFF10B981)
        ..strokeWidth = 2.8 * scale
        ..strokeCap = StrokeCap.round;

      // 6 Radiating Palm Fronds curving downwards
      final frondOffsets = [
        Offset(-18 * scale, 8 * scale),
        Offset(18 * scale, 8 * scale),
        Offset(-22 * scale, -5 * scale),
        Offset(22 * scale, -5 * scale),
        Offset(-14 * scale, -15 * scale),
        Offset(14 * scale, -15 * scale),
      ];

      for (var f in frondOffsets) {
        final frondPath = Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(top.dx + f.dx * 0.5, top.dy + f.dy - 8 * scale, top.dx + f.dx, top.dy + f.dy);
        canvas.drawPath(frondPath, frondPaint);
      }

      // Coconuts
      final coconutPaint = Paint()..color = const Color(0xFF451A03);
      canvas.drawCircle(Offset(top.dx - 3 * scale, top.dy + 3 * scale), 2.5 * scale, coconutPaint);
      canvas.drawCircle(Offset(top.dx + 3 * scale, top.dy + 3 * scale), 2.5 * scale, coconutPaint);
    } else if (stage == TreeStage.sapling) {
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.4, py - 18 * scale), trunkPaint);
      final frondPaint = Paint()..color = const Color(0xFF10B981)..strokeWidth = 2.4 * scale;
      canvas.drawLine(Offset(px + sway * 0.4, py - 18 * scale), Offset(px - 10 * scale, py - 26 * scale), frondPaint);
      canvas.drawLine(Offset(px + sway * 0.4, py - 18 * scale), Offset(px + 10 * scale, py - 26 * scale), frondPaint);
    } else if (stage == TreeStage.seed) {
      final nutPaint = Paint()..color = const Color(0xFF78350F);
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py - 3 * scale), width: 8 * scale, height: 6 * scale), nutPaint);
      final sproutPaint = Paint()..color = const Color(0xFF34D399)..strokeWidth = 2.0 * scale;
      canvas.drawLine(Offset(px, py - 6 * scale), Offset(px + sway * 0.3, py - 14 * scale), sproutPaint);
    } else {
      _drawWitheredBranches(canvas, px, py, sway, scale);
    }
  }

  // ☀️ GOLDEN SUN AUTUMN TREE PAINTER
  void _drawAutumnTree(Canvas canvas, double px, double py, TreeStage stage, double sway, double scale) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 3.8 * scale
      ..strokeCap = StrokeCap.round;

    if (stage == TreeStage.goldenTree || stage == TreeStage.lushTree) {
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.4, py - 32 * scale), trunkPaint);
      final folPaint = Paint()
        ..color = (stage == TreeStage.goldenTree) ? AppColors.gold : const Color(0xFFEA580C);
      canvas.drawCircle(Offset(px + sway * 0.4 - 6 * scale, py - 36 * scale), 14 * scale, folPaint);
      canvas.drawCircle(Offset(px + sway * 0.4 + 6 * scale, py - 34 * scale), 13 * scale, folPaint);

      folPaint.color = (stage == TreeStage.goldenTree) ? const Color(0xFFFEF08A) : const Color(0xFFFBBF24);
      canvas.drawCircle(Offset(px + sway * 0.4, py - 42 * scale), 16 * scale, folPaint);
    } else if (stage == TreeStage.sapling) {
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.5, py - 20 * scale), trunkPaint);
      final folPaint = Paint()..color = const Color(0xFFF59E0B);
      canvas.drawCircle(Offset(px + sway * 0.5, py - 24 * scale), 9 * scale, folPaint);
    } else if (stage == TreeStage.seed) {
      final stemPaint = Paint()..color = const Color(0xFFFBBF24)..strokeWidth = 2.0 * scale;
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.3, py - 12 * scale), stemPaint);
      canvas.drawCircle(Offset(px + sway * 0.3, py - 13 * scale), 4.0 * scale, stemPaint);
    } else {
      _drawWitheredBranches(canvas, px, py, sway, scale);
    }
  }

  // 🌲 EMERALD OAK & ALPINE EVERGREEN PAINTER
  void _drawEmeraldTree(Canvas canvas, double px, double py, TreeStage stage, double sway, double scale) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round;

    if (stage == TreeStage.goldenTree || stage == TreeStage.lushTree) {
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.4, py - 30 * scale), trunkPaint);
      final folPaint = Paint()
        ..color = (stage == TreeStage.goldenTree) ? AppColors.gold : AppColors.primary;
      canvas.drawCircle(Offset(px + sway * 0.4 - 6 * scale, py - 35 * scale), 14 * scale, folPaint);
      canvas.drawCircle(Offset(px + sway * 0.4 + 6 * scale, py - 33 * scale), 13 * scale, folPaint);

      folPaint.color = (stage == TreeStage.goldenTree) ? const Color(0xFFFEF08A) : AppColors.primaryLight;
      canvas.drawCircle(Offset(px + sway * 0.4, py - 40 * scale), 16 * scale, folPaint);
    } else if (stage == TreeStage.sapling) {
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.5, py - 20 * scale), trunkPaint);
      final folPaint = Paint()..color = AppColors.primary;
      canvas.drawCircle(Offset(px + sway * 0.5, py - 24 * scale), 9 * scale, folPaint);
    } else if (stage == TreeStage.seed) {
      final stemPaint = Paint()..color = AppColors.primaryLight..strokeWidth = 2.0 * scale;
      canvas.drawLine(Offset(px, py), Offset(px + sway * 0.3, py - 12 * scale), stemPaint);
      final leafPaint = Paint()..color = AppColors.primary;
      canvas.drawOval(Rect.fromCenter(center: Offset(px - 4, py - 13 * scale), width: 7 * scale, height: 5 * scale), leafPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(px + 4, py - 13 * scale), width: 7 * scale, height: 5 * scale), leafPaint);
    } else {
      _drawWitheredBranches(canvas, px, py, sway, scale);
    }
  }

  void _drawWitheredBranches(Canvas canvas, double px, double py, double sway, double scale) {
    final dryPaint = Paint()..color = const Color(0xFF64748B)..strokeWidth = 2.2 * scale;
    canvas.drawLine(Offset(px, py), Offset(px + sway * 0.2, py - 20 * scale), dryPaint);
    canvas.drawLine(Offset(px + sway * 0.2, py - 14 * scale), Offset(px - 7 * scale, py - 20 * scale), dryPaint);
    canvas.drawLine(Offset(px + sway * 0.2, py - 16 * scale), Offset(px + 7 * scale, py - 22 * scale), dryPaint);
  }

  void _drawAtmosphere(Canvas canvas, double cx, double cy, Size size) {
    // 1. Soft Volumetric Clouds floating in the breeze
    final cloudPaint = Paint()
      ..color = Colors.white.withAlpha(32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 110 + animValue * 24, cy - 90), width: 85, height: 26),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 105 - animValue * 20, cy - 75), width: 75, height: 22),
      cloudPaint,
    );

    // 2. Flying Tropical Seabirds (in Tropical Biome)
    if (biome == IslandBiome.tropical) {
      final birdPaint = Paint()
        ..color = const Color(0xFFE0F2FE).withAlpha(180)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      // Gull 1
      final b1 = Offset(cx - 80 + animValue * 15, cy - 120);
      final p1 = Path()..moveTo(b1.dx - 6, b1.dy)..quadraticBezierTo(b1.dx - 3, b1.dy - 4, b1.dx, b1.dy)..quadraticBezierTo(b1.dx + 3, b1.dy - 4, b1.dx + 6, b1.dy);
      canvas.drawPath(p1, birdPaint);

      // Gull 2
      final b2 = Offset(cx + 60 - animValue * 12, cy - 135);
      final p2 = Path()..moveTo(b2.dx - 5, b2.dy)..quadraticBezierTo(b2.dx - 2.5, b2.dy - 3, b2.dx, b2.dy)..quadraticBezierTo(b2.dx + 2.5, b2.dy - 3, b2.dx + 5, b2.dy);
      canvas.drawPath(p2, birdPaint);
    }

    // 3. Floating ambient sparkles (Sakura petals or Sun flares or Fireflies)
    final glowColor = (biome == IslandBiome.sakura)
        ? const Color(0xFFF472B6).withAlpha(200)
        : (biome == IslandBiome.goldValley)
            ? AppColors.gold.withAlpha(200)
            : (biome == IslandBiome.tropical)
                ? const Color(0xFF38BDF8).withAlpha(200)
                : AppColors.primaryLight.withAlpha(200);

    final glowDotPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final dots = [
      Offset(cx - 50 + sin(animValue * 3) * 16, cy - 45 + cos(animValue * 2) * 10),
      Offset(cx + 70 + cos(animValue * 3) * 14, cy - 55 + sin(animValue * 2) * 8),
      Offset(cx - 90 + sin(animValue * 2) * 10, cy + 8 + cos(animValue * 3) * 6),
      Offset(cx + 30 + cos(animValue * 4) * 18, cy - 25 + sin(animValue * 3) * 10),
      Offset(cx - 20 + sin(animValue * 2.5) * 12, cy - 80 + cos(animValue * 3) * 8),
    ];
    for (var dot in dots) {
      canvas.drawCircle(dot, 2.8, glowDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LivingIslandPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.biome != biome ||
        oldDelegate.records.length != records.length;
  }
}
