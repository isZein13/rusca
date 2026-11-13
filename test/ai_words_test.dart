import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rusca/data/ai_words.dart';
import 'package:rusca/data/app_state.dart';
import 'package:rusca/data/speak_topics.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _payload = '''
{"items":[
  {"ru":"Привет","tr":"Merhaba","trPron":"Privet","tip":"Selam"},
  {"ru":"Hello","tr":"Merhaba","trPron":"Hello","tip":"Yok"},
  {"ru":"Можно меню?","tr":"Menü alabilir miyim?","trPron":"","tip":"Kafede söyle."}
]}
''';

class _FakeAi implements AiWordClient {
  _FakeAi(this.text);

  final String text;
  String? prompt;
  String? apiKey;

  @override
  Future<String> complete(String prompt, String apiKey) async {
    this.prompt = prompt;
    this.apiKey = apiKey;
    return text;
  }
}

Future<void> emptyPrefs() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('home_widget'),
    (call) async => null,
  );

  test('parser keeps a new spoken line and drops duplicates', () {
    final words = parseAiWords(
      '```json\n$_payload\n```',
      knownRu: const ['Привет'],
      topicId: 'kafe',
      idStart: 3,
    );

    expect(words, hasLength(1));
    expect(words.single.id, 'ai_3');
    expect(words.single.ru, 'Можно меню?');
    expect(words.single.tr, 'Menü alabilir miyim?');
    expect(words.single.trPron, 'Mojno menyu?');
    expect(words.single.tip, 'Kafede söyle.');
    expect(words.single.category, 'kafe');
  });

  test('prompt follows the situation and how many words are already learned',
      () {
    final beginner = buildSpeakPrompt(
      topic: speakTopics.first,
      knownRu: const ['Привет'],
      learnedCount: 0,
    );
    final later = buildSpeakPrompt(
      topic: speakTopics[2],
      knownRu: const ['Привет'],
      learnedCount: 90,
    );

    expect(beginner, contains('Привет'));
    expect(beginner, contains('Tanışma'));
    expect(beginner, contains('absolute beginner'));
    expect(later, contains('Kafe'));
    expect(later, contains('elementary'));
  });

  test('next situation is the one with the fewest phrases', () {
    expect(suggestSpeakTopic(const []), 'tanisma');
    expect(
      suggestSpeakTopic(List.filled(8, 'tanisma')),
      'anlama',
    );
  });

  test('gemini client skips a missing model and reads the text', () async {
    var calls = 0;
    final client = GeminiWordClient(
      httpClient: MockClient((request) async {
        calls += 1;
        expect(request.url.path, contains(':generateContent'));
        expect(request.url.queryParameters['key'], 'abc');
        if (request.url.path.contains(geminiModels.first)) {
          return http.Response('{"error":{"status":"NOT_FOUND"}}', 404);
        }
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '{"items":[]}'},
                  ],
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    expect(await client.complete('hi', 'abc'), '{"items":[]}');
    expect(calls, 2);
  });

  test('generated phrases stay on the device and open the card deck', () async {
    await emptyPrefs();
    final ai = _FakeAi(_payload);
    final state = AppState(ai: ai);
    await state.load();
    await state.saveAiKey('test-key-123456789012345');

    final added = await state.generateSpeakingWords('kafe');

    expect(added, 1);
    expect(ai.apiKey, 'test-key-123456789012345');
    expect(ai.prompt, contains('Привет'));
    expect(ai.prompt, contains('Kafe'));
    expect(state.swipeDeck.first.ru, 'Можно меню?');
    expect(state.generateError, isNull);

    final again = AppState(ai: _FakeAi('{}'));
    await again.load();
    expect(again.generatedWords.single.tr, 'Menü alabilir miyim?');
    expect(again.hasAiKey, isTrue);
    expect(again.swipeDeck.first.id, 'ai_1');
  });
}
