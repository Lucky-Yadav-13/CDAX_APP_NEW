// ASSUMPTION: Uses direct repository calls; search/pagination are stubs for now.

import 'package:flutter/material.dart';
import '../application/course_providers.dart';
import 'course_list_card.dart';
import '../../../widgets/animations/staggered_list_animation.dart';
import '../../../widgets/loading/skeleton_loader.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final CourseRepository _repo;
  late Future _loadFuture;
  final List _all = [];
  final List _visible = [];
  bool _isLoadingMore = false;
  int _page = 0;
  static const int _pageSize = 10;
  String? _currentSearch;

  @override
  void initState() {
    super.initState();
    
    // Initialize repository using factory
    _repo = CourseProviders.getCourseRepository();
    print('🎓 CourseListScreen: Initialized with ${_repo.runtimeType}');
    // Pagination: detect near-bottom and trigger load more
    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      final offset = _scrollCtrl.offset;
      if (max - offset < 200) {
        _loadMore();
      }
    });
    _loadFuture = _initialLoad();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadFuture = _repo.getCourses();
          });
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Search courses',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onFieldSubmitted: (v) {
                          _currentSearch = v;
                          setState(() {
                            _loadFuture = _initialLoad();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done && _visible.isEmpty) {
                    return SizedBox(
                      height: 400,
                      child: SkeletonLayouts.list(
                        itemBuilder: () => SkeletonLayouts.courseCard(),
                        itemCount: 3,
                      ),
                    );
                  }
                  if (snapshot.hasError && _visible.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }
                  if (_visible.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: Text('No courses found')),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _visible.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) =>
                        index < _visible.length
                            ? StaggeredListAnimation(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: CourseListCard(course: _visible[index]),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initialLoad() async {
    final data = await _repo.getCourses(search: _currentSearch);
    _all
      ..clear()
      ..addAll(data);
    _page = 0;
    _visible
      ..clear()
      ..addAll(_takePage(0));
    if (mounted) setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    final nextStart = (_page + 1) * _pageSize;
    if (nextStart >= _all.length) return;
    setState(() => _isLoadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _page += 1;
    _visible.addAll(_takePage(_page));
    if (mounted) setState(() => _isLoadingMore = false);
  }

  List _takePage(int page) {
    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, _all.length);
    return _all.sublist(start, end);
  }
}


