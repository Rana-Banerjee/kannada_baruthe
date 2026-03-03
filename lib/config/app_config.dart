import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final String appName;
  final String appVersion;
  final String primaryColor;
  final String secondaryColor;
  final String correctColor;
  final String wrongColor;
  final String backgroundColor;
  final String textColorPrimary;
  final double sizeWordScript;
  final double sizeWordRoman;
  final double sizeTileLabel;
  final String kannadaFont;
  final int numTiles;
  final int tileColumns;
  final bool randomizeTileOrder;
  final bool autoPlayAudio;
  final bool showRoman;
  final bool ttsEnabled;
  final String ttsLanguageCode;
  final double ttsRate;
  final String correctMessage;
  final String wrongMessage;
  final String continueLabel;

  AppConfig({
    required this.appName,
    required this.appVersion,
    required this.primaryColor,
    required this.secondaryColor,
    required this.correctColor,
    required this.wrongColor,
    required this.backgroundColor,
    required this.textColorPrimary,
    required this.sizeWordScript,
    required this.sizeWordRoman,
    required this.sizeTileLabel,
    required this.kannadaFont,
    required this.numTiles,
    required this.tileColumns,
    required this.randomizeTileOrder,
    required this.autoPlayAudio,
    required this.showRoman,
    required this.ttsEnabled,
    required this.ttsLanguageCode,
    required this.ttsRate,
    required this.correctMessage,
    required this.wrongMessage,
    required this.continueLabel,
  });

  static AppConfig? _instance;
  static AppConfig get instance => _instance!;

  static Future<void> load() async {
    final jsonString = await rootBundle.loadString('config/app_config.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    
    _instance = AppConfig(
      appName: json['app']['name'] as String,
      appVersion: json['app']['version'] as String,
      primaryColor: json['theme']['primary_color'] as String,
      secondaryColor: json['theme']['secondary_color'] as String,
      correctColor: json['theme']['correct_color'] as String,
      wrongColor: json['theme']['wrong_color'] as String,
      backgroundColor: json['theme']['background_color'] as String,
      textColorPrimary: json['theme']['text_color_primary'] as String,
      sizeWordScript: (json['fonts']['size_word_script'] as num).toDouble(),
      sizeWordRoman: (json['fonts']['size_word_roman'] as num).toDouble(),
      sizeTileLabel: (json['fonts']['size_tile_label'] as num).toDouble(),
      kannadaFont: json['fonts']['kannada_font'] as String,
      numTiles: json['exercise']['num_tiles'] as int,
      tileColumns: json['exercise']['tile_columns'] as int,
      randomizeTileOrder: json['exercise']['randomize_tile_order'] as bool,
      autoPlayAudio: json['exercise']['auto_play_audio'] as bool,
      showRoman: json['exercise']['show_roman'] as bool,
      ttsEnabled: json['audio']['tts_enabled'] as bool,
      ttsLanguageCode: json['audio']['tts_language_code'] as String,
      ttsRate: (json['audio']['tts_rate'] as num).toDouble(),
      correctMessage: json['feedback_banner']['correct_message'] as String,
      wrongMessage: json['feedback_banner']['wrong_message'] as String,
      continueLabel: json['feedback_banner']['continue_label'] as String,
    );
  }
}
