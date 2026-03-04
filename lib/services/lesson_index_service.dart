import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson_index.dart';

class LessonIndexService {
  static List<LessonIndexEntry>? _cachedIndex;

  static Future<List<LessonIndexEntry>> loadLessons() async {
    if (_cachedIndex != null) {
      return _cachedIndex!;
    }

    final indexString = await rootBundle.loadString('data/lessons_index.json');
    final index = jsonDecode(indexString) as Map<String, dynamic>;
    final lessons = (index['lessons'] as List).cast<Map<String, dynamic>>();

    _cachedIndex = lessons
        .where((l) => l['enabled'] == true)
        .map((l) => LessonIndexEntry.fromJson(l))
        .toList();

    return _cachedIndex!;
  }

  static void clearCache() {
    _cachedIndex = null;
  }
}
