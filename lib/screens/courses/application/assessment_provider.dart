import 'package:flutter/foundation.dart';

class AssessmentProvider extends ChangeNotifier {
  AssessmentProvider();

  int _currentIndex = 0;
  final Map<int, int> _answers = <int, int>{}; // questionIndex -> selectedOptionIndex
  int _score = 0;
  bool _isSubmitting = false;

  int get currentIndex => _currentIndex;
  Map<int, int> get answers => Map.unmodifiable(_answers);
  int get score => _score;
  bool get isSubmitting => _isSubmitting;

  void resetAttempt() {
    _currentIndex = 0;
    _answers.clear();
    _score = 0;
    _isSubmitting = false;
    notifyListeners();
  }

  void submitAnswer({required int questionIndex, required int selectedOptionIndex}) {
    _answers[questionIndex] = selectedOptionIndex;
    notifyListeners();
  }

  void goToNextQuestion(int total) {
    if (_currentIndex < total - 1) {
      _currentIndex += 1;
      notifyListeners();
    }
  }

  void goToPrevQuestion() {
    if (_currentIndex > 0) {
      _currentIndex -= 1;
      notifyListeners();
    }
  }

  Future<int> computeScore({required List<int> correctOptionIndexes}) async {
    _isSubmitting = true;
    notifyListeners();
    // Simulate async scoring
    await Future<void>.delayed(const Duration(milliseconds: 400));
    int sum = 0;
    for (int i = 0; i < correctOptionIndexes.length; i++) {
      final selected = _answers[i];
      if (selected != null && selected == correctOptionIndexes[i]) {
        sum += 1;
      }
    }
    _score = sum;
    _isSubmitting = false;
    notifyListeners();
    return _score;
  }
}
