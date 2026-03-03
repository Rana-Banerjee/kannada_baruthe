import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/progress_service.dart';

class CompleteScreen extends StatelessWidget {
  const CompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final score = args?['score'] as int? ?? 0;
    final total = args?['total'] as int? ?? 0;
    
    final config = AppConfig.instance;
    
    return Scaffold(
      backgroundColor: _parseColor(config.backgroundColor),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration icon
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: _parseColor(config.primaryColor),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Lesson Complete!',
                  key: const Key('kl_complete_title'),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _parseColor(config.textColorPrimary),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: _parseColor(config.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _parseColor(config.primaryColor),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    key: const Key('kl_complete_score'),
                    '$score / $total correct',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _parseColor(config.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Back to home button
                ElevatedButton(
                  key: const Key('kl_complete_home_btn'),
                  onPressed: () async {
                    // Ensure checkpoint is cleared
                    await ProgressService().clearCheckpoint();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _parseColor(config.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}
