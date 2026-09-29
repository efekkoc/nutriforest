import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';
import 'glass_card.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late AiProviderType _selectedProvider;
  late TextEditingController _geminiController;
  late TextEditingController _openAiController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _selectedProvider = settings.aiProvider;
    _geminiController = TextEditingController(text: settings.geminiApiKey);
    _openAiController = TextEditingController(text: settings.openAiApiKey);
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _openAiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGemini = _selectedProvider == AiProviderType.gemini;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yapay Zeka Servisi & API',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Fotoğraftan Gerçek Yemek Tespiti',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Provider Selector Switcher (Gemini vs OpenAI)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _ProviderTab(
                        title: 'Google Gemini',
                        subtitle: 'Ücretsiz & Hızlı ⚡',
                        isSelected: isGemini,
                        onTap: () => setState(() => _selectedProvider = AiProviderType.gemini),
                      ),
                    ),
                    Expanded(
                      child: _ProviderTab(
                        title: 'OpenAI ChatGPT',
                        subtitle: 'GPT-4o Vision 🧠',
                        isSelected: !isGemini,
                        onTap: () => setState(() => _selectedProvider = AiProviderType.chatgpt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step-by-Step Beginner Guide Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isGemini
                      ? AppColors.primary.withAlpha(15)
                      : const Color(0xFF10A37F).withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isGemini
                        ? AppColors.primary.withAlpha(50)
                        : const Color(0xFF10A37F).withAlpha(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 16,
                          color: isGemini ? AppColors.primary : const Color(0xFF10A37F),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isGemini
                              ? 'Google Gemini API Nasıl Alınır? (30 Saniye - ÜCRETSİZ)'
                              : 'OpenAI ChatGPT API Nasıl Alınır?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isGemini ? AppColors.primaryLight : const Color(0xFF10A37F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isGemini) ...[
                      const _StepRow(num: '1', text: 'Tarayıcıda aistudio.google.com adresine gidin.'),
                      const _StepRow(num: '2', text: 'Mavi "Get API key" -> "Create API key" butonuna basın.'),
                      const _StepRow(num: '3', text: 'Çıkan AIzaSy... ile başlayan anahtarı kopyalayıp buraya yapıştırın.'),
                    ] else ...[
                      const _StepRow(num: '1', text: 'platform.openai.com/api-keys adresine gidin.'),
                      const _StepRow(num: '2', text: '"Create new secret key" butonuna basıp anahtar oluşturun.'),
                      const _StepRow(num: '3', text: 'sk-... ile başlayan anahtarı kopyalayıp buraya yapıştırın.'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // API Key Textfield
              Text(
                isGemini ? 'Google Gemini API Anahtarı' : 'OpenAI Secret Key (sk-...)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: isGemini ? _geminiController : _openAiController,
                        obscureText: _obscure,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: isGemini ? 'AIzaSy...' : 'sk-proj-...',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ],
                ),
              ),

                 // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: BouncyButton(
                      scaleFactor: 0.92,
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: const Text(
                          'İptal',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: BouncyButton(
                      scaleFactor: 0.94,
                      onTap: () async {
                        final nav = Navigator.of(context);
                        final settings = Provider.of<SettingsProvider>(context, listen: false);
                        await settings.setAiProvider(_selectedProvider);
                        await settings.setGeminiApiKey(_geminiController.text.trim());
                        await settings.setOpenAiApiKey(_openAiController.text.trim());
                        if (mounted) nav.pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(100),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Kaydet & Aktifleştir ⚡',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
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

class _ProviderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderTab({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      scaleFactor: 0.92,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(35) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String num;
  final String text;

  const _StepRow({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
