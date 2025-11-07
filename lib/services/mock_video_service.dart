import '../screens/courses/application/course_providers.dart';

class MockVideoService {
  static Future<String> getCourseIntroUrl(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    try {
      // Get the actual course data from the repository (backend or mock)
      final repo = CourseProviders.getCourseRepository();
      print('🎬 MockVideoService: Getting intro URL for course $courseId using ${repo.runtimeType}');
      final course = await repo.getCourseById(courseId);
      
      // Return the first module's video URL as course intro
      if (course.modules.isNotEmpty) {
        return course.modules.first.videoUrl;
      }
    } catch (e) {
      // Fallback to demo video if anything goes wrong
    }
    
    // Free demo MP4 (samplelib). Replace with backend API later.
    return 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4';
  }

  static Future<String> getModuleVideoUrl({required String courseId, required String moduleId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    try {
      // Get the actual course data from the repository (backend or mock)
      final repo = CourseProviders.getCourseRepository();
      print('🎬 MockVideoService: Getting video URL for course $courseId, module $moduleId using ${repo.runtimeType}');
      final course = await repo.getCourseById(courseId);
      
      // Find the specific module
      final module = course.modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => course.modules.first,
      );
      
      // Return the actual video URL from the module
      return module.videoUrl;
    } catch (e) {
      // Fallback to demo video if anything goes wrong
      print('Error loading module video for courseId: $courseId, moduleId: $moduleId - $e');
      return 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4';
    }
  }
}


