import 'package:flutter/foundation.dart';

import '../l10n.dart';
import '../models/word_item.dart';
import 'ai_words.dart';
import 'progress_store.dart';
import 'speak_topics.dart';
import 'tts_service.dart';
import 'widget_sync.dart';
import 'word_catalog.dart';

class AppState extends ChangeNotifier {
  AppState({
    ProgressStore? store,
    TtsService? tts,
    GeneratedWordsStore? generatedStore,
    AiKeyStore? keyStore,
    AiWordClient? ai,
  })  : _store = store ?? ProgressStore(),
        tts = tts ?? TtsService(),
        _generatedStore = generatedStore ?? GeneratedWordsStore(),
        _keyStore = keyStore ?? AiKeyStore(),
        _ai = ai ?? GeminiWordClient();

  final ProgressStore _store;
  final TtsService tts;
  final GeneratedWordsStore _generatedStore;
  final AiKeyStore _keyStore;
  final AiWordClient _ai;

  WordCatalog? _catalog;
  List<WordItem> _generated = [];
  String aiKey = '';
  bool generating = false;
  String? generateError;
  ProgressSnapshot _progress = ProgressSnapshot(
    statuses: {},
    correctCounts: {},
    xp: 0,
    streak: 0,
    lastPracticeDay: '',
  );

  List<WordItem> get words => [...?_catalog?.words, ..._generated];
  List<WordItem> get generatedWords => List<WordItem>.unmodifiable(_generated);
  bool get hasAiKey => aiKey.length >= 20;
  int get xp => _progress.xp;
  int get streak => _progress.streak;

  WordStatus statusOf(WordItem word) => _progress.statusOf(word.id);

  List<WordItem> get toLearn =>
      words.where((w) => statusOf(w) == WordStatus.toLearn).toList();

  List<WordItem> get learned =>
      words.where((w) => statusOf(w) == WordStatus.learned).toList();

  List<WordItem> get swipeDeck {
    final neu = words.where((w) => statusOf(w) == WordStatus.neu).toList();
    final fresh =
        neu.where((w) => w.id.startsWith('ai_')).toList().reversed.toList();
    final rest = neu.where((w) => !w.id.startsWith('ai_'));
    return [...fresh, ...rest];
  }

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
    _generated = await _generatedStore.load();
    aiKey = await _keyStore.load();
    _progress = await _store.load();
    await syncWordOfDayWidget(wordOfDay);
    notifyListeners();
  }

  Future<void> saveAiKey(String key) async {
    aiKey = key.trim();
    await _keyStore.save(aiKey);
    notifyListeners();
  }

  Future<int> generateSpeakingWords(String topicId) async {
    if (generating) return 0;
    final topic = speakTopicById(topicId) ?? speakTopics.first;
    if (!hasAiKey) {
      generateError = L10n.needKey;
      notifyListeners();
      throw AiWordsException(L10n.needKey);
    }
    generating = true;
    generateError = null;
    notifyListeners();
    try {
      final prompt = buildSpeakPrompt(
        topic: topic,
        knownRu: words.map((word) => word.ru).toList(),
        learnedCount: learned.length,
      );
      final raw = await _ai.complete(prompt, aiKey);
      final fresh = parseAiWords(
        raw,
        knownRu: words.map((word) => word.ru),
        topicId: topic.id,
        idStart: _nextAiSerial(),
      );
      if (fresh.isEmpty) throw AiWordsException(L10n.generateEmpty);
      _generated = [..._generated, ...fresh];
      await _generatedStore.save(_generated);
      return fresh.length;
    } on AiWordsException catch (error) {
      generateError = error.message;
      rethrow;
    } catch (_) {
      generateError = L10n.generateFailed;
      throw AiWordsException(L10n.generateFailed);
    } finally {
      generating = false;
      notifyListeners();
    }
  }

  int _nextAiSerial() {
    var max = 0;
    for (final word in _generated) {
      final match = RegExp(r'^ai_(\d+)$').firstMatch(word.id);
      final serial = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (serial > max) max = serial;
    }
    return max + 1;
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
    final fresh = words.where((w) => statusOf(w) == WordStatus.neu).toList();
    if (fresh.isNotEmpty) return fresh;
    return List<WordItem>.from(words);
  }

  Future<void> recordLesson({
    required int correct,
    required Set<String> masteredIds,
    Set<String> missedIds = const {},
  }) async {
    _progress.xp += correct * 10;
    final today = _dayKey(DateTime.now());
    if (_progress.lastPracticeDay != today) {
      if (_progress.lastPracticeDay ==
          _dayKey(DateTime.now().subtract(const Duration(days: 1)))) {
        _progress.streak += 1;
      } else {
        _progress.streak = 1;
      }
      _progress.lastPracticeDay = today;
    }
    for (final id in masteredIds) {
      _progress.correctCounts[id] = (_progress.correctCounts[id] ?? 0) + 1;
      _progress.statuses[id] = WordStatus.learned;
    }
    for (final id in missedIds) {
      if (_progress.statuses[id] == WordStatus.learned) continue;
      _progress.statuses[id] = WordStatus.toLearn;
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
