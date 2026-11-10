import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_item.dart';

class ProgressSnapshot {
  ProgressSnapshot({
    required this.statuses,
    required this.correctCounts,
    required this.xp,
    required this.streak,
    required this.lastPracticeDay,
  });

  final Map<String, WordStatus> statuses;
  final Map<String, int> correctCounts;
  final int xp;
  final int streak;
  final String lastPracticeDay;

  WordStatus statusOf(String id) => statuses[id] ?? WordStatus.neu;
}

class ProgressStore {
  static const _key = 'rusca_progress_v1';

  Future<ProgressSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return ProgressSnapshot(
        statuses: {},
        correctCounts: {},
        xp: 0,
        streak: 0,
        lastPracticeDay: '',
      );
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final statuses = <String, WordStatus>{};
    final statusRaw = map['statuses'] as Map<String, dynamic>? ?? {};
    for (final entry in statusRaw.entries) {
      statuses[entry.key] = WordStatus.values.firstWhere(
        (value) => value.name == entry.value,
        orElse: () => WordStatus.neu,
      );
    }
    final counts = <String, int>{};
    final countRaw = map['correctCounts'] as Map<String, dynamic>? ?? {};
    for (final entry in countRaw.entries) {
      counts[entry.key] = entry.value as int;
    }
    return ProgressSnapshot(
      statuses: statuses,
      correctCounts: counts,
      xp: map['xp'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      lastPracticeDay: map['lastPracticeDay'] as String? ?? '',
    );
  }

  Future<void> save(ProgressSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final statuses = <String, String>{};
    for (final entry in snapshot.statuses.entries) {
      statuses[entry.key] = entry.value.name;
    }
    await prefs.setString(
      _key,
      jsonEncode({
        'statuses': statuses,
        'correctCounts': snapshot.correctCounts,
        'xp': snapshot.xp,
        'streak': snapshot.streak,
        'lastPracticeDay': snapshot.lastPracticeDay,
      }),
    );
  }
}
