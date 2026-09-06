import 'favorites_service.dart';
import 'notes_service.dart';
import 'reading_goal_service.dart';
import 'reading_progress_service.dart';
import 'reading_streak_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlocked,
  });
}

class AchievementsService {
  AchievementsService._();

  static List<Achievement> evaluate() {
    final progress = ReadingProgressService.instance;
    final streak = ReadingStreakService.instance;
    final favorites = FavoritesService.instance;
    final notes = NotesService.instance;
    final goal = ReadingGoalService.instance;

    bool unlocked(String id) => switch (id) {
          'first_read' => progress.totalVisitedPeriods >= 1,
          'reader_10' => progress.totalVisitedPeriods >= 10,
          'reader_30' => progress.totalVisitedPeriods >= 30,
          'countries_3' => progress.countriesStartedCount >= 3,
          'countries_8' => progress.countriesStartedCount >= 8,
          'streak_3' => streak.longestStreak >= 3,
          'streak_7' => streak.longestStreak >= 7,
          'collector' => favorites.items.length >= 5,
          'note_taker' => notes.noteCount >= 1,
          'weekly_goal' => goal.isGoalMet,
          _ => false,
        };

    final defs = [
      ('first_read', '初涉史海', '阅读第一个历史阶段', '📖'),
      ('reader_10', '勤勉读史', '累计阅读 10 个阶段', '📚'),
      ('reader_30', '博古通今', '累计阅读 30 个阶段', '🏛️'),
      ('countries_3', '三国游历', '涉足 3 个国家', '🌍'),
      ('countries_8', '环球史探', '涉足 8 个国家', '🗺️'),
      ('streak_3', '三日不辍', '连续阅读 3 天', '🔥'),
      ('streak_7', '一周坚持', '连续阅读 7 天', '⭐'),
      ('collector', '收藏达人', '收藏 5 条内容', '🔖'),
      ('note_taker', '笔耕不辍', '写下第一条笔记', '📝'),
      ('weekly_goal', '本周达标', '完成本周阅读目标', '🎯'),
    ];

    return defs
        .map(
          (d) => Achievement(
            id: d.$1,
            title: d.$2,
            description: d.$3,
            emoji: d.$4,
            unlocked: unlocked(d.$1),
          ),
        )
        .toList();
  }

  static int get unlockedCount => evaluate().where((a) => a.unlocked).length;
}
