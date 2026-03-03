class Tile {
  final String tileId;
  final String englishLabel;
  final String image;
  final bool isCorrect;

  Tile({
    required this.tileId,
    required this.englishLabel,
    required this.image,
    required this.isCorrect,
  });

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      tileId: json['tile_id'] as String,
      englishLabel: json['english_label'] as String,
      image: json['image'] as String,
      isCorrect: json['is_correct'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tile_id': tileId,
      'english_label': englishLabel,
      'image': image,
      'is_correct': isCorrect,
    };
  }
}
