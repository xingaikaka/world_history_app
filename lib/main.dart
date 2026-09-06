import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/favorites_service.dart';
import 'services/notes_service.dart';
import 'services/reading_goal_service.dart';
import 'services/reading_progress_service.dart';
import 'services/reading_streak_service.dart';
import 'services/search_history_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    FavoritesService.instance.load(),
    ReadingProgressService.instance.load(),
    SearchHistoryService.instance.load(),
    ReadingStreakService.instance.load(),
    NotesService.instance.load(),
    ReadingGoalService.instance.load(),
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const WorldHistoryApp());
}

class WorldHistoryApp extends StatelessWidget {
  const WorldHistoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '万国史鉴',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainShell(),
    );
  }
}
