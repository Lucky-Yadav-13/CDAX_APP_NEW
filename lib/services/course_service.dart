// Course Service
// Handles all course-related API operations
import '../constants/api_endpoints.dart';
import 'http_service.dart';

class CourseService {
  final HttpService _httpService = HttpService();
  
  // Get all courses
  Future<ApiResponse<List<Course>>> getAllCourses({
    int page = 0,
    int size = 20,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      
      return await _httpService.get<List<Course>>(
        ApiEndpoints.allCourses,
        (data) => (data['content'] as List)
            .map((item) => Course.fromJson(item))
            .toList(),
        queryParams: queryParams,
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch courses: ${e.toString()}');
    }
  }
  
  // Get featured courses
  Future<ApiResponse<List<Course>>> getFeaturedCourses() async {
    try {
      return await _httpService.get<List<Course>>(
        ApiEndpoints.featuredCourses,
        (data) => (data as List)
            .map((item) => Course.fromJson(item))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch featured courses: ${e.toString()}');
    }
  }
  
  // Get popular courses
  Future<ApiResponse<List<Course>>> getPopularCourses() async {
    try {
      return await _httpService.get<List<Course>>(
        ApiEndpoints.popularCourses,
        (data) => (data as List)
            .map((item) => Course.fromJson(item))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch popular courses: ${e.toString()}');
    }
  }
  
  // Get course details
  Future<ApiResponse<Course>> getCourseDetails(String courseId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseDetails,
        {'id': courseId},
      );
      
      return await _httpService.get<Course>(
        endpoint,
        (data) => Course.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch course details: ${e.toString()}');
    }
  }
  
  // Get course content
  Future<ApiResponse<CourseContent>> getCourseContent(String courseId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseContent,
        {'id': courseId},
      );
      
      return await _httpService.get<CourseContent>(
        endpoint,
        (data) => CourseContent.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch course content: ${e.toString()}');
    }
  }
  
  // Enroll in course
  Future<ApiResponse<Map<String, dynamic>>> enrollCourse(String courseId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseEnroll,
        {'id': courseId},
      );
      
      return await _httpService.post<Map<String, dynamic>>(
        endpoint,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse.error('Failed to enroll in course: ${e.toString()}');
    }
  }
  
  // Get user's enrolled courses
  Future<ApiResponse<List<Course>>> getUserCourses() async {
    try {
      return await _httpService.get<List<Course>>(
        ApiEndpoints.userCourses,
        (data) => (data as List)
            .map((item) => Course.fromJson(item))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch user courses: ${e.toString()}');
    }
  }
  
  // Get course progress
  Future<ApiResponse<CourseProgress>> getCourseProgress(String courseId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseProgress,
        {'id': courseId},
      );
      
      return await _httpService.get<CourseProgress>(
        endpoint,
        (data) => CourseProgress.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch course progress: ${e.toString()}');
    }
  }
  
  // Update course progress
  Future<ApiResponse<Map<String, dynamic>>> updateCourseProgress({
    required String courseId,
    required String lessonId,
    required double progressPercentage,
    bool completed = false,
  }) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseProgress,
        {'id': courseId},
      );
      
      return await _httpService.post<Map<String, dynamic>>(
        endpoint,
        (data) => data as Map<String, dynamic>,
        body: {
          'lessonId': lessonId,
          'progressPercentage': progressPercentage,
          'completed': completed,
        },
      );
    } catch (e) {
      return ApiResponse.error('Failed to update course progress: ${e.toString()}');
    }
  }
  
  // Get course reviews
  Future<ApiResponse<List<CourseReview>>> getCourseReviews(String courseId) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseReviews,
        {'id': courseId},
      );
      
      return await _httpService.get<List<CourseReview>>(
        endpoint,
        (data) => (data as List)
            .map((item) => CourseReview.fromJson(item))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch course reviews: ${e.toString()}');
    }
  }
  
  // Add course review
  Future<ApiResponse<CourseReview>> addCourseReview({
    required String courseId,
    required int rating,
    required String comment,
  }) async {
    try {
      final endpoint = ApiEndpoints.replacePathParams(
        ApiEndpoints.courseReviews,
        {'id': courseId},
      );
      
      return await _httpService.post<CourseReview>(
        endpoint,
        (data) => CourseReview.fromJson(data),
        body: {
          'rating': rating,
          'comment': comment,
        },
      );
    } catch (e) {
      return ApiResponse.error('Failed to add course review: ${e.toString()}');
    }
  }
  
  // Get course categories
  Future<ApiResponse<List<CourseCategory>>> getCourseCategories() async {
    try {
      return await _httpService.get<List<CourseCategory>>(
        ApiEndpoints.courseCategories,
        (data) => (data as List)
            .map((item) => CourseCategory.fromJson(item))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch course categories: ${e.toString()}');
    }
  }
}

// Placeholder model classes - replace with your actual models
class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final double price;
  final double rating;
  final int duration;
  final String imageUrl;
  
  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.price,
    required this.rating,
    required this.duration,
    required this.imageUrl,
  });
  
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class CourseContent {
  final String courseId;
  final List<Lesson> lessons;
  
  CourseContent({
    required this.courseId,
    required this.lessons,
  });
  
  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      courseId: json['courseId'] ?? '',
      lessons: (json['lessons'] as List? ?? [])
          .map((item) => Lesson.fromJson(item))
          .toList(),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String type;
  final int duration;
  final String? videoUrl;
  final String? content;
  
  Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    this.videoUrl,
    this.content,
  });
  
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      duration: json['duration'] ?? 0,
      videoUrl: json['videoUrl'],
      content: json['content'],
    );
  }
}

class CourseProgress {
  final String courseId;
  final double progressPercentage;
  final int completedLessons;
  final int totalLessons;
  final DateTime lastAccessed;
  
  CourseProgress({
    required this.courseId,
    required this.progressPercentage,
    required this.completedLessons,
    required this.totalLessons,
    required this.lastAccessed,
  });
  
  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] ?? '',
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      completedLessons: json['completedLessons'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0,
      lastAccessed: DateTime.tryParse(json['lastAccessed'] ?? '') ?? DateTime.now(),
    );
  }
}

class CourseReview {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  
  CourseReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
  
  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class CourseCategory {
  final String id;
  final String name;
  final String icon;
  
  CourseCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
  
  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}