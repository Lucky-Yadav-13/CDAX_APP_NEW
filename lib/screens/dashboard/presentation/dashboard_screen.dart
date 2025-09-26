import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';

/// DashboardScreen with BottomNavigation + PageView
/// - Tabs: Home, Courses, Modules, Support, Profile
/// - Maintains state internally
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    _PlaceholderScreen(title: 'Courses'),
    _PlaceholderScreen(title: 'Modules'),
    _PlaceholderScreen(title: 'Support'),
    _PlaceholderScreen(title: 'Profile'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Modules'),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// TODO: Replace with actual feature screens when available
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/dashboard/home'),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}


