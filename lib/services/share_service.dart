import 'package:share_plus/share_plus.dart';

import '../models/country.dart';
import 'favorites_service.dart';
import 'notes_service.dart';
import 'reading_goal_service.dart';
import 'reading_progress_service.dart';
import 'reading_streak_service.dart';

class ShareService {
  ShareService._();

  static const _appName = '万国史鉴';

  static Future<void> shareFigure({
    required Country country,
    required HistoryPeriod period,
    required KeyFigure figure,
  }) async {
    final text = '''
【$_appName · 历史人物】

${figure.name}（${figure.role}）
${country.name} · ${period.title}

${figure.description}

—— 来自 $_appName 历史百科
''';
    await Share.share(text.trim(), subject: '${figure.name} · $_appName');
  }

  static Future<void> shareEvent({
    required Country country,
    required HistoryPeriod period,
    required HistoryEvent event,
  }) async {
    final text = '''
【$_appName · 历史事件】

${event.year} · ${event.title}
${country.name} · ${period.title}

${event.description}

—— 来自 $_appName 历史百科
''';
    await Share.share(text.trim(), subject: '${event.title} · $_appName');
  }

  static Future<void> shareLearningReport() async {
    final progress = ReadingProgressService.instance;
    final favorites = FavoritesService.instance;
    final streak = ReadingStreakService.instance;
    final goal = ReadingGoalService.instance;
    final notes = NotesService.instance;

    final text = '''
【$_appName · 学习档案】

📖 已读阶段：${progress.totalVisitedPeriods} / ${progress.totalPeriodCount}
🌍 涉足国家：${progress.countriesStartedCount} 个
🔥 连续阅读：${streak.currentStreak} 天（最长 ${streak.longestStreak} 天）
📅 本周目标：${goal.thisWeekCount} / ${goal.weeklyTarget} 个阶段
🔖 收藏：${favorites.items.length} 项
📝 笔记：${notes.noteCount} 条

—— 来自 $_appName 历史百科
''';
    await Share.share(text.trim(), subject: '我的学习档案 · $_appName');
  }
}
