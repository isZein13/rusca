import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n.dart';
import '../../shell.dart';
import '../../theme.dart';
import '../../widgets/word_face.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final word = state.wordOfDay;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Row(
            children: [
              const Text(
                L10n.appName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              _Pill(icon: Icons.local_fire_department, text: '${state.streak}'),
              const SizedBox(width: 8),
              _Pill(icon: Icons.bolt, text: '${state.xp} XP'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            L10n.wordOfDay,
            style: TextStyle(color: RuscaColors.muted, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: RuscaColors.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: RuscaColors.accent.withValues(alpha: 0.25)),
            ),
            child: WordFace(word: word, state: state),
          ),
          const SizedBox(height: 16),
          Text(
            L10n.checkHomeWidget,
            style: TextStyle(color: RuscaColors.muted.withValues(alpha: 0.9), height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ShellTabs.go(context, 1),
            style: FilledButton.styleFrom(
              backgroundColor: RuscaColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(L10n.openCards),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ShellTabs.go(context, 2),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(L10n.startPractice),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: RuscaColors.cardAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RuscaColors.accent),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
