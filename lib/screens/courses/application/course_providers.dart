// Enhanced course providers with Spring Boot backend integration
// Automatically uses remote repository with mock fallback

import '../../../factories/course_repository_factory.dart';
import '../data/mock_course_repository.dart' show CourseRepository;
export '../data/mock_course_repository.dart' show CourseRepository;

/// Course provider utilities for backend integration
class CourseProviders {
  /// Get the configured course repository instance
  /// Returns RemoteCourseRepository (with mock fallback) or MockCourseRepository
  static CourseRepository getCourseRepository() {
    final repo = CourseRepositoryFactory.getInstance();
    print('📚 Using repository type: ${CourseRepositoryFactory.getRepositoryType()}');
    return repo;
  }
}

/// Simple last-played store without external dependencies; can be swapped for provider later.
class LastPlayedStore {
  LastPlayedStore._();
  static final LastPlayedStore instance = LastPlayedStore._();
  final Map<String, String?> _courseToModule = <String, String?>{};

  void setLastPlayed(String courseId, String moduleId) {
    _courseToModule[courseId] = moduleId;
  }

  String? lastForCourse(String courseId) => _courseToModule[courseId];
}


