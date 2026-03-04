import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/lesson_index.dart';
import '../services/lesson_index_service.dart';

class LessonSelectScreen extends StatefulWidget {
  const LessonSelectScreen({super.key});

  @override
  State<LessonSelectScreen> createState() => _LessonSelectScreenState();
}

class _LessonSelectScreenState extends State<LessonSelectScreen> {
  List<LessonIndexEntry> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await LessonIndexService.loadLessons();
    setState(() {
      _lessons = lessons;
      _isLoading = false;
    });
  }

  void _selectLesson(LessonIndexEntry lesson) {
    Navigator.pushNamed(context, '/lesson', arguments: lesson.lessonId);
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;

    return Scaffold(
      backgroundColor: _parseColor(config.backgroundColor),
      appBar: AppBar(
        backgroundColor: _parseColor(config.primaryColor),
        foregroundColor: Colors.white,
        title: const Text('Select Lesson'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _buildLessonList(config),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonList(AppConfig config) {
    return ListView.separated(
      itemCount: _lessons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        return _buildLessonCard(lesson, config);
      },
    );
  }

  Widget _buildLessonCard(LessonIndexEntry lesson, AppConfig config) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('kl_lesson_select_${lesson.lessonId}'),
        onTap: () => _selectLesson(lesson),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _parseColor(config.secondaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _parseColor(config.secondaryColor),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _parseColor(config.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${_lessons.indexOf(lesson) + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _parseColor(config.textColorPrimary),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _parseColor(config.textColorPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
