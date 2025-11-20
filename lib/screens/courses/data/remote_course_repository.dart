// Remote Course Repository for Spring Boot backend integration
// Implements the CourseRepository interface with HTTP calls

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'course_repository.dart';
import 'models/course.dart';
import 'models/module.dart';
import 'models/video.dart';

import '../../../models/assessment/question_model.dart';
import '../../../models/assessment/assessment_model.dart';

/// Remote implementation of CourseRepository that communicates with Spring Boot backend
class RemoteCourseRepository implements CourseRepository {
  final String baseUrl;
  final Duration timeout;
  
  RemoteCourseRepository({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  }) {
    print('🔗 RemoteCourseRepository initialized with baseUrl: $baseUrl');
  }

  @override
  Future<List<Course>> getCourses({String? search, int page = 1}) async {
    print('\n📡 Fetching courses from backend...');
    print('   ├─ Search: ${search ?? 'none'}');
    print('   ├─ Page: $page');
    print('   └─ URL: $baseUrl/api/courses');
    
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      
      final uri = Uri.parse('$baseUrl/api/courses').replace(queryParameters: queryParams);
      print('   🌐 Full request URL: $uri');
      
      // Make HTTP request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      print('   📨 Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('   ✅ Successfully received courses data');
        print('   📊 Response structure: ${jsonResponse.keys.toList()}');
        
        // Handle different response structures
        List<dynamic> coursesData = [];
        if (jsonResponse.containsKey('data')) {
          coursesData = jsonResponse['data'] as List;
        } else if (jsonResponse.containsKey('courses')) {
          coursesData = jsonResponse['courses'] as List;
        } else {
          // If response is not structured, try to find a list in values
          for (var value in jsonResponse.values) {
            if (value is List) {
              coursesData = value;
              break;
            }
          }
        }
        
        print('   📚 Found ${coursesData.length} courses in response');
        
        // Parse courses
        final List<Course> courses = coursesData.map((courseJson) {
          try {
            return Course.fromJson(courseJson);
          } catch (e) {
            print('   ⚠️ Error parsing course: $e');
            print('   📄 Problematic course data: $courseJson');
            rethrow;
          }
        }).toList();
        
        print('   🎓 Successfully parsed ${courses.length} courses');
        for (final course in courses) {
          int totalVideos = course.modules.fold(0, (sum, module) => sum + module.videos.length);
          print('   ├─ ${course.title}: ${course.modules.length} modules, $totalVideos videos');
        }

        // Apply client-side lock propagation so remote data matches mock behavior
        final List<Course> adjustedCourses = courses.map((c) => _applyLockingToCourse(c)).toList();

        return adjustedCourses;
      } else {
        print('   ❌ Backend returned error: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('   🚨 Error fetching courses from backend: $e');
      rethrow;
    }
  }

  @override
  Future<Course> getCourseById(String id) async {
    print('\n📡 Fetching course details from backend...');
    print('   ├─ Course ID: $id');
    print('   └─ URL: $baseUrl/api/courses/$id');
    
    try {
      final uri = Uri.parse('$baseUrl/api/courses/$id');
      print('   🌐 Full request URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('   ✅ Successfully received course details');
        
        // Handle different response structures
        Map<String, dynamic> courseData;
        if (jsonResponse.containsKey('data')) {
          courseData = jsonResponse['data'];
        } else if (jsonResponse.containsKey('course')) {
          courseData = jsonResponse['course'];
        } else {
          courseData = jsonResponse;
        }
        
        final Course course = Course.fromJson(courseData);
        int totalVideos = course.modules.fold(0, (sum, module) => sum + module.videos.length);
        print('   🎓 Course: ${course.title} (${course.modules.length} modules, $totalVideos videos)');

        // Apply client-side lock propagation so videos/modules respect purchase/subscription
        final Course adjusted = _applyLockingToCourse(course);
        return adjusted;
      } else {
        print('   ❌ Backend returned error: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('   🚨 Error fetching course details from backend: $e');
      rethrow;
    }
  }

  @override
  Future<bool> enrollInCourse(String courseId) async {
    print('\n📡 Enrolling in course via backend...');
    print('   ├─ Course ID: $courseId');
    print('   └─ URL: $baseUrl/api/courses/$courseId/enroll');
    
    try {
      final uri = Uri.parse('$baseUrl/api/courses/$courseId/enroll');
      print('   🌐 Full request URL: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when available
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'courseId': courseId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('   ✅ Successfully enrolled in course');
        print('   📄 Response: $jsonResponse');
        
        return jsonResponse['success'] == true || 
               jsonResponse['enrolled'] == true || 
               response.statusCode == 201;
      } else {
        print('   ❌ Backend enrollment failed: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend enrollment failed: ${response.statusCode}');
      }
    } catch (e) {
      print('   🚨 Error enrolling in course via backend: $e');
      rethrow;
    }
  }

  @override
  Future<bool> unenrollFromCourse(String courseId) async {
    print('\n📡 Unenrolling from course via backend...');
    print('   ├─ Course ID: $courseId');
    print('   └─ URL: $baseUrl/api/courses/$courseId/unenroll');
    
    try {
      final uri = Uri.parse('$baseUrl/api/courses/$courseId/unenroll');
      print('   🌐 Full request URL: $uri');
      
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when available
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('   ✅ Successfully unenrolled from course');
        return true;
      } else {
        print('   ❌ Backend unenrollment failed: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend unenrollment failed: ${response.statusCode}');
      }
    } catch (e) {
      print('   🚨 Error unenrolling from course via backend: $e');
      rethrow;
    }
  }

  @override
  Future<bool> purchaseCourse(String courseId) async {
    print('\n📡 Purchasing course via backend...');
    print('   ├─ Course ID: $courseId');
    print('   └─ URL: $baseUrl/api/courses/$courseId/purchase');
    
    try {
      final uri = Uri.parse('$baseUrl/api/courses/$courseId/purchase');
      print('   🌐 Full request URL: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when available
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'courseId': courseId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('   ✅ Successfully purchased course');
        print('   📄 Response: $jsonResponse');
        
        // Mark local mock fallback as purchased as well so client-side access works
        try {
          // Fallback removed - using backend only
        } catch (_) {}

        return jsonResponse['success'] == true || 
               jsonResponse['purchased'] == true || 
               response.statusCode == 201;
      } else {
        print('   ❌ Backend purchase failed: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend purchase failed: ${response.statusCode}');
      }
    } catch (e) {
      print('   🚨 Error purchasing course via backend: $e');
      rethrow;
    }
  }

  @override
  Future<List<Question>> getAssessmentQuestions(String assessmentId) async {
    print('\n📡 Fetching assessment questions from backend...');
    print('   ├─ Assessment ID: $assessmentId');
    print('   ├─ Assessment ID type: ${assessmentId.runtimeType}');
    print('   ├─ Base URL: $baseUrl');
    print('   └─ URL: $baseUrl/api/assessments/$assessmentId/questions');
    
    try {
      final uri = Uri.parse('$baseUrl/api/assessments/$assessmentId/questions');
      print('   🌐 Full request URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('   ✅ Successfully received questions data');
        
        // Handle different response structures
        List<dynamic> questionsData = [];
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          questionsData = jsonResponse['data'] as List;
        } else if (jsonResponse.containsKey('questions') && jsonResponse['questions'] is List) {
          questionsData = jsonResponse['questions'] as List;
        } else if (jsonResponse is List) {
          questionsData = jsonResponse as List;
        }
        
        print('   📋 Found ${questionsData.length} questions in response');
        
        // Parse questions
        final List<Question> questions = questionsData.map((questionJson) {
          try {
            return Question.fromJson(questionJson);
          } catch (e) {
            print('   ⚠️ Error parsing question: $e');
            print('   📄 Problematic question data: $questionJson');
            rethrow;
          }
        }).toList();
        
        print('   ❓ Successfully parsed ${questions.length} questions');
        
        return questions;
      } else {
        print('   ❌ Backend returned error: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('   🚨 Error fetching questions from backend: $e');
      rethrow;
    }
  }

  @override
  Future<List<Assessment>> getModuleAssessments(String moduleId) async {
    print('\n📡 Fetching module assessments from backend...');
    print('   ├─ Module ID: $moduleId');
    print('   └─ URL: $baseUrl/api/modules/$moduleId/assessments');
    
    try {
      final uri = Uri.parse('$baseUrl/api/modules/$moduleId/assessments');
      print('   🌐 Full request URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeout);
      
      print('   📨 Response status: ${response.statusCode}');
      print('   📄 Response body length: ${response.body.length}');
      print('   📄 Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      
      if (response.statusCode == 200) {
        final dynamic jsonDecoded = json.decode(response.body);
        print('   📊 Response type: ${jsonDecoded.runtimeType}');
        
        List<dynamic> jsonResponse = [];
        if (jsonDecoded is List) {
          jsonResponse = jsonDecoded;
        } else if (jsonDecoded is Map<String, dynamic>) {
          if (jsonDecoded.containsKey('data')) {
            jsonResponse = jsonDecoded['data'] as List;
          } else if (jsonDecoded.containsKey('questions')) {
            jsonResponse = jsonDecoded['questions'] as List;
          } else {
            print('   ⚠️ Unexpected response structure: ${jsonDecoded.keys}');
            jsonResponse = [];
          }
        }
        
        print('   ✅ Successfully received questions data');
        print('   📋 Found ${jsonResponse.length} questions in response');
        
        // Parse assessments
        final List<Assessment> assessments = jsonResponse.map((assessmentJson) {
          try {
            return Assessment.fromJson(assessmentJson);
          } catch (e) {
            print('   ⚠️ Error parsing assessment: $e');
            print('   📄 Problematic assessment data: $assessmentJson');
            rethrow;
          }
        }).toList();
        
        print('   📝 Successfully parsed ${assessments.length} assessments');
        
        return assessments;
      } else {
        print('   ❌ Backend returned error: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('   🚨 Error fetching assessments from backend: $e');
      rethrow;
    }
  }

  // Apply lock logic to a Course instance so remote data behaves like mock data.
  // Rules:
  // - If course.isSubscribed == true => all modules and videos unlocked.
  // - If not subscribed => only module at index 0 is unlocked; within an unlocked module
  //   only video at index 0 is unlocked. All other modules/videos are locked.
  Course _applyLockingToCourse(Course course) {
    final bool subscribed = course.isSubscribed;

    final modules = <Module>[];
    for (var mIndex = 0; mIndex < course.modules.length; mIndex++) {
      final m = course.modules[mIndex];
      final bool moduleLocked = !subscribed && mIndex > 0;

      final videos = <Video>[];
      for (var vIndex = 0; vIndex < m.videos.length; vIndex++) {
        final v = m.videos[vIndex];
        final bool videoLocked = subscribed ? false : (moduleLocked ? true : (vIndex != 0));

        videos.add(Video(
          id: v.id,
          title: v.title,
          description: v.description,
          youtubeUrl: v.youtubeUrl,
          durationSec: v.durationSec,
          orderIndex: v.orderIndex,
          thumbnailUrl: v.thumbnailUrl,
          isLocked: videoLocked,
          isCompleted: v.isCompleted,
        ));
      }

      modules.add(Module(
        id: m.id,
        title: m.title,
        description: m.description,
        durationSec: m.durationSec,
        isLocked: moduleLocked,
        orderIndex: m.orderIndex,
        videos: videos,
        // If module is locked, ensure its assessment is marked inactive so UI treats it as locked
        assessment: m.assessment != null
            ? Assessment(
                id: m.assessment!.id,
                title: m.assessment!.title,
                category: m.assessment!.category,
                duration: m.assessment!.duration,
                difficulty: m.assessment!.difficulty,
                description: m.assessment!.description,
                totalQuestions: m.assessment!.totalQuestions,
                passingScore: m.assessment!.passingScore,
                isActive: !moduleLocked,
              )
            : null,
      ));
    }

    return Course(
      id: course.id,
      title: course.title,
      description: course.description,
      thumbnailUrl: course.thumbnailUrl,
      progressPercent: course.progressPercent,
      isSubscribed: course.isSubscribed,
      isEnrolled: course.isEnrolled,
      modules: modules,
      instructor: course.instructor,
      rating: course.rating,
      studentsCount: course.studentsCount,
      category: course.category,
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
    );
  }
}