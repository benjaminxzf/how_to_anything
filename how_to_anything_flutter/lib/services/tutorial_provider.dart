import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/tutorial.dart';
import '../models/tutorial_step.dart';
import '../services/gemini_service.dart';

enum TutorialState {
  idle,
  loading,
  completed,
  error,
}

class TutorialProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  
  TutorialState _state = TutorialState.idle;
  Tutorial? _tutorial;
  String _progressMessage = '';
  String _errorMessage = '';
  Map<int, String?> _stepImages = {};
  Uint8List? _selectedImageBytes;
  
  TutorialState get state => _state;
  Tutorial? get tutorial => _tutorial;
  String get progressMessage => _progressMessage;
  String get errorMessage => _errorMessage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  
  String? getStepImage(int stepIndex) => _stepImages[stepIndex];
  
  void setSelectedImage(Uint8List? imageBytes) {
    _selectedImageBytes = imageBytes;
    notifyListeners();
  }
  
  Future<void> generateTutorial(String query, {bool generateImages = true, Uint8List? imageBytes}) async {
    print('[TutorialProvider] Starting generateTutorial for: $query');
    _state = TutorialState.loading;
    _errorMessage = '';
    _progressMessage = 'Starting tutorial generation...';
    _stepImages.clear();
    notifyListeners();
    
    try {
      _tutorial = await _geminiService.generateCompleteTutorial(
        query,
        (progress) {
          print('[TutorialProvider] Progress: $progress');
          _progressMessage = progress;
          notifyListeners();
        },
        generateImages: generateImages,
        imageBytes: imageBytes,
        onImageUpdate: (stepIndex, imageUrl) {
          print('[TutorialProvider] Image update received for step $stepIndex');
          print('[TutorialProvider] Image URL length: ${imageUrl?.length ?? 0}');
          
          _stepImages[stepIndex] = imageUrl;
          // Update the tutorial step with the new image
          if (_tutorial != null && stepIndex < _tutorial!.steps.length) {
            print('[TutorialProvider] Updating tutorial step $stepIndex with image');
            final updatedSteps = List<TutorialStep>.from(_tutorial!.steps);
            updatedSteps[stepIndex] = updatedSteps[stepIndex].copyWith(
              imageUrl: imageUrl,
            );
            _tutorial = _tutorial!.copyWith(steps: updatedSteps);
            print('[TutorialProvider] Tutorial step $stepIndex updated, notifying listeners');
          } else {
            print('[TutorialProvider] WARNING: Cannot update step $stepIndex - tutorial is null or index out of bounds');
          }
          notifyListeners();
        },
      );
      
      print('[TutorialProvider] Tutorial generation completed, state set to completed');
      _state = TutorialState.completed;
      _progressMessage = 'Tutorial ready!';
    } catch (e) {
      print('[TutorialProvider] ERROR in generateTutorial: $e');
      _state = TutorialState.error;
      _errorMessage = e.toString();
      _progressMessage = '';
    }
    
    notifyListeners();
  }
  
  void reset() {
    _state = TutorialState.idle;
    _tutorial = null;
    _progressMessage = '';
    _errorMessage = '';
    _stepImages.clear();
    _selectedImageBytes = null;
    notifyListeners();
  }
}