import 'package:flutter/foundation.dart';
import '../models/tutorial.dart';
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
  
  TutorialState get state => _state;
  Tutorial? get tutorial => _tutorial;
  String get progressMessage => _progressMessage;
  String get errorMessage => _errorMessage;
  
  Future<void> generateTutorial(String query) async {
    _state = TutorialState.loading;
    _errorMessage = '';
    _progressMessage = 'Starting tutorial generation...';
    notifyListeners();
    
    try {
      _tutorial = await _geminiService.generateCompleteTutorial(
        query,
        (progress) {
          _progressMessage = progress;
          notifyListeners();
        },
      );
      
      _state = TutorialState.completed;
      _progressMessage = 'Tutorial ready!';
    } catch (e) {
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
    notifyListeners();
  }
}