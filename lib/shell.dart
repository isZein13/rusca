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
      child: ColoredBox(
        color: const Color(0xFFE7E0D4),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: RuscaColors.paper,
                border: Border.symmetric(
                  vertical: BorderSide(color: RuscaColors.line),
                ),
              ),
              child: Scaffold(
                backgroundColor: RuscaColors.paper,
                body: IndexedStack(
                  index: _index,
                  children: const [
                    HomeScreen(),
                    SwipeScreen(),
                    PracticeScreen(),
                    ListsScreen(),
                  ],
                ),
                bottomNavigationBar: _PhoneNav(
                  index: _index,
                  onSelect: (value) => setState(() => _index = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneNav extends StatelessWidget {
  const _PhoneNav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, L10n.home),
    (Icons.style_outlined, Icons.style_rounded, L10n.cards),
    (Icons.school_outlined, Icons.school_rounded, L10n.practice),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, L10n.words),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RuscaColors.card,
        border: Border(top: BorderSide(color: RuscaColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: index == i ? _items[i].$2 : _items[i].$1,
                    label: _items[i].$3,
                    selected: index == i,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? RuscaColors.ink : RuscaColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 16 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: RuscaColors.stamp,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
