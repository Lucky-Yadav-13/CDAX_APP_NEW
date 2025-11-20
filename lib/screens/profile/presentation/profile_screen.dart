// ASSUMPTION: Avatar uses initials; streak is a small grid placeholder.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../application/profile_provider.dart';
import '../../courses/application/course_providers.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;
        final initials = profile.name.isNotEmpty
            ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
            : '?';
        return Scaffold(
          appBar: AppBar(title: const Text('Profile'), actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: profileProvider.isLoading ? null : () async {
                final updated = await Navigator.of(context).push<UserProfile>(
                  MaterialPageRoute(
                    builder: (_) => ProfileEditScreen(initial: profile),
                  ),
                );
                if (updated != null && mounted) {
                  await profileProvider.updateProfile(updated);
                }
              },
            )
          ]),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 28, child: Text(initials)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: Theme.of(context).textTheme.titleMedium),
                        Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
                        Text(profile.phone, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Chip(label: Text(profile.subscribed ? 'Pro' : 'Free')),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Enrolled courses'),
                  trailing: Text('${profile.enrolledCoursesCount}'),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => const _EnrolledCoursesSheet(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text('Streak', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Streak'),
                      content: const Text('Detailed streak view placeholder.'),
                    ),
                  );
                },
                child: _StreakGrid(),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profile'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/dashboard/profile/edit'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings coming soon')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.menu_book),
                      title: const Text('Courses'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/dashboard/courses'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: const Text('Payment'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/dashboard/subscription/methods'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.work),
                      title: const Text('Placement'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/dashboard/placement/eligibility'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy Policy coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreakGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 28,
      itemBuilder: (context, index) {
        // Simple alternating pattern; replace with backend streak days
        final active = index % 5 != 0;
        return Container(
          height: 16,
          decoration: BoxDecoration(
            color: active ? Theme.of(context).colorScheme.primary : Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class _EnrolledCoursesSheet extends StatelessWidget {
  const _EnrolledCoursesSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Your enrolled courses', style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: FutureBuilder(
                future: _loadEnrolled(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final courses = snapshot.data as List<_MiniCourse>;
                  if (courses.isEmpty) {
                    return const Center(child: Text('No courses yet'));
                  }
                  return ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = courses[i];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(c.thumb)),
                        title: Text(c.title),
                        subtitle: Text('Progress ${(c.progress * 100).round()}%'),
                        onTap: () => context.push('/dashboard/courses/${c.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<_MiniCourse>> _loadEnrolled() async {
    // TODO: Replace with backend call; for now using mock repo
    final repo = CourseProviders.getCourseRepository();
    final all = await repo.getCourses();
    return all
        .where((c) => c.isSubscribed)
        .map((c) => _MiniCourse(c.id, c.title, c.thumbnailUrl, c.progressPercent))
        .toList();
  }
}

class _MiniCourse {
  _MiniCourse(this.id, this.title, this.thumb, this.progress);
  final String id;
  final String title;
  final String thumb;
  final double progress;
}
