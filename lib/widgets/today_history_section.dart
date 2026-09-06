import 'package:flutter/material.dart';
import '../services/today_in_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../screens/period_detail_screen.dart';

class TodayHistorySection extends StatelessWidget {
  const TodayHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hits = TodayInHistoryService.forToday();
    final hasDateMatch = hits.any((h) => h.dateMatched);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                '历史上的今天 · ${now.month}月${now.day}日',
                style: AppTheme.title(size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasDateMatch ? '以下事件发生在历史上的今天' : '今日推荐历史事件',
            style: AppTheme.body(size: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          ...hits.map((hit) => _TodayEventCard(hit: hit)),
        ],
      ),
    );
  }
}

class _TodayEventCard extends StatelessWidget {
  final TodayHistoryHit hit;

  const _TodayEventCard({required this.hit});

  @override
  Widget build(BuildContext context) {
    final color = hit.period.accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PeriodDetailScreen(
                country: hit.country,
                period: hit.period,
                initialTabIndex: PeriodDetailScreen.eventsTabIndex,
                highlightEventTitle: hit.event.title,
              ),
            ),
          ),
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
                    CountryBadge(flagCode: hit.country.flagCode),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${hit.country.name} · ${hit.period.title}',
                        style: AppTheme.label(size: 11, color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hit.dateMatched)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('今日', style: AppTheme.label(size: 9, color: color)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(hit.event.year,
                          style: AppTheme.year(size: 11, color: color)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(hit.event.title, style: AppTheme.title(size: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  hit.event.description,
                  style: AppTheme.body(size: 12, height: 1.55),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
