// Remote Course Repository for Spring Boot backend integration
// Implements the CourseRepository interface with HTTP calls
// Falls back to MockCourseRepository on any error

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/course.dart';
import 'mock_course_repository.dart';

/// Remote implementation of CourseRepository that communicates with Spring Boot backend
/// Automatically falls back to mock data if backend is unavailable
class RemoteCourseRepository implements CourseRepository {
  final String baseUrl;
  final MockCourseRepository _fallbackRepository;
  final Duration timeout;
  
  RemoteCourseRepository({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  }) : _fallbackRepository = MockCourseRepository() {
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
        
        return courses;
      } else {
        print('   ❌ Backend returned error: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('   🚨 Error fetching courses from backend: $e');
      print('   🔄 Falling back to mock data...');
      
      // Fallback to mock repository
      return await _fallbackRepository.getCourses(search: search, page: page);
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
        
        return course;
      } else {
        print('   ❌ Backend returned error: ${response.statusCode}');
        print('   📄 Error response: ${response.body}');
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('   🚨 Error fetching course details from backend: $e');
      print('   🔄 Falling back to mock data...');
      
      // Fallback to mock repository
      return await _fallbackRepository.getCourseById(id);
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
      print('   🔄 Falling back to mock enrollment...');
      
      // Fallback to mock repository
      return await _fallbackRepository.enrollInCourse(courseId);
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
      print('   🔄 Falling back to mock unenrollment...');
      
      // Fallback to mock repository
      return await _fallbackRepository.unenrollFromCourse(courseId);
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
      print('   🔄 Falling back to mock purchase...');
      
      // Fallback to mock repository
      return await _fallbackRepository.purchaseCourse(courseId);
    }
  }
}