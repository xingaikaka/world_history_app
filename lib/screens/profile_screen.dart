import 'package:flutter/material.dart';

import '../navigation/main_tab_controller.dart';
import '../services/favorites_service.dart';
import '../services/notes_service.dart';
import '../services/reading_goal_service.dart';
import '../services/reading_progress_service.dart';
import '../services/reading_streak_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import 'notes_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.headerDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('学习档案', style: AppTheme.title(size: 17, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: ShareService.shareLearningReport,
            tooltip: '分享档案',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          ReadingProgressService.instance,
          FavoritesService.instance,
          ReadingStreakService.instance,
          ReadingGoalService.instance,
          NotesService.instance,
        ]),
        builder: (context, _) {
          final progress = ReadingProgressService.instance;
          final favorites = FavoritesService.instance;
          final streak = ReadingStreakService.instance;
          final goal = ReadingGoalService.instance;
          final notes = NotesService.instance;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeroCard(
                progress: progress.overallProgress,
                streak: streak.currentStreak,
              ),
              const SizedBox(height: 16),
              _StatGrid(
                items: [
                  _StatItem(label: '已读阶段',
                      value: '${progress.totalVisitedPeriods}/${progress.totalPeriodCount}'),
                  _StatItem(label: '涉足国家', value: '${progress.countriesStartedCount}'),
                  _StatItem(label: '连续阅读', value: '${streak.currentStreak} 天'),
                  _StatItem(label: '最长连续', value: '${streak.longestStreak} 天'),
                  _StatItem(label: '收藏', value: '${favorites.items.length}'),
                  _StatItem(label: '笔记', value: '${notes.noteCount}'),
                ],
              ),
              const SizedBox(height: 20),
              _GoalCard(goal: goal),
              const SizedBox(height: 20),
              const AchievementsSection(),
              const SizedBox(height: 20),
              Text('快捷入口', style: AppTheme.title(size: 16)),
              const SizedBox(height: 12),
              _LinkTile(
                icon: Icons.sticky_note_2_rounded,
                title: '我的笔记',
                subtitle: '${notes.noteCount} 条笔记',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesListScreen()),
                ),
              ),
              _LinkTile(
                icon: Icons.quiz_rounded,
                title: '历史小测验',
                subtitle: '检验读史成果',
                onTap: () => MainTabController.instance.switchTo(MainTab.quiz.tabIndex),
              ),
              _LinkTile(
                icon: Icons.bookmarks_rounded,
                title: '我的收藏',
                subtitle: '${favorites.items.length} 项收藏',
                onTap: () => MainTabController.instance.switchTo(MainTab.favorites.tabIndex),
              ),
              _LinkTile(
                icon: Icons.timeline_rounded,
                title: '世界史年表',
                subtitle: '按年代浏览全球历史事件',
                onTap: () => MainTabController.instance.switchTo(MainTab.chronology.tabIndex),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double progress;
  final int streak;

  const _HeroCard({required this.progress, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2118), Color(0xFF4A3728)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('读史进度',
              style: AppTheme.title(size: 18, color: Colors.white)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}% 总进度',
                style: AppTheme.body(size: 12, color: Colors.white70),
              ),
              if (streak > 0) ...[
                const Spacer(),
                const Icon(Icons.local_fire_department_rounded,
                    size: 16, color: Color(0xFFE65100)),
                const SizedBox(width: 4),
                Text('连续 $streak 天',
                    style: AppTheme.label(size: 11, color: const Color(0xFFE65100))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
}

class _StatGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return Container(
          width: (MediaQuery.of(context).size.width - 50) / 2,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: AppTheme.label(size: 11)),
              const SizedBox(height: 6),
              Text(item.value, style: AppTheme.year(size: 16, color: AppTheme.primary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final ReadingGoalService goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('本周阅读目标', style: AppTheme.title(size: 15)),
              const Spacer(),
              Text(
                goal.isGoalMet ? '已完成 🎉' : '进行中',
                style: AppTheme.label(
                  size: 11,
                  color: goal.isGoalMet ? const Color(0xFF2E7D32) : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.weeklyProgress,
              minHeight: 6,
              backgroundColor: AppTheme.divider,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${goal.thisWeekCount} / ${goal.weeklyTarget} 个历史阶段',
            style: AppTheme.body(size: 13),
          ),
          const SizedBox(height: 12),
          Text('调整目标', style: AppTheme.label(size: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 3, 5, 7].map((target) {
              final selected = goal.weeklyTarget == target;
              return ChoiceChip(
                label: Text('每周 $target 个', style: AppTheme.label(size: 11)),
                selected: selected,
                onSelected: (_) => goal.setWeeklyTarget(target),
                selectedColor: AppTheme.primary.withValues(alpha: 0.15),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.title(size: 14)),
                      Text(subtitle, style: AppTheme.body(size: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
