import 'package:flutter/material.dart';
import '../models/country.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';

class PeriodDetailScreen extends StatelessWidget {
  final Country country;
  final HistoryPeriod period;

  const PeriodDetailScreen({
    super.key,
    required this.country,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: period.accentColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      period.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: period.accentColor),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            period.accentColor.withValues(alpha: 0.3),
                            period.accentColor.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CountryBadge(flagCode: country.flagCode),
                              const SizedBox(width: 8),
                              Text(country.name,
                                  style: AppTheme.label(
                                      size: 12, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(period.title,
                              style: AppTheme.title(
                                  size: 22, color: Colors.white)),
                          Text(period.subtitle,
                              style: AppTheme.body(
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: AppTheme.label(size: 13, color: Colors.white),
                unselectedLabelStyle:
                    AppTheme.label(size: 13, color: Colors.white60),
                tabs: const [
                  Tab(text: '概览'),
                  Tab(text: '政治'),
                  Tab(text: '经济社会'),
                  Tab(text: '大事记'),
                  Tab(text: '人物文化'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(period: period),
              _TextTab(period: period, title: '政治格局', content: period.politics,
                  icon: Icons.account_balance_rounded),
              _EconomySocietyTab(period: period),
              _EventsTab(period: period),
              _FiguresCultureTab(period: period),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final HistoryPeriod period;
  const _OverviewTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _YearBanner(period: period),
          const SizedBox(height: 20),
          _SectionTitle(title: '阶段概述', icon: Icons.auto_stories_rounded),
          const SizedBox(height: 10),
          Text(period.summary,
              style: AppTheme.body(size: 14, height: 1.8)),
          const SizedBox(height: 20),
          _SectionTitle(title: '历史背景', icon: Icons.history_rounded),
          const SizedBox(height: 10),
          _TextBlock(text: period.background, color: period.accentColor),
          const SizedBox(height: 20),
          _SectionTitle(title: '历史影响与遗产', icon: Icons.history_edu_rounded),
          const SizedBox(height: 10),
          _TextBlock(text: period.legacy, color: period.accentColor),
          const SizedBox(height: 24),
          _QuickStats(period: period),
        ],
      ),
    );
  }
}

class _EconomySocietyTab extends StatelessWidget {
  final HistoryPeriod period;
  const _EconomySocietyTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '经济发展', icon: Icons.trending_up_rounded),
          const SizedBox(height: 10),
          _TextBlock(text: period.economy, color: period.accentColor),
          const SizedBox(height: 24),
          _SectionTitle(title: '社会生活', icon: Icons.groups_rounded),
          const SizedBox(height: 10),
          _TextBlock(text: period.society, color: period.accentColor),
        ],
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  final HistoryPeriod period;
  final String title;
  final String content;
  final IconData icon;
  const _TextTab({
    required this.period,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, icon: icon),
          const SizedBox(height: 12),
          _TextBlock(text: content, color: period.accentColor),
        ],
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  final HistoryPeriod period;
  const _EventsTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: period.events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final e = period.events[index];
        return _EventTile(event: e, color: period.accentColor, index: index + 1);
      },
    );
  }
}

class _FiguresCultureTab extends StatelessWidget {
  final HistoryPeriod period;
  const _FiguresCultureTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '关键人物', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          ...period.keyFigures.map(
            (f) => _FigureCard(figure: f, color: period.accentColor),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: '文化成就', icon: Icons.museum_rounded),
          const SizedBox(height: 12),
          ...period.culturalHighlights.map(
            (c) => _CultureCard(item: c, color: period.accentColor),
          ),
        ],
      ),
    );
  }
}

class _YearBanner extends StatelessWidget {
  final HistoryPeriod period;
  const _YearBanner({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            period.accentColor.withValues(alpha: 0.15),
            period.accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: period.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.date_range_rounded, color: period.accentColor, size: 20),
          const SizedBox(width: 10),
          Text(period.yearRange,
              style: AppTheme.year(size: 16, color: period.accentColor)),
          if (period.endYear != null) ...[
            const SizedBox(width: 12),
            Text('约 ${period.durationYears} 年',
                style: AppTheme.label(size: 11, color: period.accentColor)),
          ],
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final HistoryPeriod period;
  const _QuickStats({required this.period});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
            icon: Icons.event_note_rounded,
            label: '${period.events.length} 个事件',
            color: period.accentColor),
        const SizedBox(width: 8),
        _StatChip(
            icon: Icons.person_rounded,
            label: '${period.keyFigures.length} 位人物',
            color: period.accentColor),
        const SizedBox(width: 8),
        _StatChip(
            icon: Icons.museum_rounded,
            label: '${period.culturalHighlights.length} 项文化',
            color: period.accentColor),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: AppTheme.label(size: 10, color: color),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.title(size: 17)),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String text;
  final Color color;
  const _TextBlock({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(text, style: AppTheme.body(size: 14, height: 1.85)),
    );
  }
}

class _EventTile extends StatelessWidget {
  final HistoryEvent event;
  final Color color;
  final int index;
  const _EventTile(
      {required this.event, required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('$index',
                  style: AppTheme.year(size: 11, color: color)),
            ),
            Container(
              width: 2,
              height: 8,
              color: color.withValues(alpha: 0.2),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(event.year,
                          style: AppTheme.year(size: 11, color: color)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(event.title,
                          style: AppTheme.title(size: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(event.description,
                    style: AppTheme.body(size: 13, height: 1.7)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FigureCard extends StatelessWidget {
  final KeyFigure figure;
  final Color color;
  const _FigureCard({required this.figure, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(figure.name.characters.first,
                    style: AppTheme.title(size: 14, color: color)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(figure.name, style: AppTheme.title(size: 15)),
                    Text(figure.role,
                        style: AppTheme.label(size: 11, color: color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(figure.description,
              style: AppTheme.body(size: 13, height: 1.65)),
        ],
      ),
    );
  }
}

class _CultureCard extends StatelessWidget {
  final CulturalItem item;
  final Color color;
  const _CultureCard({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTheme.title(size: 14, color: color)),
          const SizedBox(height: 8),
          Text(item.description,
              style: AppTheme.body(size: 13, height: 1.65)),
        ],
      ),
    );
  }
}
