import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_select_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/complete_screen.dart';

class KannadaLearnApp extends StatelessWidget {
  const KannadaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: _createMaterialColor(
          _parseColor(config.primaryColor),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/select': (context) => const LessonSelectScreen(),
        '/lesson': (context) => const LessonScreen(),
        '/complete': (context) => const CompleteScreen(),
      },
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }

  MaterialColor _createMaterialColor(Color color) {
    return MaterialColor(
      color.value,
      {
        50: color.withOpacity(0.1),
        100: color.withOpacity(0.2),
        200: color.withOpacity(0.3),
        300: color.withOpacity(0.4),
        400: color.withOpacity(0.5),
        500: color.withOpacity(0.6),
        600: color.withOpacity(0.7),
        700: color.withOpacity(0.8),
        800: color.withOpacity(0.9),
        900: color.withOpacity(1.0),
      },
    );
  }
}
