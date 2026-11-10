import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/app_state.dart';
import '../../l10n.dart';
import '../../models/word_item.dart';
import '../../theme.dart';

enum _QType { ruToTr, trToRu, pickPron }

class _Question {
  _Question({
    required this.word,
    required this.type,
    required this.prompt,
    required this.hint,
    required this.options,
    required this.correct,
  });

  final WordItem word;
  final _QType type;
  final String prompt;
  final String hint;
  final List<String> options;
  final String correct;
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<_Question> _questions = [];
  int _index = 0;
  int _correct = 0;
  String? _picked;
  bool _done = false;
  final Set<String> _mastered = {};
  final Set<String> _missed = {};

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (_questions.isEmpty && !_done) {
      return _Lobby(onStart: () => _start(state));
    }
    if (_done) {
      return _Summary(
        correct: _correct,
        total: _questions.length,
        xp: state.xp,
        streak: state.streak,
        onAgain: () => _start(state),
      );
    }
    final q = _questions[_index];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${L10n.questionOf} ${_index + 1}/${_questions.length}',
              style: const TextStyle(color: RuscaColors.muted),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _index / _questions.length,
              color: RuscaColors.accent,
              backgroundColor: RuscaColors.cardAlt,
            ),
            const SizedBox(height: 28),
            Text(q.hint, style: const TextStyle(color: RuscaColors.muted)),
            const SizedBox(height: 8),
            Text(
              q.prompt,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            for (final option in q.options) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OptionButton(
                  label: option,
                  selected: _picked,
                  correct: q.correct,
                  onTap: _picked == null ? () => _choose(state, q, option) : null,
                ),
              ),
            ],
            if (_picked != null)
              FilledButton(
                onPressed: () => _next(state),
                style: FilledButton.styleFrom(
                  backgroundColor: RuscaColors.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(L10n.continueLabel),
              ),
          ],
        ),
      ),
    );
  }

  void _start(AppState state) {
    final pool = state.practicePool();
    final rnd = Random();
    final selected = List<WordItem>.from(pool)..shuffle(rnd);
    final take = selected.take(8).toList();
    final questions = <_Question>[];
    for (var i = 0; i < take.length; i++) {
      questions.add(_buildQuestion(take[i], pool, _QType.values[i % 3], rnd));
    }
    setState(() {
      _questions = questions;
      _index = 0;
      _correct = 0;
      _picked = null;
      _done = false;
      _mastered.clear();
      _missed.clear();
    });
  }

  _Question _buildQuestion(
    WordItem word,
    List<WordItem> pool,
    _QType type,
    Random rnd,
  ) {
    final others = pool.where((w) => w.id != word.id).toList()..shuffle(rnd);
    switch (type) {
      case _QType.ruToTr:
        return _Question(
          word: word,
          type: type,
          prompt: word.ru,
          hint: L10n.pickTurkish,
          options: _opts([word.tr, ...others.take(3).map((w) => w.tr)], rnd),
          correct: word.tr,
        );
      case _QType.trToRu:
        return _Question(
          word: word,
          type: type,
          prompt: word.tr,
          hint: L10n.pickRussian,
          options: _opts([word.ru, ...others.take(3).map((w) => w.ru)], rnd),
          correct: word.ru,
        );
      case _QType.pickPron:
        return _Question(
          word: word,
          type: type,
          prompt: word.ru,
          hint: L10n.pickPron,
          options: _opts(
            [word.trPron, ...others.take(3).map((w) => w.trPron)],
            rnd,
          ),
          correct: word.trPron,
        );
    }
  }

  List<String> _opts(Iterable<String> raw, Random rnd) {
    final list = raw.toSet().toList()..shuffle(rnd);
    return list.take(4).toList();
  }

  void _choose(AppState state, _Question q, String option) {
    final ok = option == q.correct;
    setState(() {
      _picked = option;
      if (ok) {
        _correct += 1;
        if (!_missed.contains(q.word.id)) _mastered.add(q.word.id);
      } else {
        _missed.add(q.word.id);
        _mastered.remove(q.word.id);
      }
    });
    if (ok) {
      state.tts.speakRussian(q.word.ru);
    }
  }

  Future<void> _next(AppState state) async {
    if (_index >= _questions.length - 1) {
      await state.recordLesson(correct: _correct, masteredIds: _mastered);
      setState(() => _done = true);
      return;
    }
    setState(() {
      _index += 1;
      _picked = null;
    });
  }
}

class _Lobby extends StatelessWidget {
  const _Lobby({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              L10n.practice,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              '8 soruluk kısa ders. Öğrenilecek kelimelerden başlarız.',
              style: TextStyle(color: RuscaColors.muted, height: 1.4),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: RuscaColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(L10n.startPractice),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.correct,
    required this.total,
    required this.xp,
    required this.streak,
    required this.onAgain,
  });

  final int correct;
  final int total;
  final int xp;
  final int streak;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              L10n.lessonDone,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            Text('$correct / $total ${L10n.correct}',
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text('${L10n.xpEarned}: $xp',
                style: const TextStyle(color: RuscaColors.accent)),
            Text('${L10n.streak}: $streak ${L10n.days}',
                style: const TextStyle(color: RuscaColors.muted)),
            const Spacer(),
            FilledButton(
              onPressed: onAgain,
              style: FilledButton.styleFrom(
                backgroundColor: RuscaColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(L10n.startPractice),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.correct,
    required this.onTap,
  });

  final String label;
  final String? selected;
  final String correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = RuscaColors.cardAlt;
    Color bg = RuscaColors.card;
    if (selected != null) {
      if (label == correct) {
        border = RuscaColors.ok;
        bg = RuscaColors.ok.withValues(alpha: 0.15);
      } else if (label == selected) {
        border = RuscaColors.no;
        bg = RuscaColors.no.withValues(alpha: 0.15);
      }
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
