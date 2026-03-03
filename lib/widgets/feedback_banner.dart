import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onContinue;

  const FeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    
    final backgroundColor = isCorrect 
      ? _parseColor(config.correctColor).withOpacity(0.1)
      : _parseColor(config.wrongColor).withOpacity(0.1);
    
    final borderColor = isCorrect 
      ? _parseColor(config.correctColor)
      : _parseColor(config.wrongColor);
    
    final message = isCorrect 
      ? config.correctMessage 
      : config.wrongMessage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                color: borderColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                message,
                key: const Key('kl_banner_message'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('kl_banner_continue_btn'),
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: borderColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              config.continueLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}
