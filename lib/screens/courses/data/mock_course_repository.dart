// ASSUMPTION: This mock repository simulates network calls with delays
// and returns canned data. Replace with RemoteCourseRepository later.

import 'dart:math';
import 'models/course.dart';
import 'models/module.dart';

/// CourseRepository interface (documented for swap-in)
/// Implementations should provide methods used by providers below.
abstract class CourseRepository {
  Future<List<Course>> getCourses({String? search, int page = 1});
  Future<Course> getCourseById(String id);
  Future<bool> enrollInCourse(String courseId);
  Future<bool> unenrollFromCourse(String courseId);
  Future<bool> purchaseCourse(String courseId);
}

class MockCourseRepository implements CourseRepository {
  MockCourseRepository();

  static final List<Course> _courses = _buildMockCourses();
  
  // Track enrollment state separately from subscription
  static final Set<String> _enrolledCourses = <String>{};
  static final Set<String> _purchasedCourses = <String>{};

  static List<Course> _buildMockCourses() {
    List<Course> list = [];
    for (int i = 1; i <= 3; i++) {
      final String id = 'c$i';
      final bool isSubscribed = i % 2 == 1 || _purchasedCourses.contains(id); // mix + purchased
      final modules = List<Module>.generate(4, (index) {
        final int num = index + 1;
        final bool locked = !isSubscribed && num > 1; // only first open if not subscribed
        final String videoUrl = i == 1 ? 'https://youtu.be/RFThBMUs3e0' :
                               i == 2 ? 'https://youtu.be/7MQe8B5n2t8' :
                               'https://youtu.be/loYQ4CkTngo';
        return Module.legacy(
          id: 'm${i}_$num',
          title: 'Module $num',
          durationSec: 600 + num * 120,
          isLocked: locked,
          videoUrl: videoUrl,
        );
      });
      final String courseTitle = i == 1 ? 'Flutter Development' : 
                            i == 2 ? 'Python Development' : 
                            'Java Programming';
      final String courseDescription = i == 1 ? 'Comprehensive Flutter development course with practical projects.' :
                                     i == 2 ? 'Complete Python development course from basics to advanced.' :
                                     'Complete Java programming course with hands-on coding.';
      
      list.add(Course.legacy(
        id: id,
        title: courseTitle,
        description: courseDescription,
        thumbnailUrl: 'https://picsum.photos/seed/$id/800/450',
        progressPercent: isSubscribed ? (0.15 * i).clamp(0, 1) : 0.0,
        isSubscribed: isSubscribed,
        isEnrolled: false, // Initially not enrolled
        modules: modules,
      ));
    }
    return list;
  }

  Duration _delay() => Duration(milliseconds: 700 + Random().nextInt(300));

  @override
  Future<List<Course>> getCourses({String? search, int page = 1}) async {
    await Future.delayed(_delay());
    Iterable<Course> data = _courses;
    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim().toLowerCase();
      data = data.where((c) => c.title.toLowerCase().contains(s));
    }
    // Pagination stub: return all; later slice by page.
    return data.toList(growable: false);
  }

  @override
  Future<Course> getCourseById(String id) async {
    await Future.delayed(_delay());
    try {
      final course = _courses.firstWhere((c) => c.id == id);
      // Compute dynamic purchase state
      final bool purchasedNow = course.isSubscribed || _purchasedCourses.contains(id);
      // If purchased, unlock all modules dynamically; else keep original lock state
      final List<Module> dynamicModules = course.modules
          .map((m) => Module(
                id: m.id,
                title: m.title,
                durationSec: m.durationSec,
                isLocked: purchasedNow ? false : m.isLocked,
                videos: m.videos, // Use the videos list instead of videoUrl
              ))
          .toList(growable: false);
      // Return course with updated enrollment and purchase status
      return Course.legacy(
        id: course.id,
        title: course.title,
        description: course.description,
        thumbnailUrl: course.thumbnailUrl,
        progressPercent: course.progressPercent,
        isSubscribed: purchasedNow, // Dynamic purchase status
        modules: dynamicModules,
        isEnrolled: _enrolledCourses.contains(id), // Dynamic enrollment status
      );
    } catch (_) {
      // Safe fallback to avoid UI crashes; return a lightweight placeholder
      return Course(
        id: id,
        title: 'Course',
        description: 'Details will be available soon.',
        thumbnailUrl: 'https://picsum.photos/seed/$id/800/450',
        progressPercent: 0.0,
        isSubscribed: false,
        modules: const <Module>[],
        isEnrolled: false,
      );
    }
  }

  @override
  Future<bool> enrollInCourse(String courseId) async {
    await Future.delayed(_delay());
    // Only allow enrollment if course is purchased (isSubscribed or purchased)
    final course = _courses.firstWhere((c) => c.id == courseId);
    final isPurchased = course.isSubscribed || _purchasedCourses.contains(courseId);
    if (isPurchased) {
      _enrolledCourses.add(courseId);
      return true;
    }
    return false; // Cannot enroll in unpurchased course
  }

  @override
  Future<bool> unenrollFromCourse(String courseId) async {
    await Future.delayed(_delay());
    _enrolledCourses.remove(courseId);
    return true;
  }

  @override
  Future<bool> purchaseCourse(String courseId) async {
    await Future.delayed(_delay());
    _purchasedCourses.add(courseId);
    // Auto-enroll user after purchase
    _enrolledCourses.add(courseId);
    return true;
  }
}


