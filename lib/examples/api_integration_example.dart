// API Integration Example for Home Screen
// This file demonstrates how to integrate the Spring Boot API with your existing home screen
// 
// INTEGRATION STEPS:
// 1. Add this to your existing home screen
// 2. Replace the existing hardcoded data with API calls
// 3. Update your providers to use the new services
// 4. Test with your actual API endpoints

import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../widgets/loading/skeleton_loader.dart';
import '../widgets/animations/staggered_list_animation.dart';

class ApiIntegrationExample extends StatefulWidget {
  const ApiIntegrationExample({super.key});

  @override
  State<ApiIntegrationExample> createState() => _ApiIntegrationExampleState();
}

class _ApiIntegrationExampleState extends State<ApiIntegrationExample> {
  final CourseService _courseService = CourseService();
  
  List<Course> featuredCourses = [];
  List<Course> popularCourses = [];
  bool isLoading = true;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      // Load featured courses
      final featuredResponse = await _courseService.getFeaturedCourses();
      if (featuredResponse.isSuccess) {
        featuredCourses = featuredResponse.data ?? [];
      } else {
        throw Exception(featuredResponse.error ?? 'Failed to load featured courses');
      }
      
      // Load popular courses
      final popularResponse = await _courseService.getPopularCourses();
      if (popularResponse.isSuccess) {
        popularCourses = popularResponse.data ?? [];
      } else {
        throw Exception(popularResponse.error ?? 'Failed to load popular courses');
      }
      
      setState(() {
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CDAX Learning Platform'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Continue your learning journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Featured Courses Section
              _buildFeaturedCoursesSection(),
              
              const SizedBox(height: 24),
              
              // Popular Courses Section
              _buildPopularCoursesSection(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeaturedCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Courses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _buildHorizontalCourseList(featuredCourses),
        ),
      ],
    );
  }
  
  Widget _buildPopularCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Courses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildVerticalCourseList(popularCourses),
      ],
    );
  }
  
  Widget _buildHorizontalCourseList(List<Course> courses) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Error loading courses',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (isLoading) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SkeletonLayouts.courseCard(),
          );
        },
      );
    }
    
    if (courses.isEmpty) {
      return const Center(
        child: Text('No featured courses available'),
      );
    }
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return StaggeredListAnimation(
          index: index,
          child: _buildCourseCard(courses[index]),
        );
      },
    );
  }
  
  Widget _buildVerticalCourseList(List<Course> courses) {
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text(
                'Error loading courses',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _initializeData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (isLoading) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonLayouts.courseCard(),
          ),
        ),
      );
    }
    
    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text('No popular courses available'),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: courses.asMap().entries.map((entry) {
          return StaggeredListAnimation(
            index: entry.key,
            child: _buildVerticalCourseCard(entry.value),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildCourseCard(Course course) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(course.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading error
                },
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course.instructor,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '₹${course.price}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVerticalCourseCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Course Image
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(course.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading error
                },
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructor,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '₹${course.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// INTEGRATION GUIDE:
/// 
/// 1. UPDATE YOUR EXISTING HOME SCREEN:
///    - Import the CourseService and AuthService
///    - Replace hardcoded data with API calls
///    - Add loading and error states
/// 
/// 2. UPDATE YOUR PROVIDER (if using Provider pattern):
///    ```dart
///    class CourseProvider with ChangeNotifier {
///      final CourseService _courseService = CourseService();
///      List<Course> _courses = [];
///      bool _isLoading = false;
///      
///      Future<void> loadCourses() async {
///        _isLoading = true;
///        notifyListeners();
///        
///        final response = await _courseService.getFeaturedCourses();
///        if (response.isSuccess) {
///          _courses = response.data ?? [];
///        }
///        
///        _isLoading = false;
///        notifyListeners();
///      }
///    }
///    ```
/// 
/// 3. UPDATE API CONFIGURATION:
///    - Go to lib/config/app_config.dart
///    - Replace 'YOUR_SPRING_BOOT_API_URL' with your actual API URL
///    - Update environment configs if needed
/// 
/// 4. ADD DEPENDENCIES TO PUBSPEC.YAML:
///    ```yaml
///    dependencies:
///      http: ^1.1.0
///      shared_preferences: ^2.2.2
///    ```
/// 
/// 5. INITIALIZE SERVICES IN MAIN.DART:
///    ```dart
///    void main() async {
///      WidgetsFlutterBinding.ensureInitialized();
///      
///      // Initialize services
///      await StorageService().initialize();
///      HttpService().initialize();
///      await AuthService().initialize();
///      
///      runApp(MyApp());
///    }
///    ```