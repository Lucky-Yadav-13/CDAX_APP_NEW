import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/dashboard_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/suggestive_learning_card.dart';
import '../widgets/progress_card.dart';
import 'package:go_router/go_router.dart';
import '../../courses/data/mock_course_repository.dart';
import '../../../providers/user_provider.dart';

/// HomeScreen
/// Assumptions:
/// - Uses Provider to read user and course providers.
/// - Theme tokens come from AppTheme.
/// - Navigation handled by GoRouter.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.currentUser;
            final userName = user?.firstName ?? getMockUserName();
            return Text('Welcome, $userName 👋');
          },
        ),
        centerTitle: false,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isAuthenticated) {
                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await userProvider.logout();
                      // Navigate to login screen
                      context.go('/login');
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.account_circle),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your courses', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: FutureBuilder(
                  future: getMockEnrolledCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Failed to load: ${snapshot.error}'));
                    }
                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return Center(
                        child: Text('No enrolled courses yet',
                            style: theme.textTheme.bodyMedium),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final c = courses[index];
                        return CourseCard(
                          width: 260,
                          title: c.title,
                          subtitle: c.description,
                          thumbnailUrl: c.thumbnailUrl,
                          progressPercent: c.progressPercent,
                          isLocked: c.isLocked,
                          onTap: () => context.push('/dashboard/courses/${c.id}'),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              Text('Suggestive Learning', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SuggestiveLearningCard(
                title: 'Continue where you left off',
                description:
                    'Pick up your next module and keep your learning streak alive.',
                imageUrl: 'https://picsum.photos/seed/suggestive/800/400',
                onPressed: () async {
                  // Use last-played info to deep link; fallback to first course/module
                  try {
                    final repo = MockCourseRepository();
                    final courses = await repo.getCourses();
                    if (courses.isEmpty) return;
                    final course = courses.first;
                    final module = course.modules.firstWhere(
                      (m) => !m.isLocked,
                      orElse: () => course.modules.first,
                    );
                    // ignore: use_build_context_synchronously
                    context.push('/dashboard/courses/${course.id}/module/${module.id}');
                  } catch (_) {}
                },
              ),

              const SizedBox(height: 24),
              
              // Assessment section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Test Your Skills', style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: () => context.push('/dashboard/assessment'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  onTap: () => context.push('/dashboard/assessment'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.quiz,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Take Assessments',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Evaluate your knowledge and earn certificates',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text('Keep progressing', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (context, index) {
                  return ProgressCard(
                    title: 'Module ${index + 1}',
                    progress: (index + 1) * 0.12 % 1.0,
                    onTap: () async {
                      try {
                        final repo = MockCourseRepository();
                        final courses = await repo.getCourses();
                        if (courses.isEmpty) return;
                        final course = courses[(index) % courses.length];
                        final module = course.modules.firstWhere(
                          (m) => !m.isLocked,
                          orElse: () => course.modules.first,
                        );
                        // ignore: use_build_context_synchronously
                        context.push('/dashboard/courses/${course.id}/module/${module.id}');
                      } catch (_) {}
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


