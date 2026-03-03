import 'tile.dart';

class Word {
  final String kannadaScript;
  final String kannadaRoman;
  final String english;

  Word({
    required this.kannadaScript,
    required this.kannadaRoman,
    required this.english,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      kannadaScript: json['kannada_script'] as String,
      kannadaRoman: json['kannada_roman'] as String,
      english: json['english'] as String,
    );
  }
}

class Audio {
  final String? file;
  final String ttsText;

  Audio({
    this.file,
    required this.ttsText,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      file: json['file'] as String?,
      ttsText: json['tts_text'] as String,
    );
  }
}

class Exercise {
  final String exerciseId;
  final String exerciseType;
  final Word word;
  final Audio audio;
  final List<Tile> tiles;

  Exercise({
    required this.exerciseId,
    required this.exerciseType,
    required this.word,
    required this.audio,
    required this.tiles,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exercise_id'] as String,
      exerciseType: json['exercise_type'] as String,
      word: Word.fromJson(json['word'] as Map<String, dynamic>),
      audio: Audio.fromJson(json['audio'] as Map<String, dynamic>),
      tiles: (json['tiles'] as List)
          .map((t) => Tile.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Tile? getCorrectTile() {
    try {
      return tiles.firstWhere((t) => t.isCorrect);
    } catch (e) {
      return null;
    }
  }
}
