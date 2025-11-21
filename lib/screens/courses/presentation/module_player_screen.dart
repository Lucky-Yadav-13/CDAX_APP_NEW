// ASSUMPTION: Simple player placeholder; integrate with real player later.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../application/course_providers.dart';
import '../../courses/data/models/module.dart';

import '../../../services/assessment_service.dart';
import '../../../models/assessment/assessment_model.dart';

class ModulePlayerScreen extends StatefulWidget {
  const ModulePlayerScreen({super.key, required this.courseId, required this.moduleId});
  final String courseId;
  final String moduleId;

  @override
  State<ModulePlayerScreen> createState() => _ModulePlayerScreenState();
}

class _ModulePlayerScreenState extends State<ModulePlayerScreen> {
  List<Assessment> _assessments = [];
  bool _assessmentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    final assessments = await AssessmentService.getModuleAssessments(
      courseId: widget.courseId,
      moduleId: widget.moduleId,
    );
    if (mounted) {
      setState(() {
        _assessments = assessments;
        _assessmentsLoading = false;
      });
    }
  }

  List<Assessment> _getAssessmentsWithModuleLockState(Module module) {
    // Assessment should be locked if ANY video in the module is locked (stricter policy)
    final bool hasLockedVideos = module.videos.any((video) => video.isLocked);
    final bool assessmentShouldBeLocked = module.isLocked || hasLockedVideos;
    
    print('🔒 Debug Assessment Lock State:');
    print('   Module: ${module.title} - isLocked: ${module.isLocked}');
    print('   Videos locked count: ${module.videos.where((v) => v.isLocked).length}/${module.videos.length}');
    print('   Has locked videos: $hasLockedVideos');
    print('   Assessment will be locked: $assessmentShouldBeLocked');
    
    final lockedAssessments = _assessments.map((assessment) {
      print('   Assessment: ${assessment.title} - will be locked: $assessmentShouldBeLocked');
      return Assessment(
        id: assessment.id,
        title: assessment.title,
        category: assessment.category,
        duration: assessment.duration,
        difficulty: assessment.difficulty,
        description: assessment.description,
        totalQuestions: assessment.totalQuestions,
        passingScore: assessment.passingScore,
        isActive: assessment.isActive,
        isLocked: assessmentShouldBeLocked, // Lock if module is locked OR any video is locked
      );
    }).toList();
    
    print('   Locked assessments count: ${lockedAssessments.length}');
    return lockedAssessments;
  }

  @override
  Widget build(BuildContext context) {
    // Get repository using factory
    final repo = CourseProviders.getCourseRepository();
    print('🎬 ModulePlayerScreen: Using ${repo.runtimeType} for course ${widget.courseId}, module ${widget.moduleId}');
    return FutureBuilder(
      future: repo.getCourseById(widget.courseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('Error: ${snapshot.error}')));
        }
        final course = snapshot.data;
        if (course == null) {
          return const Scaffold(body: Center(child: Text('Course not found')));
        }
        Module? module;
        for (final m in course.modules) {
          if (m.id == widget.moduleId) {
            module = m;
            break;
          }
        }
        module ??= course.modules.isNotEmpty ? course.modules.first : null;
        if (module == null) {
          return Scaffold(appBar: AppBar(title: const Text('Module')),
              body: const Center(child: Text('Module not found')));
        }
        // Save last played (mock)
        LastPlayedStore.instance.setLastPlayed(widget.courseId, widget.moduleId);
        
        // Make module non-null for the rest of the widget
        final currentModule = module;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(currentModule.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Navigate back to the course detail page
                context.go('/dashboard/courses/${widget.courseId}');
              },
            ),
          ),
          body: Column(
            children: [
              // Scrollable content area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Module title
                    Text(
                      currentModule.title, 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    

                    
                    // All videos in module - Multiple video support
                    ...currentModule.videos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final video = entry.value;
                      
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: GestureDetector(
                          onTap: () async {
                            // Block navigation if this video is locked for the user
                            if (video.isLocked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This lesson is locked. Purchase the course to access.')),
                              );
                              return;
                            }

                            // Use video URL from backend data
                            final url = video.youtubeUrl;
                            if (url.isNotEmpty) {
                              // ignore: use_build_context_synchronously
                              context.push('/dashboard/courses/${widget.courseId}/module/${widget.moduleId}/video?url=$url');
                            }
                          },
                          child: Row(
                            children: [
                              // Play icon - fixed size
                              Icon(
                                // show lock icon when the video is locked
                                video.isLocked ? Icons.lock : Icons.play_circle_filled,
                                color: video.isLocked ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4) : Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              // Video info - flexible to take available space
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Video title with fallback numbering
                                    Text(
                                      video.title.isNotEmpty 
                                        ? video.title 
                                        : 'Video ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    // Video-specific duration
                                    Text(
                                      video.durationSec > 0 
                                        ? '${(video.durationSec / 60).round()} min'
                                        : '${(currentModule.durationSec / 60).round()} min',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Navigation arrow - fixed size
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  video.isLocked ? Icons.lock_outline : Icons.play_arrow,
                                  color: video.isLocked ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    // Fallback if no videos exist
                    if (currentModule.videos.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: GestureDetector(
                          onTap: () async {
                            if (currentModule.isLocked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This lesson is locked. Purchase the course to access.')),
                              );
                              return;
                            }
                            final url = currentModule.videoUrl;
                            if (url.isNotEmpty) {
                              // ignore: use_build_context_synchronously
                              context.push('/dashboard/courses/${widget.courseId}/module/${widget.moduleId}/video?url=$url');
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                currentModule.isLocked ? Icons.lock : Icons.play_circle_filled,
                                color: currentModule.isLocked ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4) : Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Video 1',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${(currentModule.durationSec / 60).round()} min',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  currentModule.isLocked ? Icons.lock_outline : Icons.play_arrow,
                                  color: currentModule.isLocked ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Assessment section
                    if (!_assessmentsLoading && _assessments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Assessment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._getAssessmentsWithModuleLockState(currentModule).map((assessment) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            print('🎯 Assessment tap: ${assessment.title} - isLocked: ${assessment.isLocked}');
                            // Block navigation if this assessment is locked for the user
                            if (assessment.isLocked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This assessment is locked. Purchase the course to access.')),
                              );
                              return;
                            }
                            
                            // Navigate to assessment screen
                            print('🚀 Navigating to assessment: ${assessment.id}');
                            print('   📍 Course: ${widget.courseId}, Module: ${widget.moduleId}');
                            context.push('/dashboard/courses/${widget.courseId}/module/${widget.moduleId}/assessment/${assessment.id}');
                          },
                          child: Row(
                            children: [
                              // Assessment icon - fixed size, show lock when locked
                              Icon(
                                assessment.isLocked ? Icons.lock : Icons.quiz,
                                color: assessment.isLocked ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4) : Theme.of(context).colorScheme.secondary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              // Assessment info - flexible to take available space
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Assessment title
                                    Text(
                                      assessment.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    // Assessment details
                                    Text(
                                      '${assessment.totalQuestions} questions • ${assessment.duration} min',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Navigation arrow or lock icon - fixed size
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  assessment.isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
                                  color: assessment.isLocked ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                    
                    // Loading indicator for assessments
                    if (_assessmentsLoading) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Assessment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ],
                    
                    // Add some bottom padding to prevent content from being hidden behind the button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              // Fixed Next lesson button at bottom
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final modules = course.modules;
                        final idx = modules.indexWhere((m) => m.id == widget.moduleId);
                        if (idx >= 0 && idx < modules.length - 1) {
                          final next = modules[idx + 1];
                          if (!next.isLocked) {
                            // Use go_router for navigation
                            // ignore: use_build_context_synchronously
                            context.go('/dashboard/courses/${course.id}/module/${next.id}');
                          }
                        }
                      },
                      icon: Icon(
                        Icons.skip_next,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Next lesson',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


