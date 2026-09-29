import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_item.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AddMealScreen extends StatefulWidget {
  final MealType? initialMealType;

  const AddMealScreen({super.key, this.initialMealType});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();

  late MealType _mealType;
  int _healthScore = 8;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType ?? MealType.lunch;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Öğün Ekle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meal Type Selector
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Öğün Türü',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: MealType.values.map((type) {
                        final isSelected = type == _mealType;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mealType = type),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(40)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(type.emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(
                                    type.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
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
              ),

              const SizedBox(height: 16),

              // Meal Name & Calories
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yemek Detayları',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextInput(
                      controller: _nameController,
                      label: 'Yemek Adı',
                      hint: 'Örn: Tavuklu Kinoa Salatası',
                      icon: Icons.restaurant,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Lütfen yemek adını girin' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextInput(
                      controller: _caloriesController,
                      label: 'Kalori (kcal)',
                      hint: 'Örn: 450',
                      icon: Icons.local_fire_department,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Kalori değeri girin';
                        if (double.tryParse(val.trim()) == null) return 'Geçerli bir sayı girin';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Macros (Protein, Carbs, Fat)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Makro Değerleri (Gram)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            controller: _proteinController,
                            label: 'Protein (g)',
                            hint: '30',
                            icon: Icons.fitness_center,
                            keyboardType: TextInputType.number,
                            accentColor: AppColors.protein,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextInput(
                            controller: _carbsController,
                            label: 'Karb (g)',
                            hint: '45',
                            icon: Icons.grain,
                            keyboardType: TextInputType.number,
                            accentColor: AppColors.carbs,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextInput(
                            controller: _fatController,
                            label: 'Yağ (g)',
                            hint: '15',
                            icon: Icons.opacity,
                            keyboardType: TextInputType.number,
                            accentColor: AppColors.fat,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Health Score Slider
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sağlık Puanı',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '⭐ $_healthScore / 10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _healthScore.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surfaceLight,
                      onChanged: (val) => setState(() => _healthScore = val.toInt()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: _buildTextInput(
                  controller: _notesController,
                  label: 'Notlar (Opsiyonel)',
                  hint: 'Soslar, porsiyon veya özel detaylar...',
                  icon: Icons.edit_note,
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Öğünü Kaydet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Color? accentColor,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: accentColor ?? AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (accentColor ?? Colors.white).withAlpha(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              icon: Icon(icon, size: 18, color: accentColor ?? AppColors.textMuted),
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  void _saveMeal() {
    if (_formKey.currentState?.validate() != true) return;

    final cal = double.tryParse(_caloriesController.text.trim()) ?? 0.0;
    final p = double.tryParse(_proteinController.text.trim()) ?? 0.0;
    final c = double.tryParse(_carbsController.text.trim()) ?? 0.0;
    final f = double.tryParse(_fatController.text.trim()) ?? 0.0;

    final meal = MealItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      calories: cal,
      protein: p,
      carbs: c,
      fat: f,
      dateTime: DateTime.now(),
      mealType: _mealType,
      healthScore: _healthScore,
      notes: _notesController.text.trim(),
    );

    final provider = Provider.of<CalorieProvider>(context, listen: false);
    provider.addMeal(meal);

    Navigator.pop(context);
  }
}
