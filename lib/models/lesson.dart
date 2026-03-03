import 'exercise.dart';

class Lesson {
  final String lessonId;
  final String lessonTitle;
  final List<Exercise> exercises;

  Lesson({
    required this.lessonId,
    required this.lessonTitle,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lesson_id'] as String,
      lessonTitle: json['lesson_title'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalExercises => exercises.length;
}
