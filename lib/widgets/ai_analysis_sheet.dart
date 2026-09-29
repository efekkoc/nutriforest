import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_meal_analysis.dart';
import '../models/meal_item.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';
import 'glass_card.dart';

class AiAnalysisSheet extends StatefulWidget {
  final AiMealAnalysis analysis;
  final Uint8List? imageBytes;
  final VoidCallback onSaved;

  const AiAnalysisSheet({
    super.key,
    required this.analysis,
    this.imageBytes,
    required this.onSaved,
  });

  @override
  State<AiAnalysisSheet> createState() => _AiAnalysisSheetState();
}

class _AiAnalysisSheetState extends State<AiAnalysisSheet> {
  late MealType _selectedMealType;
  late TextEditingController _nameController;
  late TextEditingController _calController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbs;
  late double _baseFat;

  double _currentCalories = 0;
  double _currentProtein = 0;
  double _currentCarbs = 0;
  double _currentFat = 0;

  double _selectedPortion = 1.0;
  bool _isSaving = false;
  bool _isCaloriePulsing = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _guessMealType();
    _nameController = TextEditingController(text: widget.analysis.foodName);

    _baseCalories = widget.analysis.totalCalories;
    _baseProtein = widget.analysis.protein;
    _baseCarbs = widget.analysis.carbs;
    _baseFat = widget.analysis.fat;

    _currentCalories = _baseCalories;
    _currentProtein = _baseProtein;
    _currentCarbs = _baseCarbs;
    _currentFat = _baseFat;

    _calController = TextEditingController(text: _currentCalories.toStringAsFixed(0));
    _proteinController = TextEditingController(text: _currentProtein.toStringAsFixed(0));
    _carbsController = TextEditingController(text: _currentCarbs.toStringAsFixed(0));
    _fatController = TextEditingController(text: _currentFat.toStringAsFixed(0));
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  void _applyPortionMultiplier(double multiplier) {
    setState(() {
      _selectedPortion = multiplier;
      _currentCalories = (_baseCalories * multiplier).roundToDouble();
      _currentProtein = (_baseProtein * multiplier).roundToDouble();
      _currentCarbs = (_baseCarbs * multiplier).roundToDouble();
      _currentFat = (_baseFat * multiplier).roundToDouble();

      _calController.text = _currentCalories.toStringAsFixed(0);
      _proteinController.text = _currentProtein.toStringAsFixed(0);
      _carbsController.text = _currentCarbs.toStringAsFixed(0);
      _fatController.text = _currentFat.toStringAsFixed(0);
      _isCaloriePulsing = true;
    });

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _isCaloriePulsing = false);
    });
  }

  void _adjustCalories(double delta) {
    setState(() {
      _currentCalories = (_currentCalories + delta).clamp(10, 5000);
      _calController.text = _currentCalories.toStringAsFixed(0);
      _isCaloriePulsing = true;
    });

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _isCaloriePulsing = false);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // AI Badge & Close Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withAlpha(90)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                            SizedBox(width: 5),
                            Text(
                              'Yapay Zeka Besin Analizi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Doğruluk: %${(widget.analysis.confidence * 100).toInt()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  BouncyButton(
                    scaleFactor: 0.88,
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image & Editable Food Title Card
              GlassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          widget.imageBytes!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('🍲', style: TextStyle(fontSize: 28))),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yemek Adı (Düzenlenebilir ✏️)',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.analysis.portionSize} • ★ ${widget.analysis.healthScore}/10 Sağlık Skoru',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Interactive Calorie Card with Stepper & Direct Editing
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                hasGlow: true,
                glowColor: AppColors.primary,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesaplanan Kalori',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Değeri istediğin gibi değiştirebilirsin',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            AnimatedScale(
                              scale: _isCaloriePulsing ? 1.25 : 1.0,
                              duration: const Duration(milliseconds: 140),
                              curve: Curves.easeOutBack,
                              child: SizedBox(
                                width: 85,
                                child: TextField(
                                  controller: _calController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: _isCaloriePulsing ? AppColors.gold : AppColors.primary,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (val) {
                                    final n = double.tryParse(val);
                                    if (n != null) {
                                      _currentCalories = n;
                                    }
                                  },
                                ),
                              ),
                            ),
                            const Text(
                              ' kcal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Calorie Stepper Buttons (-100, -50, +50, +100)
                    Row(
                      children: [
                        Expanded(
                          child: _StepperPill(
                            label: '-100',
                            onTap: () => _adjustCalories(-100),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StepperPill(
                            label: '-50',
                            onTap: () => _adjustCalories(-50),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StepperPill(
                            label: '+50',
                            isAdd: true,
                            onTap: () => _adjustCalories(50),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StepperPill(
                            label: '+100',
                            isAdd: true,
                            onTap: () => _adjustCalories(100),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Portion Multiplier Chips (0.5x, 1x, 1.5x, 2x)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Porsiyon Büyüklüğü',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _PortionChip(
                        label: '0.5x (Yarım)',
                        isSelected: _selectedPortion == 0.5,
                        onTap: () => _applyPortionMultiplier(0.5),
                      ),
                      const SizedBox(width: 6),
                      _PortionChip(
                        label: '1.0x (Tam)',
                        isSelected: _selectedPortion == 1.0,
                        onTap: () => _applyPortionMultiplier(1.0),
                      ),
                      const SizedBox(width: 6),
                      _PortionChip(
                        label: '1.5x (Büyük)',
                        isSelected: _selectedPortion == 1.5,
                        onTap: () => _applyPortionMultiplier(1.5),
                      ),
                      const SizedBox(width: 6),
                      _PortionChip(
                        label: '2.0x (Duble)',
                        isSelected: _selectedPortion == 2.0,
                        onTap: () => _applyPortionMultiplier(2.0),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Editable Macro Breakdown Pills (Protein, Karbonhidrat, Yağ)
              Row(
                children: [
                  Expanded(
                    child: _EditableMacroCard(
                      label: 'Protein',
                      controller: _proteinController,
                      unit: 'g',
                      color: AppColors.protein,
                      onChanged: (v) {
                        _currentProtein = double.tryParse(v) ?? _currentProtein;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _EditableMacroCard(
                      label: 'Karbonhidrat',
                      controller: _carbsController,
                      unit: 'g',
                      color: AppColors.carbs,
                      onChanged: (v) {
                        _currentCarbs = double.tryParse(v) ?? _currentCarbs;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _EditableMacroCard(
                      label: 'Yağ',
                      controller: _fatController,
                      unit: 'g',
                      color: AppColors.fat,
                      onChanged: (v) {
                        _currentFat = double.tryParse(v) ?? _currentFat;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Meal Category Picker (Kahvaltı, Öğle, Akşam, Ara Öğün)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Öğün Kategorisi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: MealType.values.map((type) {
                      final isSel = _selectedMealType == type;
                      return Expanded(
                        child: BouncyButton(
                          scaleFactor: 0.88,
                          onTap: () => setState(() => _selectedMealType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary.withAlpha(45) : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.glassBorder,
                                width: isSel ? 1.5 : 1.0,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(80),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Text(type.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 3),
                                Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // AI Dietitian Advice Box
              if (widget.analysis.healthAdvice.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.analysis.healthAdvice,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Save Button (Adds to Day & Plants to Forest Island)
              BouncyButton(
                scaleFactor: 0.94,
                onTap: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        final name = _nameController.text.trim().isEmpty
                            ? widget.analysis.foodName
                            : _nameController.text.trim();

                        final cal = double.tryParse(_calController.text) ?? _currentCalories;
                        final p = double.tryParse(_proteinController.text) ?? _currentProtein;
                        final c = double.tryParse(_carbsController.text) ?? _currentCarbs;
                        final f = double.tryParse(_fatController.text) ?? _currentFat;

                        final calorieProvider = Provider.of<CalorieProvider>(context, listen: false);
                        final targetDate = calorieProvider.selectedDate;
                        final now = DateTime.now();
                        final mealDateTime = DateTime(
                          targetDate.year,
                          targetDate.month,
                          targetDate.day,
                          now.hour,
                          now.minute,
                          now.second,
                        );

                        final item = MealItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          calories: cal,
                          protein: p,
                          carbs: c,
                          fat: f,
                          dateTime: mealDateTime,
                          mealType: _selectedMealType,
                          healthScore: widget.analysis.healthScore,
                          notes: widget.analysis.healthAdvice,
                          imageBytes: widget.imageBytes,
                        );

                        final nav = Navigator.of(context);
                        await calorieProvider.addMeal(item);

                        if (mounted) {
                          widget.onSaved();
                          nav.pop();
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(120),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isSaving
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 20, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              'Günlüğe Ekle & Adayı Yeşert 🌳',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperPill extends StatelessWidget {
  final String label;
  final bool isAdd;
  final VoidCallback onTap;

  const _StepperPill({
    required this.label,
    this.isAdd = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      scaleFactor: 0.88,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary.withAlpha(35) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdd ? AppColors.primary.withAlpha(120) : AppColors.glassBorder,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isAdd ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PortionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PortionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BouncyButton(
        scaleFactor: 0.88,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableMacroCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final Color color;
  final ValueChanged<String> onChanged;

  const _EditableMacroCard({
    required this.label,
    required this.controller,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
