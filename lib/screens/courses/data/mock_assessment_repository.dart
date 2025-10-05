import 'dart:math';

class McqQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  McqQuestion({required this.question, required this.options, required this.correctIndex});
}

class MockAssessmentRepository {
  const MockAssessmentRepository();

  Future<List<McqQuestion>> getMcqsForCourse(String courseId) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final random = Random(courseId.hashCode);
    // Generate 10 MCQs deterministically from courseId
    return List<McqQuestion>.generate(10, (i) {
      final base = random.nextInt(4);
      final opts = List<String>.generate(4, (j) => 'Option ${j + 1} for Q${i + 1}');
      return McqQuestion(
        question: 'Q${i + 1}: What is concept ${i + 1} in course $courseId?',
        options: opts,
        correctIndex: base % 4,
      );
    });
  }
}
