// Course Repository Factory
// Automatically chooses between remote and mock repository based on configuration

import '../screens/courses/data/mock_course_repository.dart';
import '../screens/courses/data/remote_course_repository.dart';
import '../config/backend_config.dart';

/// Factory class to provide the appropriate CourseRepository implementation
/// Automatically switches between remote backend and mock data based on configuration
class CourseRepositoryFactory {
  static CourseRepository? _instance;
  
  /// Get the singleton instance of CourseRepository
  /// Returns RemoteCourseRepository if backend is configured, otherwise MockCourseRepository
  static CourseRepository getInstance() {
    if (_instance != null) return _instance!;
    
    print('\n🏭 CourseRepositoryFactory: Creating repository instance...');
    
    // Check if backend should be used
    if (BackendConfig.shouldUseBackend && BackendConfig.validateConfig()) {
      print('   ├─ Backend is configured and enabled');
      print('   ├─ Base URL: ${BackendConfig.baseUrl}');
      print('   └─ Creating RemoteCourseRepository with fallback to mock');
      
      _instance = RemoteCourseRepository(
        baseUrl: BackendConfig.baseUrl,
        timeout: BackendConfig.requestTimeout,
      );
    } else {
      print('   ├─ Backend is not configured or disabled');
      print('   └─ Creating MockCourseRepository');
      
      _instance = MockCourseRepository();
    }
    
    return _instance!;
  }
  
  /// Force recreate the repository instance (useful for testing or config changes)
  static void reset() {
    print('🔄 CourseRepositoryFactory: Resetting repository instance');
    _instance = null;
  }
  
  /// Get repository type for debugging
  static String getRepositoryType() {
    final repo = getInstance();
    if (repo is RemoteCourseRepository) {
      return 'Remote (with Mock fallback)';
    } else {
      return 'Mock';
    }
  }
}