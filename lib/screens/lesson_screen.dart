import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/checkpoint.dart';
import '../models/exercise.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../widgets/word_header.dart';
import '../widgets/tile_grid.dart';
import '../widgets/feedback_banner.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Lesson? _lesson;
  int _currentExerciseIndex = 0;
  int _score = 0;
  int? _selectedTileIndex;
  bool _showFeedback = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final checkpoint = ModalRoute.of(context)?.settings.arguments as Checkpoint?;
      
      // Load the lesson
      final lesson = await LessonService.loadFirstLesson();
      
      // Resume from checkpoint if provided
      final startIndex = checkpoint?.exerciseIndex ?? 0;
      final startScore = checkpoint?.score ?? 0;
      
      setState(() {
        _lesson = lesson;
        _currentExerciseIndex = startIndex;
        _score = startScore;
        _isLoading = false;
      });

      // Auto-play audio if configured
      final config = AppConfig.instance;
      if (config.autoPlayAudio && !_showFeedback) {
        _playCurrentAudio();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load lesson: $e';
        _isLoading = false;
      });
    }
  }

  void _playCurrentAudio() {
    if (_lesson == null) return;
    final exercise = _lesson!.exercises[_currentExerciseIndex];
    AudioService.play(exercise.audio.file, exercise.audio.ttsText);
  }

  void _onTileTap(int tileIndex) {
    if (_showFeedback || _lesson == null) return;

    final exercise = _lesson!.exercises[_currentExerciseIndex];
    final isCorrect = exercise.tiles[tileIndex].isCorrect;

    setState(() {
      _selectedTileIndex = tileIndex;
      _showFeedback = true;
      
      if (isCorrect) {
        _score++;
      }
    });

    // Save checkpoint after answering
    _saveCheckpoint();
  }

  Future<void> _saveCheckpoint() async {
    if (_lesson == null) return;
    
    final checkpoint = Checkpoint(
      lessonId: _lesson!.lessonId,
      exerciseIndex: _currentExerciseIndex,
      score: _score,
      timestamp: DateTime.now(),
    );
    
    await ProgressService().saveCheckpoint(checkpoint);
  }

  void _onContinue() {
    if (_lesson == null) return;

    if (_currentExerciseIndex < _lesson!.exercises.length - 1) {
      // Move to next exercise
      setState(() {
        _currentExerciseIndex++;
        _selectedTileIndex = null;
        _showFeedback = false;
      });
      
      // Auto-play audio for next exercise
      final config = AppConfig.instance;
      if (config.autoPlayAudio) {
        _playCurrentAudio();
      }
    } else {
      // Lesson complete
      _completeLesson();
    }
  }

  Future<void> _completeLesson() async {
    // Clear checkpoint
    await ProgressService().clearCheckpoint();
    
    // Navigate to completion screen with score
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/complete',
        arguments: {
          'score': _score,
          'total': _lesson?.exercises.length ?? 0,
        },
      );
    }
  }

  int? _getCorrectTileIndex() {
    if (_lesson == null) return null;
    final exercise = _lesson!.exercises[_currentExerciseIndex];
    for (int i = 0; i < exercise.tiles.length; i++) {
      if (exercise.tiles[i].isCorrect) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    
    return Scaffold(
      backgroundColor: _parseColor(config.backgroundColor),
      appBar: AppBar(
        backgroundColor: _parseColor(config.backgroundColor),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _parseColor(config.textColorPrimary)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _lesson != null
          ? Text(
              key: const Key('kl_lesson_progress'),
              '${_currentExerciseIndex + 1} / ${_lesson!.exercises.length}',
              style: TextStyle(
                color: _parseColor(config.textColorPrimary),
                fontWeight: FontWeight.bold,
              ),
            )
          : const Text('Lesson'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_lesson == null || _lesson!.exercises.isEmpty) {
      return const Center(child: Text('No exercises available'));
    }

    final exercise = _lesson!.exercises[_currentExerciseIndex];
    final correctTileIndex = _getCorrectTileIndex();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentExerciseIndex + 1) / _lesson!.exercises.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _parseColor(AppConfig.instance.primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            
            // Word header with audio
            WordHeader(
              word: exercise.word,
              audioFile: exercise.audio.file,
              ttsText: exercise.audio.ttsText,
            ),
            const SizedBox(height: 32),
            
            // Tile grid
            Expanded(
              child: TileGrid(
                tiles: exercise.tiles,
                selectedTileIndex: _selectedTileIndex,
                correctTileIndex: correctTileIndex,
                showFeedback: _showFeedback,
                onTileTap: _onTileTap,
              ),
            ),
            
            // Feedback banner (shown after selection)
            if (_showFeedback)
              FeedbackBanner(
                isCorrect: exercise.tiles[_selectedTileIndex!].isCorrect,
                onContinue: _onContinue,
              ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }
}
