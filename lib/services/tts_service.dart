import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    await _flutterTts.setLanguage('kn-IN');
    await _flutterTts.setSpeechRate(0.85);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _initialized = true;
  }

  static Future<void> speak(String text) async {
    if (!_initialized) {
      await initialize();
    }
    await _flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
