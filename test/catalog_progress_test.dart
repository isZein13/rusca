import 'package:flutter_test/flutter_test.dart';
import 'package:rusca/data/progress_store.dart';
import 'package:rusca/data/word_catalog.dart';
import 'package:rusca/models/word_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog has 150 words and the planned pronunciations', () async {
    final catalog = await WordCatalog.load();
    expect(catalog.words.length, greaterThanOrEqualTo(150));
    final byId = {for (final word in catalog.words) word.id: word};
    expect(byId['privet']!.trPron, 'Privet');
    expect(byId['spasibo']!.trPron, 'Spasiba');
    expect(byId['horosho']!.trPron, 'Haraşo');
    expect(byId['chto']!.trPron, 'Şto');
    expect(byId['lyubov']!.trPron, 'Lyubov');
    expect(byId.keys.toSet(), hasLength(catalog.words.length));
  });

  test('progress round-trips statuses, xp and streak', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ProgressStore();
    final snapshot = ProgressSnapshot(
      statuses: {'privet': WordStatus.learned, 'chto': WordStatus.toLearn},
      correctCounts: {'privet': 2},
      xp: 20,
      streak: 3,
      lastPracticeDay: '2026-11-10',
    );
    await store.save(snapshot);
    final loaded = await store.load();
    expect(loaded.statusOf('privet'), WordStatus.learned);
    expect(loaded.statusOf('chto'), WordStatus.toLearn);
    expect(loaded.statusOf('missing'), WordStatus.neu);
    expect(loaded.correctCounts['privet'], 2);
    expect(loaded.xp, 20);
    expect(loaded.streak, 3);
    expect(loaded.lastPracticeDay, '2026-11-10');
  });
}
