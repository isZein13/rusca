import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/app_state.dart';
import '../../l10n.dart';
import '../../theme.dart';
import 'lesson_builder.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<PracticeQuestion> _questions = [];
  int _index = 0;
  int _correct = 0;
  int _sessionXp = 0;
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
        xp: _sessionXp,
        totalXp: state.xp,
        streak: state.streak,
        onAgain: () => _start(state),
      );
    }
    final q = _questions[_index];
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${L10n.questionOf} ${_index + 1}/${_questions.length}',
                  style: const TextStyle(color: RuscaColors.muted),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (_index + (_picked == null ? 0 : 1)) / _questions.length,
                    color: RuscaColors.ink,
                    backgroundColor: RuscaColors.cardAlt,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              children: [
                Text(q.hint, style: const TextStyle(color: RuscaColors.muted)),
                const SizedBox(height: 8),
                Text(
                  q.prompt,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: RuscaColors.ink,
                  ),
                ),
                const SizedBox(height: 24),
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
                    child: const Text(L10n.continueLabel),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _start(AppState state) {
    final questions = buildLesson(
      state.practicePool(),
      distractors: state.words,
    );
    if (questions.isEmpty) return;
    setState(() {
      _questions = questions;
      _index = 0;
      _correct = 0;
      _sessionXp = 0;
      _picked = null;
      _done = false;
      _mastered.clear();
      _missed.clear();
    });
  }

  void _choose(AppState state, PracticeQuestion q, String option) {
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
      await state.recordLesson(
        correct: _correct,
        masteredIds: _mastered,
        missedIds: _missed,
      );
      setState(() {
        _sessionXp = _correct * 10;
        _done = true;
      });
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
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('DERS', style: RuscaType.kicker),
            const SizedBox(height: 6),
            const Text(L10n.practice, style: RuscaType.page),
            const SizedBox(height: 12),
            const Text(
              '8 soruluk kısa ders. Öğrenilecek kelimelerden başlarız.',
              style: TextStyle(color: RuscaColors.muted, height: 1.4),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onStart,
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
    required this.totalXp,
    required this.streak,
    required this.onAgain,
  });

  final int correct;
  final int total;
  final int xp;
  final int totalXp;
  final int streak;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('SONUÇ', style: RuscaType.kicker),
            const SizedBox(height: 6),
            const Text(L10n.lessonDone, style: RuscaType.page),
            const SizedBox(height: 24),
            Text('$correct / $total',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                )),
            Text(L10n.correct, style: const TextStyle(color: RuscaColors.muted)),
            const SizedBox(height: 16),
            Text('+ $xp ${L10n.xpEarned}',
                style: const TextStyle(
                  color: RuscaColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 8),
            Text('${L10n.streak}: $streak ${L10n.days}',
                style: const TextStyle(color: RuscaColors.muted, fontSize: 18)),
            Text('Toplam $totalXp ${L10n.xpEarned}',
                style: const TextStyle(color: RuscaColors.muted)),
            const Spacer(),
            FilledButton(
              onPressed: onAgain,
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
    var border = RuscaColors.line;
    var bg = RuscaColors.card;
    var fg = RuscaColors.ink;
    if (selected != null) {
      if (label == correct) {
        border = RuscaColors.ok;
        bg = const Color(0xFFE7F6EE);
        fg = const Color(0xFF145C38);
      } else if (label == selected) {
        border = RuscaColors.no;
        bg = const Color(0xFFFBECEA);
        fg = RuscaColors.no;
      }
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        side: BorderSide(color: border, width: selected == null ? 1 : 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        alignment: Alignment.centerLeft,
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
