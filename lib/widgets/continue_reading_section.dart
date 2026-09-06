import 'package:flutter/material.dart';

import '../services/reading_progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../screens/period_detail_screen.dart';

class ContinueReadingSection extends StatelessWidget {
  const ContinueReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ReadingProgressService.instance;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final recent = progress.recentEntries(limit: 3);
        if (recent.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_edu_rounded, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text('继续阅读', style: AppTheme.title(size: 16)),
                  const Spacer(),
                  Text(
                    '已读 ${progress.totalVisitedPeriods} 个阶段',
                    style: AppTheme.label(size: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recent.map((entry) {
                final country = entry.country;
                final period = entry.period;
                if (country == null || period == null) return const SizedBox.shrink();
                final color = period.accentColor;
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
                            country: country,
                            period: period,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            CountryBadge(flagCode: country.flagCode),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${country.name} · ${period.title}',
                                    style: AppTheme.title(size: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    period.subtitle,
                                    style: AppTheme.body(size: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: color),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
