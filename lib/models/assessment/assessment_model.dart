class Assessment {
  final String id;
  final String title;
  final String category;
  final int duration; // in minutes
  final String difficulty;
  final String description;
  final int totalQuestions;
  final int passingScore;
  final bool isActive;
  final bool isLocked;

  const Assessment({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.description,
    required this.totalQuestions,
    required this.passingScore,
    this.isActive = true,
    this.isLocked = false,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      duration: json['duration'] ?? 30, // Default 30 minutes
      difficulty: json['difficulty']?.toString() ?? 'Medium',
      description: json['description']?.toString() ?? '',
      totalQuestions: json['total_questions'] ?? json['totalQuestions'] ?? 0,
      passingScore: json['passing_score'] ?? json['passingScore'] ?? json['totalMarks'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      isLocked: json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'totalMarks': passingScore, // Backend expects totalMarks
      'category': category,
      'duration': duration,
      'difficulty': difficulty,
      'description': description,
      'total_questions': totalQuestions,
      'passing_score': passingScore,
      'is_active': isActive,
      'isLocked': isLocked,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assessment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
