// ASSUMPTION: Simple player placeholder; integrate with real player later.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../application/course_providers.dart';
import '../../courses/data/models/module.dart';
import '../../../services/mock_video_service.dart';

class ModulePlayerScreen extends StatelessWidget {
  const ModulePlayerScreen({super.key, required this.courseId, required this.moduleId});
  final String courseId;
  final String moduleId;

  @override
  Widget build(BuildContext context) {
    // Get repository using factory
    final repo = CourseProviders.getCourseRepository();
    print('🎬 ModulePlayerScreen: Using ${repo.runtimeType} for course $courseId, module $moduleId');
    return FutureBuilder(
      future: repo.getCourseById(courseId),
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
          if (m.id == moduleId) {
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
        LastPlayedStore.instance.setLastPlayed(courseId, moduleId);
        return Scaffold(
          appBar: AppBar(title: Text(module.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FutureBuilder<String>(
                future: MockVideoService.getModuleVideoUrl(courseId: courseId, moduleId: moduleId),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError || (snap.data ?? '').isEmpty) {
                    return const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: Text('Unable to load video')),
                    );
                  }
                  final url = snap.data!;
                  return FilledButton(
                    onPressed: () => context.push('/dashboard/courses/$courseId/module/$moduleId/video?url=$url'),
                    child: const Text('Watch Video'),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(module.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Lesson description placeholder. Replace with backend content.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final modules = course.modules;
                  final idx = modules.indexWhere((m) => m.id == moduleId);
                  if (idx >= 0 && idx < modules.length - 1) {
                    final next = modules[idx + 1];
                    if (!next.isLocked) {
                      // Use go_router for navigation
                      // ignore: use_build_context_synchronously
                      context.go('/dashboard/courses/${course.id}/module/${next.id}');
                    }
                  }
                },
                child: const Text('Next lesson'),
              ),
            ],
          ),
        );
      },
    );
  }
}


