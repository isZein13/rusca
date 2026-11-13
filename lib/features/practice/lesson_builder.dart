import 'dart:math';

import '../../l10n.dart';
import '../../models/word_item.dart';

class PracticeQuestion {
  const PracticeQuestion({
    required this.word,
    required this.prompt,
    required this.hint,
    required this.options,
    required this.correct,
  });

  final WordItem word;
  final String prompt;
  final String hint;
  final List<String> options;
  final String correct;
}

enum _Kind { ruToTr, trToRu, pron }

List<PracticeQuestion> buildLesson(
  List<WordItem> pool, {
  int count = 8,
  Random? random,
  List<WordItem>? distractors,
}) {
  if (pool.isEmpty) return const [];
  final rng = random ?? Random();
  final words = List<WordItem>.from(pool)..shuffle(rng);
  final bank = (distractors == null || distractors.isEmpty) ? pool : distractors;
  const kinds = _Kind.values;
  return [
    for (var i = 0; i < count; i++)
      _question(words[i % words.length], bank, kinds[i % kinds.length], rng),
  ];
}

PracticeQuestion _question(
  WordItem word,
  List<WordItem> pool,
  _Kind kind,
  Random rng,
) {
  String answerOf(WordItem item) {
    switch (kind) {
      case _Kind.ruToTr:
        return item.tr;
      case _Kind.trToRu:
        return item.ru;
      case _Kind.pron:
        return item.trPron;
    }
  }

  final prompt = kind == _Kind.trToRu ? word.tr : word.ru;
  final hint = switch (kind) {
    _Kind.ruToTr => L10n.pickTurkish,
    _Kind.trToRu => L10n.pickRussian,
    _Kind.pron => L10n.pickPron,
  };

  final options = <String>{answerOf(word)};
  final others = List<WordItem>.from(pool)..shuffle(rng);
  for (final other in others) {
    if (options.length >= 4) break;
    if (other.id == word.id) continue;
    options.add(answerOf(other));
  }
  final list = options.toList()..shuffle(rng);
  return PracticeQuestion(
    word: word,
    prompt: prompt,
    hint: hint,
    options: list,
    correct: answerOf(word),
  );
}
