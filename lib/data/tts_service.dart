import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> speakRussian(String text) async {
    try {
      if (!_ready) {
        await _tts.setLanguage('ru-RU');
        await _tts.setSpeechRate(0.42);
        await _tts.setPitch(1);
        _ready = true;
      }
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }
}
