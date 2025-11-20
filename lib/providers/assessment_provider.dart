import 'package:flutter/foundation.dart';
import '../models/assessment/assessment_model.dart';
import '../models/assessment/question_model.dart';
import '../services/assessment_service.dart';

class AssessmentProvider extends ChangeNotifier {
  // Using AssessmentService which uses backend repository
  
  // State variables
  List<Assessment> _assessments = [];
  List<Question> _currentQuestions = [];
  final Map<String, UserAnswer> _userAnswers = {};
  Assessment? _currentAssessment;
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  DateTime? _assessmentStartTime;
  
  // Timer state
  Duration _remainingTime = Duration.zero;
  bool _isTimerRunning = false;
  
  // Getters
  List<Assessment> get assessments => List.unmodifiable(_assessments);
  List<Question> get currentQuestions => List.unmodifiable(_currentQuestions);
  Map<String, UserAnswer> get userAnswers => Map.unmodifiable(_userAnswers);
  Assessment? get currentAssessment => _currentAssessment;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Duration get remainingTime => _remainingTime;
  bool get isTimerRunning => _isTimerRunning;
  DateTime? get assessmentStartTime => _assessmentStartTime;
  
  // Computed getters
  Question? get currentQuestion => 
      _currentQuestions.isNotEmpty && _currentQuestionIndex < _currentQuestions.length
          ? _currentQuestions[_currentQuestionIndex]
          : null;
  
  int get totalQuestions => _currentQuestions.length;
  
  double get progress => 
      totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;
  
  int get answeredCount => _userAnswers.length;
  
  bool get hasNextQuestion => _currentQuestionIndex < totalQuestions - 1;
  
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;
  
  bool get isCurrentQuestionAnswered => 
      currentQuestion != null && _userAnswers.containsKey(currentQuestion!.id);

  /// Load all available assessments
  Future<void> loadAssessments() async {
    _setLoading(true);
    _clearError();
    
    try {
      // For now, return empty list until backend provides assessment list endpoint
      _assessments = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to load assessments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Start a specific assessment
  Future<void> startAssessment(String assessmentId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Find the assessment
      _currentAssessment = _assessments.firstWhere(
        (a) => a.id == assessmentId,
        orElse: () => throw Exception('Assessment not found'),
      );
      
      // Load questions
      _currentQuestions = await AssessmentService.getAssessmentQuestions(assessmentId: assessmentId);
      
      // Reset state
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _assessmentStartTime = DateTime.now();
      
      // Start timer
      _remainingTime = Duration(minutes: _currentAssessment!.duration);
      _isTimerRunning = true;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to start assessment: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Submit answer for current question
  void submitAnswer(dynamic answer) {
    if (currentQuestion == null) return;
    
    final userAnswer = UserAnswer(
      questionId: currentQuestion!.id,
      answer: answer,
      timestamp: DateTime.now(),
    );
    
    _userAnswers[currentQuestion!.id] = userAnswer;
    notifyListeners();
  }

  /// Navigate to next question
  void goToNextQuestion() {
    if (hasNextQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Navigate to previous question
  void goToPreviousQuestion() {
    if (hasPreviousQuestion) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Navigate to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Update timer (called externally by timer)
  void updateTimer(Duration newRemainingTime) {
    _remainingTime = newRemainingTime;
    
    // Auto-submit when time runs out
    if (_remainingTime.inSeconds <= 0 && _isTimerRunning) {
      _isTimerRunning = false;
      // Timer expiry will be handled by the UI
    }
    
    notifyListeners();
  }

  /// Stop the timer
  void stopTimer() {
    _isTimerRunning = false;
    notifyListeners();
  }

  /// Reset assessment state
  void resetAssessment() {
    _currentAssessment = null;
    _currentQuestions.clear();
    _userAnswers.clear();
    _currentQuestionIndex = 0;
    _assessmentStartTime = null;
    _remainingTime = Duration.zero;
    _isTimerRunning = false;
    _clearError();
    notifyListeners();
  }

  /// Get answer for specific question
  UserAnswer? getAnswerForQuestion(String questionId) {
    return _userAnswers[questionId];
  }

  /// Check if all questions are answered
  bool get areAllQuestionsAnswered => 
      _userAnswers.length == _currentQuestions.length;

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isTimerRunning = false;
    super.dispose();
  }
}
