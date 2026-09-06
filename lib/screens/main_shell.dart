import 'package:flutter/material.dart';

import '../navigation/main_tab_controller.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import 'chronology_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _tabController = MainTabController.instance;

  static const _pages = <Widget>[
    HomeScreen(),
    ChronologyScreen(),
    QuizScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context, _) {
        final favCount = FavoritesService.instance.items.length;
        final index = _tabController.index;

        return Scaffold(
          body: IndexedStack(
            index: index,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _tabController.switchTo,
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: '首页',
              ),
              const NavigationDestination(
                icon: Icon(Icons.timeline_outlined),
                selectedIcon: Icon(Icons.timeline_rounded),
                label: '年表',
              ),
              const NavigationDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(Icons.quiz_rounded),
                label: '测验',
              ),
              NavigationDestination(
                icon: favCount > 0
                    ? Badge(
                        label: Text('$favCount'),
                        child: const Icon(Icons.bookmark_outline),
                      )
                    : const Icon(Icons.bookmark_outline),
                selectedIcon: favCount > 0
                    ? Badge(
                        label: Text('$favCount'),
                        child: const Icon(Icons.bookmarks_rounded),
                      )
                    : const Icon(Icons.bookmarks_rounded),
                label: '收藏',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }
}
