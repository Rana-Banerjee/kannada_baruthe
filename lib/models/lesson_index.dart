class LessonIndexEntry {
  final String lessonId;
  final String title;
  final String file;
  final bool enabled;

  LessonIndexEntry({
    required this.lessonId,
    required this.title,
    required this.file,
    required this.enabled,
  });

  factory LessonIndexEntry.fromJson(Map<String, dynamic> json) {
    return LessonIndexEntry(
      lessonId: json['lesson_id'] as String,
      title: json['title'] as String,
      file: json['file'] as String,
      enabled: json['enabled'] as bool,
    );
  }
}
