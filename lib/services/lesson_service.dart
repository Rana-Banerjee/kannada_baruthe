import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson.dart';

class LessonService {
  static Lesson? _cachedLesson;

  static Future<Lesson> loadLesson(String lessonId) async {
    if (_cachedLesson != null && _cachedLesson!.lessonId == lessonId) {
      return _cachedLesson!;
    }

    final path = 'data/lessons/$lessonId.json';
    final jsonString = await rootBundle.loadString(path);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    
    _cachedLesson = Lesson.fromJson(json);
    return _cachedLesson!;
  }

  static Future<Lesson> loadFirstLesson() async {
    final indexString = await rootBundle.loadString('data/lessons_index.json');
    final index = jsonDecode(indexString) as Map<String, dynamic>;
    final lessons = (index['lessons'] as List).cast<Map<String, dynamic>>();
    
    final firstEnabled = lessons.firstWhere(
      (l) => l['enabled'] == true,
      orElse: () => lessons.first,
    );
    
    final lessonId = firstEnabled['lesson_id'] as String;
    return loadLesson(lessonId);
  }
}
