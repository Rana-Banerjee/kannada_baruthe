import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import 'tts_service.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> play(String? audioFile, String ttsText) async {
    if (_isPlaying) {
      await stop();
    }

    final config = AppConfig.instance;
    
    // Try to play file audio if available and exists
    if (audioFile != null && config.ttsEnabled) {
      try {
        // Check if asset exists by trying to load it
        await rootBundle.load(audioFile);
        await _audioPlayer.play(AssetSource(audioFile.replaceFirst('assets/', '')));
        _isPlaying = true;
        return;
      } catch (e) {
        // File doesn't exist, fall through to TTS
      }
    }
    
    // Fallback to TTS
    if (config.ttsEnabled) {
      await TtsService.speak(ttsText);
      _isPlaying = true;
    }
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
    await TtsService.stop();
    _isPlaying = false;
  }

  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
