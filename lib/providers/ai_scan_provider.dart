import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ai_meal_analysis.dart';
import '../services/ai_service.dart';

class AiScanProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isAnalyzing = false;
  AiMealAnalysis? _analysisResult;
  String? _errorMessage;

  Uint8List? get imageBytes => _imageBytes;
  String? get imageName => _imageName;
  bool get isAnalyzing => _isAnalyzing;
  AiMealAnalysis? get analysisResult => _analysisResult;
  String? get errorMessage => _errorMessage;

  Future<bool> pickAndAnalyzeImage({
    required ImageSource source,
    required String apiKey,
    AiProviderType providerType = AiProviderType.gemini,
  }) async {
    _errorMessage = null;
    _analysisResult = null;
    _imageBytes = null;
    _imageName = null;

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file == null) {
        _isAnalyzing = false;
        notifyListeners();
        return false; // User cancelled
      }

      _isAnalyzing = true;
      _imageName = file.name;
      notifyListeners();

      // Read as bytes (Cross-platform for Web, Android, iOS)
      _imageBytes = await file.readAsBytes();
      notifyListeners();

      // Analyze with AI (Gemini or ChatGPT)
      final result = await AiService.analyzeFoodImage(
        imageBytes: _imageBytes!,
        apiKey: apiKey,
        providerType: providerType,
        mimeType: file.mimeType ?? 'image/jpeg',
      );

      _analysisResult = result;
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = 'Görsel analiz edilirken bir sorun oluştu: ${e.toString().replaceFirst("Exception: ", "")}';
      notifyListeners();
      return false;
    } finally {
      if (_isAnalyzing) {
        _isAnalyzing = false;
        notifyListeners();
      }
    }
  }

  void setCustomAnalysis(AiMealAnalysis analysis, Uint8List? bytes) {
    _analysisResult = analysis;
    _imageBytes = bytes;
    notifyListeners();
  }

  void clear() {
    _imageBytes = null;
    _imageName = null;
    _isAnalyzing = false;
    _analysisResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
