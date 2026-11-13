import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rusca/data/phonetics.dart';
import 'package:rusca/features/practice/lesson_builder.dart';
import 'package:rusca/models/word_item.dart';

void main() {
  test('transcribes a leading ye and drops the soft sign', () {
    expect(RussianToTurkishPhonetics.transcribe('есть'), 'yest');
    expect(RussianToTurkishPhonetics.transcribe('Любовь'), 'Lyubov');
  });

  test('builds an 8-question lesson with four choices', () {
    final pool = [
      for (var i = 0; i < 10; i++)
        WordItem(
          id: 'w$i',
          ru: 'Слово$i',
          tr: 'Kelime$i',
          trPron: 'Slova$i',
          category: 'test',
        ),
    ];
    final lesson = buildLesson(pool, random: Random(1));
    expect(lesson, hasLength(8));
    for (final question in lesson) {
      expect(question.options, hasLength(4));
      expect(question.options, contains(question.correct));
    }
    expect(lesson.map((q) => q.hint).toSet().length, greaterThan(1));
  });

  test('repeats a short queue into 8 questions', () {
    final pool = [
      for (var i = 0; i < 3; i++)
        WordItem(
          id: 'w$i',
          ru: 'Слово$i',
          tr: 'Kelime$i',
          trPron: 'Slova$i',
          category: 'test',
        ),
    ];
    final lesson = buildLesson(
      pool,
      random: Random(2),
      distractors: [
        ...pool,
        for (var i = 0; i < 6; i++)
          WordItem(
            id: 'd$i',
            ru: 'Другое$i',
            tr: 'Başka$i',
            trPron: 'Drugoye$i',
            category: 'test',
          ),
      ],
    );
    expect(lesson, hasLength(8));
    for (final question in lesson) {
      expect(question.options, contains(question.correct));
      expect(question.options, hasLength(4));
    }
  });
}
