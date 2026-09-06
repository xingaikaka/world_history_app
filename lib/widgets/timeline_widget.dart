import 'package:flutter/material.dart';
import '../models/country.dart';
import '../theme/app_theme.dart';

class TimelineWidget extends StatelessWidget {
  final List<HistoryPeriod> periods;
  final void Function(HistoryPeriod period) onPeriodTap;

  const TimelineWidget({
    super.key,
    required this.periods,
    required this.onPeriodTap,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<HistoryPeriod>.from(periods)
      ..sort((a, b) => a.startYear.compareTo(b.startYear));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final period = sorted[index];
        final isLast = index == sorted.length - 1;
        return _TimelineNode(
          period: period,
          isLast: isLast,
          onTap: () => onPeriodTap(period),
        );
      },
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final HistoryPeriod period;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineNode({
    required this.period,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: period.accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surface, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: period.accentColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            period.accentColor.withValues(alpha: 0.6),
                            AppTheme.timelineLine,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: _PeriodCard(period: period, onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final HistoryPeriod period;
  final VoidCallback onTap;

  const _PeriodCard({required this.period, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [
              BoxShadow(
                color: period.accentColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                child: Stack(
                  children: [
                    Image.asset(
                      period.imageAsset,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: period.accentColor.withValues(alpha: 0.15),
                        child: Icon(Icons.landscape_rounded,
                            color: period.accentColor, size: 40),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: Text(
                        period.yearRange,
                        style: AppTheme.year(size: 12, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: period.accentColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${period.events.length} 事件',
                          style: AppTheme.label(size: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(period.title, style: AppTheme.title(size: 16)),
                    const SizedBox(height: 4),
                    Text(
                      period.subtitle,
                      style: AppTheme.body(size: 12, color: period.accentColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      period.summary,
                      style: AppTheme.body(size: 13, height: 1.55),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    if (period.keyFigures.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: period.keyFigures.take(4).map((figure) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: period.accentColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: period.accentColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: period.accentColor.withValues(alpha: 0.15),
                                  child: Text(
                                    figure.name.characters.first,
                                    style: AppTheme.label(size: 8, color: period.accentColor),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  figure.name,
                                  style: AppTheme.label(size: 10, color: period.accentColor),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 14, color: period.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          '点击查看详情',
                          style: AppTheme.label(
                              size: 11, color: period.accentColor),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: period.accentColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
