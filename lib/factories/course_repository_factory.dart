// Course Repository Factory
// Automatically chooses between remote and mock repository based on configuration

import 'package:flutter/foundation.dart';
import 'dart:developer';
import '../screens/courses/data/course_repository.dart';
import '../screens/courses/data/remote_course_repository.dart';
import '../config/backend_config.dart';

/// Factory class to provide the appropriate CourseRepository implementation
/// Automatically switches between remote backend and mock data based on configuration
class CourseRepositoryFactory {
  static CourseRepository? _instance;
  
  /// Get the singleton instance of CourseRepository
  /// Returns RemoteCourseRepository configured with backend
  static CourseRepository getInstance() {
    if (_instance != null) return _instance!;
    
    if (kDebugMode) {
      debugPrint('\n🏭 CourseRepositoryFactory: Creating repository instance...');
    }
    
    if (kDebugMode) {
      debugPrint('   ├─ Creating RemoteCourseRepository');
      debugPrint('   ├─ Base URL: ${BackendConfig.baseUrl}');
      debugPrint('   └─ Timeout: ${BackendConfig.requestTimeout}');
    }
    
    _instance = RemoteCourseRepository(
      baseUrl: BackendConfig.baseUrl,
      timeout: BackendConfig.requestTimeout,
    );
    
    return _instance!;
  }
  
  /// Force recreate the repository instance (useful for testing or config changes)
  static void reset() {
    log('🔄 CourseRepositoryFactory: Resetting repository instance');
    _instance = null;
  }
  
  /// Get repository type for debugging
  static String getRepositoryType() {
    return 'Remote';
  }
}