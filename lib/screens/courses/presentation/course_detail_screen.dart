// ASSUMPTION: Local enroll toggle only; backend integration later.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../application/course_providers.dart';
import '../../courses/presentation/module_row.dart';
import '../../courses/data/models/module.dart';
import '../../../providers/subscription_provider.dart';


class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final CourseRepository _repo;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize repository using factory
    _repo = CourseProviders.getCourseRepository();
    print('📖 CourseDetailScreen: Initialized with ${_repo.runtimeType} for course ${widget.courseId}');
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourse = _repo.getCourseById(widget.courseId);
    final theme = Theme.of(context);
    return FutureBuilder(
      future: asyncCourse,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('Error: ${snapshot.error}')));
        }
        final course = snapshot.data;
        if (course == null) {
          return const Scaffold(
            body: Center(child: Text('Course not found')),
          );
        }
        final bool enrolled = course.isEnrolled;
        return Scaffold(
          appBar: AppBar(title: Text(course.title)),
          body: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Module? firstUnlocked;
                  for (final m in course.modules) {
                    if (!m.isLocked) {
                      firstUnlocked = m;
                      break;
                    }
                  }
                  firstUnlocked ??= course.modules.isNotEmpty ? course.modules.first : null;
                  if (firstUnlocked != null) {
                  context.go('/dashboard/courses/${course.id}/module/${firstUnlocked.id}');
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(course.thumbnailUrl, fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(course.description),
                    const SizedBox(height: 12),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                    Row(
                      children: [
                             // Only show Enroll button if course is purchased but not enrolled
                             if (course.isSubscribed && !enrolled)
                               Expanded(
                                 child: FilledButton(
                                   onPressed: () async {
                                     try {
                                       final success = await _repo.enrollInCourse(course.id);
                                       if (mounted) {
                                         if (success) {
                                           // ignore: use_build_context_synchronously
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             const SnackBar(
                                               content: Text('Successfully enrolled in course!'),
                                               backgroundColor: Colors.green,
                                             ),
                                           );
                                           setState(() {}); // Refresh to show updated state
                                         } else {
                                           // ignore: use_build_context_synchronously
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             const SnackBar(
                                               content: Text('Cannot enroll in unpurchased course'),
                                               backgroundColor: Colors.red,
                                             ),
                                           );
                                         }
                                       }
                                     } catch (e) {
                                       if (mounted) {
                                         // ignore: use_build_context_synchronously
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(
                                             content: Text('Failed to enroll. Please try again.'),
                                             backgroundColor: Colors.red,
                                           ),
                                         );
                                       }
                                     }
                                   },
                                   child: const Text('Enroll'),
                                 ),
                               ),
                             // Only show Unenroll button if enrolled
                             if (enrolled)
                               Expanded(
                                 child: FilledButton.tonal(
                                   onPressed: () async {
                                     try {
                                       final success = await _repo.unenrollFromCourse(course.id);
                                       if (mounted) {
                                         if (success) {
                                           // ignore: use_build_context_synchronously
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             const SnackBar(
                                               content: Text('Successfully unenrolled from course'),
                                               backgroundColor: Colors.orange,
                                             ),
                                           );
                                           setState(() {}); // Refresh to show updated state
                                         } else {
                                           // ignore: use_build_context_synchronously
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             const SnackBar(
                                               content: Text('Failed to unenroll. Please try again.'),
                                               backgroundColor: Colors.red,
                                             ),
                                           );
                                         }
                                       }
                                     } catch (e) {
                                       if (mounted) {
                                         // ignore: use_build_context_synchronously
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(
                                             content: Text('Failed to unenroll. Please try again.'),
                                             backgroundColor: Colors.red,
                                           ),
                                         );
                                       }
                                     }
                                   },
                                   child: const Text('Unenroll'),
                                 ),
                               ),
                             const SizedBox(width: 8),
                             // Only show Buy Course button for unpurchased courses
                             if (!course.isSubscribed)
                               Expanded(
                                 child: FilledButton.tonal(
                                   onPressed: () {
                                     // Prepare purchase context for this course
                                     SubscriptionController.instance.setPurchaseContext(
                                       courseId: course.id,
                                       title: course.title,
                                       amount: 399.0,
                                     );
                                     // Navigate to order summary first
                                     context.push('/dashboard/subscription/summary');
                                   },
                                   child: const Text('Buy course'),
                                 ),
                               ),
                           ],
                         ),
                         const SizedBox(height: 8),
                        Text('Progress: ${(course.progressPercent * 100).round()}%'),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: enrolled
                                        ? () => context.push('/dashboard/assessment')
                                        : null,
                                    child: const Text('Take Assessment'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: enrolled
                                        ? () => context.push('/dashboard/courses/${course.id}/code')
                                        : null,
                                    child: const Text('Solve Problem'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: enrolled
                                  ? () => context.push('/dashboard/courses/${course.id}/certificate')
                                  : null,
                              child: const Text('View Certificate'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: course.modules.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text('No modules available')),
                          )
                        ]
                      : course.modules.map((m) {
                    return ModuleRow(
                      module: m,
                      onPlay: m.isLocked
                          ? null
                          : () => context.go('/dashboard/courses/${course.id}/module/${m.id}'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


