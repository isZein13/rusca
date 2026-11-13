import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n.dart';
import '../../shell.dart';
import '../../theme.dart';
import '../../widgets/word_face.dart';
import '../speak/generate_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final word = state.wordOfDay;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const Text('BUGÜN', style: RuscaType.kicker),
          const SizedBox(height: 6),
          const Text(L10n.wordOfDay, style: RuscaType.page),
          const SizedBox(height: 8),
          Text(
            '${state.streak} ${L10n.days} seri  ·  ${state.xp} XP',
            style: const TextStyle(color: RuscaColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          PaperCard(child: WordFace(word: word, state: state)),
          const SizedBox(height: 14),
          const Text(
            L10n.checkHomeWidget,
            style:
                TextStyle(color: RuscaColors.muted, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () => openGenerate(context),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text(L10n.generateWords),
          ),
          const SizedBox(height: 8),
          const Text(
            L10n.generateLead,
            style:
                TextStyle(color: RuscaColors.muted, height: 1.35, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ShellTabs.go(context, 1),
            child: const Text(L10n.openCards),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => ShellTabs.go(context, 2),
            child: const Text(L10n.startPractice),
          ),
        ],
      ),
    );
  }
}
