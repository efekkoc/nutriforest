import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  String _geminiApiKey = '';
  String _openAiApiKey = '';
  AiProviderType _aiProvider = AiProviderType.gemini;
  double _targetCalories = 2000.0;
  double _targetProtein = 130.0;
  double _targetCarbs = 220.0;
  double _targetFat = 65.0;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    try {
      _geminiApiKey = _storage.getApiKey();
      _openAiApiKey = _storage.getOpenAiApiKey();
      final providerStr = _storage.getAiProvider();
      _aiProvider = providerStr == 'chatgpt' ? AiProviderType.chatgpt : AiProviderType.gemini;
      _targetCalories = _storage.getTargetCalories();
      _targetProtein = _storage.getTargetProtein();
      _targetCarbs = _storage.getTargetCarbs();
      _targetFat = _storage.getTargetFat();
    } catch (_) {}
  }

  String get apiKey {
    final k = _aiProvider == AiProviderType.chatgpt ? _openAiApiKey : _geminiApiKey;
    return k.trim();
  }

  String get geminiApiKey => _geminiApiKey;
  String get openAiApiKey => _openAiApiKey;
  AiProviderType get aiProvider => _aiProvider;

  double get targetCalories => _targetCalories;
  double get targetProtein => _targetProtein;
  double get targetCarbs => _targetCarbs;
  double get targetFat => _targetFat;

  bool get hasApiKey => apiKey.isNotEmpty;

  Future<void> setApiKey(String key) async {
    if (_aiProvider == AiProviderType.chatgpt) {
      await setOpenAiApiKey(key);
    } else {
      await setGeminiApiKey(key);
    }
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key.trim();
    await _storage.setApiKey(_geminiApiKey);
    notifyListeners();
  }

  Future<void> setOpenAiApiKey(String key) async {
    _openAiApiKey = key.trim();
    await _storage.setOpenAiApiKey(_openAiApiKey);
    notifyListeners();
  }

  Future<void> setAiProvider(AiProviderType provider) async {
    _aiProvider = provider;
    await _storage.setAiProvider(provider == AiProviderType.chatgpt ? 'chatgpt' : 'gemini');
    notifyListeners();
  }

  Future<void> setTargetCalories(double val) async {
    _targetCalories = val;
    await _storage.setTargetCalories(val);
    notifyListeners();
  }

  Future<void> setMacros({
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    _targetProtein = protein;
    _targetCarbs = carbs;
    _targetFat = fat;
    await _storage.setTargetProtein(protein);
    await _storage.setTargetCarbs(carbs);
    await _storage.setTargetFat(fat);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await _storage.resetAll();
    _loadSettings();
    notifyListeners();
  }
}
