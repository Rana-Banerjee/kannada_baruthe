import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/checkpoint.dart';
import '../services/progress_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Checkpoint? _checkpoint;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckpoint();
  }

  Future<void> _loadCheckpoint() async {
    final checkpoint = await ProgressService().loadCheckpoint();
    setState(() {
      _checkpoint = checkpoint;
      _isLoading = false;
    });
  }

  void _startLesson() {
    Navigator.pushNamed(context, '/select');
  }

  void _resumeLesson() {
    if (_checkpoint != null) {
      Navigator.pushNamed(
        context,
        '/lesson',
        arguments: _checkpoint!.lessonId,
      );
    }
  }

  void _restartLesson() async {
    await ProgressService().clearCheckpoint();
    setState(() {
      _checkpoint = null;
    });
    _startLesson();
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;

    return Scaffold(
      backgroundColor: _parseColor(config.backgroundColor),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Name
                  Text(
                    config.appName,
                    key: const Key('kl_home_app_name'),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _parseColor(config.primaryColor),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn Kannada',
                    style: TextStyle(
                      fontSize: 20,
                      color: _parseColor(config.textColorPrimary),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  if (_isLoading)
                    const CircularProgressIndicator()
                  else if (_checkpoint != null)
                    _buildResumeSection(config)
                  else
                    _buildStartSection(config),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartSection(AppConfig config) {
    return ElevatedButton(
      key: const Key('kl_home_start_btn'),
      onPressed: _startLesson,
      style: ElevatedButton.styleFrom(
        backgroundColor: _parseColor(config.primaryColor),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Start Lesson',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResumeSection(AppConfig config) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _parseColor(config.secondaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _parseColor(config.secondaryColor),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Resume: Lesson 1',
                key: const Key('kl_home_resume_label'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _parseColor(config.textColorPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ex ${_checkpoint!.exerciseIndex + 1}',
                style: TextStyle(
                  fontSize: 18,
                  color: _parseColor(config.textColorPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: const Key('kl_home_resume_btn'),
              onPressed: _resumeLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: _parseColor(config.primaryColor),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Resume',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              key: const Key('kl_home_restart_btn'),
              onPressed: _restartLesson,
              style: OutlinedButton.styleFrom(
                foregroundColor: _parseColor(config.wrongColor),
                side:
                    BorderSide(color: _parseColor(config.wrongColor), width: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Restart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}
