import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/exercise.dart';
import '../services/audio_service.dart';

class WordHeader extends StatelessWidget {
  final Word word;
  final String? audioFile;
  final String ttsText;

  const WordHeader({
    super.key,
    required this.word,
    this.audioFile,
    required this.ttsText,
  });

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    
    return Column(
      children: [
        // Kannada script
        Text(
          word.kannadaScript,
          key: const Key('kl_word_script'),
          style: TextStyle(
            fontSize: config.sizeWordScript,
            fontWeight: FontWeight.bold,
            color: _parseColor(config.textColorPrimary),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        // Romanized with audio button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (config.showRoman) ...[
              Text(
                word.kannadaRoman,
                key: const Key('kl_word_roman'),
                style: TextStyle(
                  fontSize: config.sizeWordRoman,
                  color: _parseColor(config.textColorPrimary).withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 12),
            ],
            // Audio button
            IconButton(
              key: const Key('kl_word_audio_btn'),
              onPressed: () => AudioService.play(audioFile, ttsText),
              icon: Icon(
                Icons.volume_up,
                color: _parseColor(config.secondaryColor),
                size: 28,
              ),
              tooltip: 'Play audio',
            ),
          ],
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}
