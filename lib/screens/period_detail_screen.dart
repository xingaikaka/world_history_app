import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/favorites_service.dart';
import '../services/figure_link_service.dart';
import '../services/reading_progress_service.dart';
import '../services/share_service.dart';
import '../services/notes_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../widgets/figure_intro_card.dart';
import '../widgets/note_editor_sheet.dart';
import 'figure_detail_screen.dart';

/// 阶段详情页；[initialTabIndex] 默认 0，大事记 Tab 为 [eventsTabIndex]。
class PeriodDetailScreen extends StatefulWidget {
  static const int eventsTabIndex = 3;

  final Country country;
  final HistoryPeriod period;
  final int initialTabIndex;
  final String? highlightEventTitle;

  const PeriodDetailScreen({
    super.key,
    required this.country,
    required this.period,
    this.initialTabIndex = 0,
    this.highlightEventTitle,
  });

  @override
  State<PeriodDetailScreen> createState() => _PeriodDetailScreenState();
}

class _PeriodDetailScreenState extends State<PeriodDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
    ReadingProgressService.instance.recordPeriodVisit(
      widget.country.id,
      widget.period.id,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  HistoryPeriod? get _previousPeriod {
    final index =
        widget.country.periods.indexWhere((p) => p.id == widget.period.id);
    if (index <= 0) return null;
    return widget.country.periods[index - 1];
  }

  HistoryPeriod? get _nextPeriod {
    final index =
        widget.country.periods.indexWhere((p) => p.id == widget.period.id);
    if (index < 0 || index >= widget.country.periods.length - 1) return null;
    return widget.country.periods[index + 1];
  }

  void _goToPeriod(HistoryPeriod period) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PeriodDetailScreen(
          country: widget.country,
          period: period,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prev = _previousPeriod;
    final next = _nextPeriod;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: widget.period.accentColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (prev != null)
                IconButton(
                  icon: const Icon(Icons.navigate_before_rounded, color: Colors.white),
                  tooltip: '上一阶段',
                  onPressed: () => _goToPeriod(prev),
                ),
              if (next != null)
                IconButton(
                  icon: const Icon(Icons.navigate_next_rounded, color: Colors.white),
                  tooltip: '下一阶段',
                  onPressed: () => _goToPeriod(next),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.period.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: widget.period.accentColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.period.accentColor.withValues(alpha: 0.3),
                          widget.period.accentColor.withValues(alpha: 0.85),
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
                            CountryBadge(flagCode: widget.country.flagCode),
                            const SizedBox(width: 8),
                            Text(widget.country.name,
                                style: AppTheme.label(
                                    size: 12, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.period.title,
                            style: AppTheme.title(
                                size: 22, color: Colors.white)),
                        Text(widget.period.subtitle,
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
              controller: _tabController,
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
                Tab(text: '大事记 · 人物'),
                Tab(text: '人物文化'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(period: widget.period),
            _TextTab(
                period: widget.period,
                title: '政治格局',
                content: widget.period.politics,
                icon: Icons.account_balance_rounded),
            _EconomySocietyTab(period: widget.period),
            _EventsTab(
              country: widget.country,
              period: widget.period,
              highlightEventTitle: widget.highlightEventTitle,
            ),
            _FiguresCultureTab(country: widget.country, period: widget.period),
          ],
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
          Text(period.summary, style: AppTheme.body(size: 14, height: 1.8)),
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

class _EventsTab extends StatefulWidget {
  final Country country;
  final HistoryPeriod period;
  final String? highlightEventTitle;

  const _EventsTab({
    required this.country,
    required this.period,
    this.highlightEventTitle,
  });

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  final Map<int, GlobalKey> _tileKeys = {};
  bool _showHighlight = true;
  String _filter = '';

  List<HistoryEvent> get _filteredEvents {
    final q = _filter.trim();
    if (q.isEmpty) return widget.period.events;
    return widget.period.events.where((event) {
      return event.title.contains(q) ||
          event.year.contains(q) ||
          event.description.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.highlightEventTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
    }
  }

  void _scrollToHighlight() {
    final index = widget.period.events
        .indexWhere((e) => e.title == widget.highlightEventTitle);
    if (index < 0) return;
    final key = _tileKeys[index];
    final context = key?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.15,
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHighlight = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            onChanged: (v) => setState(() => _filter = v),
            style: AppTheme.body(size: 14),
            decoration: InputDecoration(
              hintText: '筛选本阶段事件…',
              hintStyle: AppTheme.body(size: 13, color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.filter_list_rounded, size: 20),
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        if (events.isEmpty)
          Expanded(
            child: Center(
              child: Text('没有匹配的事件',
                  style: AppTheme.body(size: 14, color: AppTheme.textSecondary)),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final e = events[index];
                final originalIndex = widget.period.events.indexOf(e);
                final isHighlighted =
                    _showHighlight && e.title == widget.highlightEventTitle;
                _tileKeys.putIfAbsent(originalIndex, GlobalKey.new);
                return _EventTile(
                  key: _tileKeys[originalIndex],
                  country: widget.country,
                  period: widget.period,
                  event: e,
                  color: widget.period.accentColor,
                  index: originalIndex + 1,
                  highlighted: isHighlighted,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FiguresCultureTab extends StatelessWidget {
  final Country country;
  final HistoryPeriod period;
  const _FiguresCultureTab({required this.country, required this.period});

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
            (f) => FigureIntroCard(
              figure: f,
              color: period.accentColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FigureDetailScreen(
                    country: country,
                    period: period,
                    figure: f,
                  ),
                ),
              ),
            ),
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
  final Country country;
  final HistoryPeriod period;
  final HistoryEvent event;
  final Color color;
  final int index;
  final bool highlighted;

  const _EventTile({
    super.key,
    required this.country,
    required this.period,
    required this.event,
    required this.color,
    required this.index,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final figures = FigureLinkService.figuresForEvent(
      event,
      period,
      countryId: country.id,
    );
    final favorites = FavoritesService.instance;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: highlighted ? 0.35 : 0.15),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: highlighted
                  ? color.withValues(alpha: 0.08)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: highlighted ? color : AppTheme.divider,
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    ListenableBuilder(
                      listenable: favorites,
                      builder: (context, _) {
                        final saved = favorites.isEventFavorite(
                          country.id,
                          period.id,
                          event.title,
                        );
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NoteIconButton(
                              storageKey: NotesService.eventKey(
                                country.id,
                                period.id,
                                event.title,
                              ),
                              title: event.title,
                              subtitle: '${country.name} · ${period.title}',
                              color: color,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(Icons.share_rounded,
                                  size: 20, color: AppTheme.textSecondary),
                              onPressed: () => ShareService.shareEvent(
                                country: country,
                                period: period,
                                event: event,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                saved ? Icons.bookmark : Icons.bookmark_outline,
                                size: 20,
                                color: saved ? color : AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                favorites.toggle(FavoriteItem(
                                  kind: FavoriteKind.event,
                                  countryId: country.id,
                                  periodId: period.id,
                                  title: event.title,
                                  subtitle:
                                      '${country.name} · ${period.title} · ${event.year}',
                                ));
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(event.description,
                    style: AppTheme.body(size: 13, height: 1.7)),
                if (figures.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 16, color: color),
                      const SizedBox(width: 6),
                      Text('相关人物',
                          style: AppTheme.label(size: 12, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...figures.map(
                    (figure) => FigureIntroCard(
                      figure: figure,
                      color: color,
                      compact: true,
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
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
