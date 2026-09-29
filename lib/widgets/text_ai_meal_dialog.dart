import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import 'ai_analysis_sheet.dart';
import 'api_key_dialog.dart';
import 'bouncy_button.dart';
import 'glass_card.dart';

class TextAiMealDialog extends StatefulWidget {
  const TextAiMealDialog({super.key});

  @override
  State<TextAiMealDialog> createState() => _TextAiMealDialogState();
}

class _TextAiMealDialogState extends State<TextAiMealDialog> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final List<String> _quickSuggestions = [
    '1 Kase Mercimek Çorbası ve 1 Dilim Ekmek',
    'Izgara Tavuk Göğsü (150g) ve Akdeniz Salatası',
    '2 Haşlanmış Yumurta, 30g Beyaz Peynir ve 5 Zeytin',
    '1 Dilim Karışık Pizza ve Ayran',
    'Yulaf Lapası, 1 Muz ve 1 Kaşık Fıstık Ezmesi',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.hasApiKey) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => const ApiKeyDialog(),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analysis = await AiService.analyzeFoodText(
        textDescription: text,
        apiKey: settings.apiKey,
        providerType: settings.aiProvider,
      );

      if (mounted) {
        Navigator.pop(context); // Close text dialog
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AiAnalysisSheet(
            analysis: analysis,
            imageBytes: null,
            onSaved: () {},
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yapay Zekaya Yazarak Ekle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Ne yediğini doğal dille yaz, yapay zeka hesaplasın',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Text Input Box
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Örn: 1 tabak kurufasulye, 3 kaşık pirinç pilavı ve cacık yedim...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ],

              const SizedBox(height: 14),

              // Quick Suggestions Chips
              const Text(
                'Hızlı Örnekler:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickSuggestions.map((sug) {
                  return BouncyButton(
                    scaleFactor: 0.90,
                    onTap: () {
                      _textController.text = sug;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        sug,
                        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: BouncyButton(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Center(
                          child: Text('İptal', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BouncyButton(
                      scaleFactor: 0.94,
                      onTap: _isLoading ? null : _analyzeText,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(90),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 16, color: Colors.black),
                                  SizedBox(width: 6),
                                  Text(
                                    'Analiz Et & Hesapla',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
