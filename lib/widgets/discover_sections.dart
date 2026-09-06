import 'package:flutter/material.dart';

import '../navigation/main_tab_controller.dart';
import '../services/discovery_service.dart';
import '../services/favorites_service.dart';
import '../services/reading_progress_service.dart';
import '../services/reading_streak_service.dart';
import '../services/reading_goal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../screens/figure_detail_screen.dart';
import '../screens/period_detail_screen.dart';

class DiscoverTodaySection extends StatefulWidget {
  const DiscoverTodaySection({super.key});

  @override
  State<DiscoverTodaySection> createState() => _DiscoverTodaySectionState();
}

class _DiscoverTodaySectionState extends State<DiscoverTodaySection> {
  late DiscoveryPick _pick;
  int _shuffleSalt = 0;

  @override
  void initState() {
    super.initState();
    _pick = DiscoveryService.forToday();
  }

  void _shuffle() {
    setState(() {
      _shuffleSalt++;
      _pick = DiscoveryService.randomPick(salt: _shuffleSalt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = _pick.country;
    final period = _pick.period;
    final figure = _pick.spotlightFigure;
    final color = period.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('今日探索', style: AppTheme.title(size: 16)),
              const Spacer(),
              TextButton.icon(
                onPressed: _shuffle,
                icon: const Icon(Icons.shuffle_rounded, size: 16),
                label: Text('换一换', style: AppTheme.label(size: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_pick.tagline,
              style: AppTheme.body(size: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Material(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PeriodDetailScreen(
                    country: country,
                    period: period,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CountryBadge(flagCode: country.flagCode),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${country.name} · ${period.title}',
                            style: AppTheme.title(size: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(period.subtitle,
                        style: AppTheme.body(size: 12), maxLines: 2),
                    if (figure != null) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FigureDetailScreen(
                              country: country,
                              period: period,
                              figure: figure,
                            ),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: color.withValues(alpha: 0.15),
                                child: Text(
                                  figure.name.characters.first,
                                  style: AppTheme.title(size: 14, color: color),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('推荐人物 · ${figure.name}',
                                        style: AppTheme.title(size: 13)),
                                    Text(figure.role,
                                        style: AppTheme.body(size: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: color),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LearningStatsSection extends StatelessWidget {
  const LearningStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ReadingProgressService.instance,
        FavoritesService.instance,
        ReadingStreakService.instance,
        ReadingGoalService.instance,
      ]),
      builder: (context, _) {
        final progress = ReadingProgressService.instance;
        final favorites = FavoritesService.instance;
        final streak = ReadingStreakService.instance;
        final goal = ReadingGoalService.instance;

        if (progress.totalVisitedPeriods == 0 &&
            favorites.items.isEmpty &&
            streak.currentStreak == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Material(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => MainTabController.instance.switchTo(MainTab.profile.tabIndex),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights_rounded, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text('学习档案', style: AppTheme.title(size: 15)),
                        if (streak.currentStreak > 0) ...[
                          const Spacer(),
                          Icon(Icons.local_fire_department_rounded,
                              size: 16, color: Color(0xFFE65100)),
                          const SizedBox(width: 4),
                          Text('连续 ${streak.currentStreak} 天',
                              style: AppTheme.label(size: 11, color: const Color(0xFFE65100))),
                        ],
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppTheme.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatChip(
                          label: '已读阶段',
                          value:
                              '${progress.totalVisitedPeriods}/${progress.totalPeriodCount}',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: '涉足国家',
                          value: '${progress.countriesStartedCount}',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: '收藏',
                          value: '${favorites.items.length}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '本周 ${goal.thisWeekCount}/${goal.weeklyTarget} 个阶段',
                            style: AppTheme.label(size: 11, color: AppTheme.textSecondary),
                          ),
                        ),
                        Text(
                          goal.isGoalMet ? '目标达成' : '点击查看详情',
                          style: AppTheme.label(
                            size: 10,
                            color: goal.isGoalMet
                                ? const Color(0xFF2E7D32)
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (progress.totalVisitedPeriods > 0) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.overallProgress,
                          minHeight: 6,
                          backgroundColor: AppTheme.divider,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '总阅读进度 ${(progress.overallProgress * 100).toStringAsFixed(1)}%',
                        style: AppTheme.label(size: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: AppTheme.year(size: 14, color: AppTheme.primary)),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.label(size: 10)),
          ],
        ),
      ),
    );
  }
}
