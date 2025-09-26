/// Assumptions
/// - Riverpod is not currently available; using simple mock accessors instead.
/// - Replace with real repository/services when backend is available.
/// - Keep model lightweight and serializable-friendly.

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.progressPercent,
    this.isLocked = false,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final double progressPercent; // 0.0 - 1.0
  final bool isLocked;
}

/// TODO: Integrate authenticated user info
String getMockUserName() => 'Rohit';

/// Mock: Enrolled courses for the user
Future<List<Course>> getMockEnrolledCourses() async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  return const [
    Course(
      id: 'flutter_foundations',
      title: 'Flutter Foundations',
      thumbnailUrl: 'https://picsum.photos/seed/flutter_foundations/400/240',
      progressPercent: 0.62,
      isLocked: false,
    ),
    Course(
      id: 'dart_essentials',
      title: 'Dart Essentials',
      thumbnailUrl: 'https://picsum.photos/seed/dart_essentials/400/240',
      progressPercent: 0.35,
      isLocked: false,
    ),
    Course(
      id: 'ui_ux_basics',
      title: 'UI/UX Basics',
      thumbnailUrl: 'https://picsum.photos/seed/ui_ux_basics/400/240',
      progressPercent: 0.12,
      isLocked: true,
    ),
  ];
}


