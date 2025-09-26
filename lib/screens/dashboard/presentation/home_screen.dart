import 'package:flutter/material.dart';
import '../application/dashboard_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/suggestive_learning_card.dart';
import '../widgets/progress_card.dart';
import 'package:go_router/go_router.dart';

/// HomeScreen
/// Assumptions:
/// - Uses Riverpod to read user and course providers.
/// - Theme tokens come from AppTheme.
/// - Navigation handled by GoRouter.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = getMockUserName();

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $userName 👋'),
        centerTitle: false,
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
                height: 220,
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
                onPressed: () {
                  // TODO: Deep link to suggested module/course
                },
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
                    onTap: () {
                      // TODO: Navigate to module detail
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


