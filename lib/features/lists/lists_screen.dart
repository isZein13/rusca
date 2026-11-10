import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n.dart';
import '../../models/word_item.dart';
import '../../theme.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  L10n.words,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const TabBar(
              indicatorColor: RuscaColors.accent,
              labelColor: RuscaColors.accent,
              unselectedLabelColor: RuscaColors.muted,
              tabs: [
                Tab(text: L10n.toLearn),
                Tab(text: L10n.learned),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _WordList(
                    words: state.toLearn,
                    empty: L10n.emptyToLearn,
                    onHeard: (w) => state.tts.speakRussian(w.ru),
                  ),
                  _WordList(
                    words: state.learned,
                    empty: L10n.emptyLearned,
                    onHeard: (w) => state.tts.speakRussian(w.ru),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({
    required this.words,
    required this.empty,
    required this.onHeard,
  });

  final List<WordItem> words;
  final String empty;
  final void Function(WordItem) onHeard;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            empty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: RuscaColors.muted),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: words.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final word = words[index];
        return ListTile(
          tileColor: RuscaColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(word.trPron, style: const TextStyle(color: RuscaColors.accent)),
          subtitle: Text('${word.ru} · ${word.tr}'),
          trailing: IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => onHeard(word),
          ),
        );
      },
    );
  }
}
