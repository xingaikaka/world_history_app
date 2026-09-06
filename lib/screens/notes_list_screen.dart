import 'package:flutter/material.dart';

import '../services/achievements_service.dart';
import '../services/figure_link_service.dart';
import '../services/notes_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import 'figure_detail_screen.dart';
import 'period_detail_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text('我的笔记', style: AppTheme.title(size: 18)),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: NotesService.instance,
        builder: (context, _) {
          final entries = NotesService.instance.allEntries;
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sticky_note_2_outlined,
                        size: 56,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('还没有笔记',
                        style: AppTheme.title(size: 17, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      '在人物详情或历史事件中点击笔记图标即可记录',
                      style: AppTheme.body(size: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final country = entry.country;
              final period = entry.period;
              if (country == null || period == null) {
                return const SizedBox.shrink();
              }
              final color = period.accentColor;
              final isFigure = entry.kind == NoteTargetKind.figure;

              return Material(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (isFigure) {
                      final figure = FigureLinkService.resolveFigure(
                        country.id,
                        period,
                        entry.targetTitle,
                      );
                      if (figure == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FigureDetailScreen(
                            country: country,
                            period: period,
                            figure: figure,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PeriodDetailScreen(
                            country: country,
                            period: period,
                            initialTabIndex: PeriodDetailScreen.eventsTabIndex,
                            highlightEventTitle: entry.targetTitle,
                          ),
                        ),
                      );
                    }
                  },
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
                            CountryBadge(flagCode: country.flagCode),
                            const SizedBox(width: 8),
                            Text(isFigure ? '人物笔记' : '事件笔记',
                                style: AppTheme.label(size: 10, color: color)),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                size: 18, color: AppTheme.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(entry.targetTitle, style: AppTheme.title(size: 15)),
                        Text('${country.name} · ${period.title}',
                            style: AppTheme.body(size: 11)),
                        const SizedBox(height: 8),
                        Text(
                          entry.text,
                          style: AppTheme.body(size: 13, height: 1.55),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementsService.evaluate();
    final unlocked = achievements.where((a) => a.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('读史成就', style: AppTheme.title(size: 16)),
            const Spacer(),
            Text('$unlocked / ${achievements.length}',
                style: AppTheme.label(size: 11, color: AppTheme.primary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: achievements.map((achievement) {
            return Container(
              width: (MediaQuery.of(context).size.width - 50) / 2,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: achievement.unlocked
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: achievement.unlocked
                      ? AppTheme.primary.withValues(alpha: 0.3)
                      : AppTheme.divider,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    achievement.emoji,
                    style: TextStyle(
                      fontSize: 22,
                      color: achievement.unlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: AppTheme.title(
                            size: 13,
                            color: achievement.unlocked
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: AppTheme.body(size: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
