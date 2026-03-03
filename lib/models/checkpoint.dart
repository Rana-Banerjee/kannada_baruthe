class Checkpoint {
  final String lessonId;
  final int exerciseIndex;
  final int score;
  final DateTime timestamp;

  Checkpoint({
    required this.lessonId,
    required this.exerciseIndex,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'exercise_index': exerciseIndex,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    return Checkpoint(
      lessonId: json['lesson_id'] as String,
      exerciseIndex: json['exercise_index'] as int,
      score: json['score'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
