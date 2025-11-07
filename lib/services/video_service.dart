// Enhanced Video Service for Spring Boot backend integration
// Handles multiple videos per module and backend/mock fallback

import '../screens/courses/application/course_providers.dart';
import '../screens/courses/data/models/video.dart';

class VideoService {
  /// Get course intro video URL (first video of first module)
  static Future<String> getCourseIntroUrl(String courseId) async {
    print('\n🎬 VideoService: Getting intro URL for course $courseId');
    
    try {
      final repo = CourseProviders.getCourseRepository();
      final course = await repo.getCourseById(courseId);
      
      print('   ├─ Course found: ${course.title}');
      
      if (course.modules.isNotEmpty) {
        final firstModule = course.modules.first;
        print('   ├─ First module: ${firstModule.title}');
        
        if (firstModule.videos.isNotEmpty) {
          final introVideo = firstModule.videos.first;
          print('   ├─ Intro video: ${introVideo.title}');
          print('   └─ YouTube URL: ${introVideo.youtubeUrl}');
          return introVideo.youtubeUrl;
        } else {
          // Fallback to legacy videoUrl if no videos list
          print('   ├─ No videos in module, using legacy videoUrl');
          print('   └─ Legacy URL: ${firstModule.videoUrl}');
          return firstModule.videoUrl;
        }
      }
      
      print('   ⚠️ No modules found in course');
    } catch (e) {
      print('   🚨 Error getting course intro: $e');
    }
    
    // Ultimate fallback
    print('   🔄 Using fallback demo video');
    return 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4';
  }

  /// Get specific video URL by video ID within a module
  static Future<String> getVideoUrl({
    required String courseId,
    required String moduleId,
    required String videoId,
  }) async {
    print('\n🎬 VideoService: Getting video URL');
    print('   ├─ Course: $courseId');
    print('   ├─ Module: $moduleId');
    print('   └─ Video: $videoId');
    
    try {
      final repo = CourseProviders.getCourseRepository();
      final course = await repo.getCourseById(courseId);
      
      // Find the specific module
      final module = course.modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => course.modules.first,
      );
      
      print('   ├─ Module found: ${module.title}');
      
      // Find the specific video
      if (module.videos.isNotEmpty) {
        final video = module.videos.firstWhere(
          (v) => v.id == videoId,
          orElse: () => module.videos.first,
        );
        
        print('   ├─ Video found: ${video.title}');
        print('   └─ YouTube URL: ${video.youtubeUrl}');
        return video.youtubeUrl;
      } else {
        // Fallback to legacy videoUrl
        print('   ├─ No videos in module, using legacy videoUrl');
        print('   └─ Legacy URL: ${module.videoUrl}');
        return module.videoUrl;
      }
    } catch (e) {
      print('   🚨 Error getting video URL: $e');
    }
    
    // Ultimate fallback
    print('   🔄 Using fallback demo video');
    return 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4';
  }

  /// Get module video URL (first video in the module) - for backward compatibility
  static Future<String> getModuleVideoUrl({
    required String courseId,
    required String moduleId,
  }) async {
    print('\n🎬 VideoService: Getting module video URL (legacy method)');
    print('   ├─ Course: $courseId');
    print('   └─ Module: $moduleId');
    
    try {
      final repo = CourseProviders.getCourseRepository();
      final course = await repo.getCourseById(courseId);
      
      // Find the specific module
      final module = course.modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => course.modules.first,
      );
      
      print('   ├─ Module found: ${module.title}');
      
      if (module.videos.isNotEmpty) {
        final firstVideo = module.videos.first;
        print('   ├─ First video: ${firstVideo.title}');
        print('   └─ YouTube URL: ${firstVideo.youtubeUrl}');
        return firstVideo.youtubeUrl;
      } else {
        // Fallback to legacy videoUrl
        print('   ├─ No videos in module, using legacy videoUrl');
        print('   └─ Legacy URL: ${module.videoUrl}');
        return module.videoUrl;
      }
    } catch (e) {
      print('   🚨 Error getting module video URL: $e');
    }
    
    // Ultimate fallback
    print('   🔄 Using fallback demo video');
    return 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4';
  }

  /// Get all videos for a specific module
  static Future<List<Video>> getModuleVideos({
    required String courseId,
    required String moduleId,
  }) async {
    print('\n🎬 VideoService: Getting all videos for module');
    print('   ├─ Course: $courseId');
    print('   └─ Module: $moduleId');
    
    try {
      final repo = CourseProviders.getCourseRepository();
      final course = await repo.getCourseById(courseId);
      
      // Find the specific module
      final module = course.modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => course.modules.first,
      );
      
      print('   ├─ Module found: ${module.title}');
      print('   ├─ Videos count: ${module.videos.length}');
      
      for (int i = 0; i < module.videos.length; i++) {
        final video = module.videos[i];
        print('   │  ├─ Video ${i + 1}: ${video.title}');
        print('   │  └─ URL: ${video.youtubeUrl}');
      }
      
      return module.videos;
    } catch (e) {
      print('   🚨 Error getting module videos: $e');
      return [];
    }
  }
}