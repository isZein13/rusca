import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n.dart';
import '../models/word_item.dart';
import 'phonetics.dart';
import 'speak_topics.dart';

const aiPackSize = 8;

const geminiModels = <String>[
  'gemini-2.5-flash',
  'gemini-2.0-flash',
  'gemini-flash-latest',
];

class AiWordsException implements Exception {
  AiWordsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiKeyStore {
  static const _key = 'rusca_gemini_key';

  Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key)?.trim() ?? '';
  }

  Future<void> save(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, key.trim());
  }
}

class GeneratedWordsStore {
  static const _key = 'rusca_generated_v1';

  Future<List<WordItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final words = <WordItem>[];
      for (final item in list) {
        if (item is! Map) continue;
        try {
          words.add(WordItem.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
      return words;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<WordItem> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final word in words) word.toJson()]),
    );
  }
}

abstract class AiWordClient {
  Future<String> complete(String prompt, String apiKey);
}

class GeminiWordClient implements AiWordClient {
  GeminiWordClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  @override
  Future<String> complete(String prompt, String apiKey) async {
    Object? lastError;
    for (final model in geminiModels) {
      try {
        return await _once(model, prompt, apiKey);
      } on AiWordsException {
        rethrow;
      } catch (error) {
        lastError = error;
      }
    }
    if (lastError is AiWordsException) throw lastError;
    throw AiWordsException(L10n.generateFailed);
  }

  Future<String> _once(String model, String prompt, String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${Uri.encodeQueryComponent(apiKey)}',
    );
    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.7,
                'responseMimeType': 'application/json',
              },
            }),
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw AiWordsException(L10n.generateFailed);
    } on http.ClientException {
      throw AiWordsException(L10n.generateFailed);
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      final body = response.body;
      if (body.contains('API_KEY_INVALID') || body.contains('API key')) {
        throw AiWordsException(L10n.badKey);
      }
      if (body.contains('NOT_FOUND') || body.contains('not found')) {
        throw StateError('missing model');
      }
      throw AiWordsException(L10n.generateFailed);
    }
    if (response.statusCode == 429) {
      throw AiWordsException(L10n.generateFailed);
    }
    if (response.statusCode != 200) {
      throw StateError('model $model status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw AiWordsException(L10n.generateFailed);
    final text = _candidateText(decoded);
    if (text == null || text.trim().isEmpty) {
      throw AiWordsException(L10n.generateFailed);
    }
    return text;
  }

  String? _candidateText(Map<dynamic, dynamic> body) {
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final first = candidates.first;
    if (first is! Map) return null;
    final content = first['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    return buffer.toString();
  }
}

String buildSpeakPrompt({
  required SpeakTopic topic,
  required List<String> knownRu,
  required int learnedCount,
}) {
  final level = learnedCount < 25
      ? 'absolute beginner: 2 to 5 words, present tense, no participles, no rare verbs'
      : learnedCount < 80
          ? 'beginner A1: short spoken lines, simple cases only'
          : 'elementary A2: still under 8 words, everyday speech';
  return '''
You write spoken Russian for a Turkish speaker who wants to talk, not memorize a dictionary.

Return JSON only, no markdown:
{"items":[{"ru":"...","tr":"...","trPron":"...","tip":"..."}]}

Exactly $aiPackSize items.
Situation (${topic.label}): ${topic.brief}
Level: $level

Each item is a line the learner says out loud in this situation.
Prefer a short sentence or a fixed phrase over a lone noun or an infinitive.
Russian must be natural and correct.
tr is a natural Turkish translation.
trPron is how a Turk reads the Russian with Turkish letters (ş ç ğ ü ö ı). Examples: Спасибо → Spasiba, Здравствуйте → Zdrastvuyte, Что → Şto.
tip is one short Turkish sentence: when to say this line.
You may reuse a known word inside a new longer line. The full line must be new.
Do not repeat or lightly reword anything in KNOWN.
Do not include English.

KNOWN:
${knownRu.join(' | ')}
''';
}

String normRu(String ru) {
  final lower = ru.toLowerCase().replaceAll('ё', 'е');
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    if (RegExp(r'^[а-я0-9]$').hasMatch(ch)) {
      buffer.write(ch);
    } else if (ch.trim().isEmpty &&
        buffer.isNotEmpty &&
        !buffer.toString().endsWith(' ')) {
      buffer.write(' ');
    }
  }
  return buffer.toString().trim();
}

List<WordItem> parseAiWords(
  String raw, {
  required Iterable<String> knownRu,
  required String topicId,
  required int idStart,
}) {
  final decoded = jsonDecode(extractJsonObject(raw));
  if (decoded is! Map) return const [];
  final list = decoded['items'] ?? decoded['words'];
  if (list is! List) return const [];

  final seen = knownRu.map(normRu).where((value) => value.isNotEmpty).toSet();
  final words = <WordItem>[];
  var serial = idStart;
  for (final item in list) {
    if (item is! Map) continue;
    final ru = _text(item['ru']);
    final tr = _text(item['tr']);
    var pron = _text(item['trPron']);
    final tip = _text(item['tip']);
    if (!_usableRussian(ru) || tr.isEmpty) continue;
    if (ru.split(RegExp(r'\s+')).length > 8) continue;
    if (RegExp(r'[A-Za-z]{3,}').hasMatch(ru)) continue;
    final key = normRu(ru);
    if (key.isEmpty || seen.contains(key)) continue;
    if (pron.isEmpty) {
      pron = RussianToTurkishPhonetics.transcribe(ru);
    }
    pron = _polishPron(pron);
    seen.add(key);
    words.add(
      WordItem(
        id: 'ai_$serial',
        ru: ru,
        tr: tr,
        trPron: pron,
        category: topicId,
        tip: tip,
      ),
    );
    serial += 1;
    if (words.length >= aiPackSize) break;
  }
  return words;
}

String extractJsonObject(String raw) {
  var text = raw.trim();
  if (text.startsWith('```')) {
    text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
    final fence = text.lastIndexOf('```');
    if (fence >= 0) text = text.substring(0, fence);
  }
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw const FormatException('json yok');
  }
  return text.substring(start, end + 1);
}

bool _usableRussian(String ru) {
  if (ru.isEmpty || ru.length > 80) return false;
  return RegExp('[А-Яа-яЁё]').allMatches(ru).length >= 2;
}

String _text(Object? value) => value is String ? value.trim() : '';

String _polishPron(String pron) {
  final trimmed = pron.trim();
  if (trimmed.isEmpty) return trimmed;
  final first = trimmed.substring(0, 1);
  return first.toUpperCase() + trimmed.substring(1);
}
