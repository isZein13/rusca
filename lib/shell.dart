import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/lists/lists_screen.dart';
import 'features/practice/practice_screen.dart';
import 'features/swipe/swipe_screen.dart';
import 'l10n.dart';
import 'theme.dart';

class ShellTabs extends InheritedWidget {
  const ShellTabs({
    super.key,
    required this.goTo,
    required super.child,
  });

  final void Function(int index) goTo;

  static void go(BuildContext context, int index) {
    final tabs = context.dependOnInheritedWidgetOfExactType<ShellTabs>();
    tabs?.goTo(index);
  }

  @override
  bool updateShouldNotify(ShellTabs oldWidget) => false;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ShellTabs(
      goTo: (index) => setState(() => _index = index),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            SwipeScreen(),
            PracticeScreen(),
            ListsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: RuscaColors.card,
          indicatorColor: RuscaColors.accent.withValues(alpha: 0.2),
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny),
              label: L10n.home,
            ),
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style),
              label: L10n.cards,
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: L10n.practice,
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: L10n.words,
            ),
          ],
        ),
      ),
    );
  }
}
