import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _tts = FlutterTts();

  final FlutterTts _tts;
  Future<void>? _preparing;
  bool _prepared = false;

  Future<void> speakRussian(String text) async {
    final spoken = text.trim();
    if (spoken.isEmpty) return;
    try {
      await _ensureReady();
      if (_isIos) {
        await _tts.setSharedInstance(true);
      }
      await _tts.speak(spoken);
    } catch (_) {
      _prepared = false;
      _preparing = null;
    }
  }

  bool get _isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _ensureReady() {
    if (_prepared) return Future<void>.value();
    return _preparing ??= _prepare();
  }

  Future<void> _prepare() async {
    if (_isIos) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }
    await _tts.setVolume(1);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1);
    await _selectRussian();
    _prepared = true;
  }

  Future<void> _selectRussian() async {
    final voices = await _tts.getVoices.catchError((_) => null);
    if (voices is List) {
      Map<String, String>? builtin;
      Map<String, String>? any;
      for (final item in voices) {
        if (item is! Map) continue;
        final locale = '${item['locale'] ?? ''}';
        if (!locale.toLowerCase().startsWith('ru')) continue;
        final voice = <String, String>{
          'name': '${item['name'] ?? ''}',
          'locale': locale,
          if ('${item['identifier'] ?? ''}'.isNotEmpty)
            'identifier': '${item['identifier']}',
        };
        if (voice['name']!.isEmpty) continue;
        any ??= voice;
        if ('${item['quality'] ?? ''}' == 'default') builtin ??= voice;
      }
      final chosen = builtin ?? any;
      if (chosen != null) {
        await _tts.setVoice(chosen);
        return;
      }
    }
    for (final code in ['ru-RU', 'ru']) {
      final available = await _tts.isLanguageAvailable(code);
      if (available == true || available == 1) {
        await _tts.setLanguage(code);
        return;
      }
    }
    await _tts.setLanguage('ru-RU');
  }
}
