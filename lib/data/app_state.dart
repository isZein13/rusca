import 'package:flutter/foundation.dart';

import '../models/word_item.dart';
import 'progress_store.dart';
import 'tts_service.dart';
import 'widget_sync.dart';
import 'word_catalog.dart';

class AppState extends ChangeNotifier {
  AppState({
    ProgressStore? store,
    TtsService? tts,
  })  : _store = store ?? ProgressStore(),
        tts = tts ?? TtsService();

  final ProgressStore _store;
  final TtsService tts;

  WordCatalog? _catalog;
  ProgressSnapshot _progress = ProgressSnapshot(
    statuses: {},
    correctCounts: {},
    xp: 0,
    streak: 0,
    lastPracticeDay: '',
  );

  List<WordItem> get words => _catalog?.words ?? const [];
  int get xp => _progress.xp;
  int get streak => _progress.streak;

  WordStatus statusOf(WordItem word) => _progress.statusOf(word.id);

  List<WordItem> get toLearn =>
      words.where((w) => statusOf(w) == WordStatus.toLearn).toList();

  List<WordItem> get learned =>
      words.where((w) => statusOf(w) == WordStatus.learned).toList();

  List<WordItem> get swipeDeck =>
      words.where((w) => statusOf(w) == WordStatus.neu).toList();

  WordItem get wordOfDay {
    if (words.isEmpty) {
      return const WordItem(
        id: 'fallback',
        ru: 'Привет',
        tr: 'Merhaba',
        trPron: 'Privet',
        category: 'selamlar',
      );
    }
    if (toLearn.isNotEmpty) {
      final day = DateTime.now().difference(DateTime(2024)).inDays;
      return toLearn[day % toLearn.length];
    }
    final day = DateTime.now().difference(DateTime(2024)).inDays;
    return words[day % words.length];
  }

  Future<void> load() async {
    _catalog = await WordCatalog.load();
    _progress = await _store.load();
    await syncWordOfDayWidget(wordOfDay);
    notifyListeners();
  }

  Future<void> markLearned(WordItem word) async {
    _progress.statuses[word.id] = WordStatus.learned;
    await _persistAndSync();
  }

  Future<void> markToLearn(WordItem word) async {
    _progress.statuses[word.id] = WordStatus.toLearn;
    await _persistAndSync();
  }

  List<WordItem> practicePool() {
    if (toLearn.isNotEmpty) return List<WordItem>.from(toLearn);
    return List<WordItem>.from(words);
  }

  Future<void> recordLesson({
    required int correct,
    required Set<String> masteredIds,
  }) async {
    _progress.xp += correct * 10;
    final today = _dayKey(DateTime.now());
    if (_progress.lastPracticeDay == today) {
      // already counted today
    } else if (_progress.lastPracticeDay ==
        _dayKey(DateTime.now().subtract(const Duration(days: 1)))) {
      _progress.streak += 1;
    } else {
      _progress.streak = 1;
    }
    _progress.lastPracticeDay = today;
    for (final id in masteredIds) {
      _progress.correctCounts[id] = (_progress.correctCounts[id] ?? 0) + 1;
      if ((_progress.correctCounts[id] ?? 0) >= 1) {
        _progress.statuses[id] = WordStatus.learned;
      }
    }
    await _persistAndSync();
  }

  Future<void> _persistAndSync() async {
    await _store.save(_progress);
    await syncWordOfDayWidget(wordOfDay);
    notifyListeners();
  }

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
