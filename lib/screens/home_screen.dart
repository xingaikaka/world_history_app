import 'package:flutter/material.dart';
import '../data/countries_data.dart';
import '../models/country.dart';
import '../services/figure_search_service.dart';
import '../services/event_search_service.dart';
import '../services/search_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../widgets/today_history_section.dart';
import '../widgets/continue_reading_section.dart';
import '../widgets/discover_sections.dart';
import '../widgets/search_history_section.dart';
import '../services/reading_progress_service.dart';
import 'country_screen.dart';
import 'figure_detail_screen.dart';
import 'period_detail_screen.dart';

enum _SearchMode { country, figure, event }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _regionFilter = '全部';
  String _search = '';
  _SearchMode _searchMode = _SearchMode.country;

  List<Country> get _filteredCountries {
    var list = allCountries;
    if (_regionFilter != '全部') {
      list = list.where((c) => c.region == _regionFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((c) =>
              c.name.contains(_search) ||
              c.englishName.toLowerCase().contains(q) ||
              c.tags.any((t) => t.contains(_search)))
          .toList();
    }
    return list;
  }

  List<FigureSearchHit> get _figureHits {
    if (_searchMode != _SearchMode.figure || _search.trim().isEmpty) {
      return [];
    }
    return FigureSearchService.search(_search);
  }

  List<EventSearchHit> get _eventHits {
    if (_searchMode != _SearchMode.event || _search.trim().isEmpty) {
      return [];
    }
    return EventSearchService.search(_search);
  }

  SearchHistoryKind get _historyKind => switch (_searchMode) {
        _SearchMode.country => SearchHistoryKind.country,
        _SearchMode.figure => SearchHistoryKind.figure,
        _SearchMode.event => SearchHistoryKind.event,
      };

  void _recordSearch() {
    final query = _search.trim();
    if (query.length >= 2) {
      SearchHistoryService.instance.add(_historyKind, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final regions = [
      '全部',
      ...allCountries.map((c) => c.region).toSet(),
    ];
    final figureHits = _figureHits;
    final eventHits = _eventHits;
    final showFigureResults = _searchMode == _SearchMode.figure && _search.isNotEmpty;
    final showEventResults = _searchMode == _SearchMode.event && _search.isNotEmpty;
    final filtered = _filteredCountries;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A2118), Color(0xFF4A3728)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppTheme.primaryLight.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.account_balance_rounded,
                                color: Color(0xFFD4AF37), size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('万国史鉴',
                                    style: AppTheme.title(
                                        size: 24, color: Colors.white)),
                                Text('World History Timeline',
                                    style: AppTheme.body(
                                        size: 12,
                                        color:
                                            Colors.white.withValues(alpha: 0.65))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${allCountries.length} 个国家 · ${allCountries.fold<int>(0, (s, c) => s + c.periods.length)} 个历史阶段',
                        style: AppTheme.body(
                            size: 13, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (v) => setState(() => _search = v),
                        onSubmitted: (_) => _recordSearch(),
                        style: AppTheme.body(size: 14, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: switch (_searchMode) {
                            _SearchMode.country => '搜索国家、标签…',
                            _SearchMode.figure => '搜索历史人物…',
                            _SearchMode.event => '搜索历史事件…',
                          },
                          hintStyle:
                              AppTheme.body(size: 14, color: AppTheme.textSecondary),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.textSecondary, size: 22),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ModeChip(
                              label: '国家',
                              selected: _searchMode == _SearchMode.country,
                              onTap: () =>
                                  setState(() => _searchMode = _SearchMode.country),
                            ),
                            const SizedBox(width: 8),
                            _ModeChip(
                              label: '人物',
                              selected: _searchMode == _SearchMode.figure,
                              onTap: () =>
                                  setState(() => _searchMode = _SearchMode.figure),
                            ),
                            const SizedBox(width: 8),
                            _ModeChip(
                              label: '事件',
                              selected: _searchMode == _SearchMode.event,
                              onTap: () =>
                                  setState(() => _searchMode = _SearchMode.event),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ),
          if (_search.isEmpty)
            SliverToBoxAdapter(
              child: SearchHistorySection(
                kind: _historyKind,
                onSelect: (query) => setState(() => _search = query),
                onClear: () => SearchHistoryService.instance.clear(_historyKind),
              ),
            ),
          if (_searchMode == _SearchMode.country)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: regions.map((r) {
                      final selected = _regionFilter == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(r, style: AppTheme.label(size: 12)),
                          selected: selected,
                          onSelected: (_) => setState(() => _regionFilter = r),
                          selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                          checkmarkColor: AppTheme.primary,
                          side: BorderSide(
                            color: selected ? AppTheme.primary : AppTheme.divider,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          if (_searchMode == _SearchMode.country && _search.isEmpty)
            const SliverToBoxAdapter(child: LearningStatsSection()),
          if (_searchMode == _SearchMode.country && _search.isEmpty)
            const SliverToBoxAdapter(child: TodayHistorySection()),
          if (_searchMode == _SearchMode.country && _search.isEmpty)
            const SliverToBoxAdapter(child: ContinueReadingSection()),
          if (_searchMode == _SearchMode.country && _search.isEmpty)
            const SliverToBoxAdapter(child: DiscoverTodaySection()),
          if (showFigureResults) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '找到 ${figureHits.length} 位人物',
                  style: AppTheme.label(size: 12, color: AppTheme.textSecondary),
                ),
              ),
            ),
            if (figureHits.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded,
                            size: 56,
                            color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('未找到相关人物',
                            style: AppTheme.title(
                                size: 17, color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text('试试姓名、身份或简介中的关键词',
                            style: AppTheme.body(size: 13),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) _recordSearch();
                      final hit = figureHits[index];
                      return _FigureSearchTile(hit: hit);
                    },
                    childCount: figureHits.length,
                  ),
                ),
              ),
          ] else if (showEventResults) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '找到 ${eventHits.length} 个事件',
                  style: AppTheme.label(size: 12, color: AppTheme.textSecondary),
                ),
              ),
            ),
            if (eventHits.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded,
                            size: 56,
                            color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('未找到相关事件',
                            style: AppTheme.title(
                                size: 17, color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text('试试事件名称、年份或描述中的关键词',
                            style: AppTheme.body(size: 13),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) _recordSearch();
                      final hit = eventHits[index];
                      return _EventSearchTile(hit: hit);
                    },
                    childCount: eventHits.length,
                  ),
                ),
              ),
          ] else if (_searchMode == _SearchMode.country && filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('未找到相关国家',
                          style: AppTheme.title(
                              size: 17, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Text(
                        _search.isNotEmpty
                            ? '试试其他关键词，或切换地区筛选'
                            : '当前地区暂无国家数据',
                        style: AppTheme.body(size: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final country = filtered[index];
                    return _CountryCard(country: country);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.primaryLight.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryLight.withValues(alpha: 0.6)
                  : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.label(
              size: 12,
              color: selected ? const Color(0xFFD4AF37) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _FigureSearchTile extends StatelessWidget {
  final FigureSearchHit hit;

  const _FigureSearchTile({required this.hit});

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
              builder: (_) => FigureDetailScreen(
                country: hit.country,
                period: hit.period,
                figure: hit.figure,
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
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Text(
                    hit.figure.name.characters.first,
                    style: AppTheme.title(size: 18, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CountryBadge(flagCode: hit.country.flagCode),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hit.country.name,
                              style: AppTheme.label(size: 10, color: color),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(hit.figure.name, style: AppTheme.title(size: 15)),
                      Text(hit.figure.role,
                          style: AppTheme.body(size: 12), maxLines: 1),
                      Text(hit.period.title,
                          style: AppTheme.body(size: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventSearchTile extends StatelessWidget {
  final EventSearchHit hit;

  const _EventSearchTile({required this.hit});

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
                        style: AppTheme.label(size: 10, color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                      child: Text(hit.event.title, style: AppTheme.title(size: 15)),
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

class _CountryCard extends StatelessWidget {
  final Country country;

  const _CountryCard({required this.country});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CountryScreen(country: country)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [
              BoxShadow(
                color: country.themeColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Stack(
                  children: [
                    Image.asset(
                      country.imageAsset,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: country.themeColor.withValues(alpha: 0.2),
                        child: Icon(Icons.public_rounded,
                            color: country.themeColor, size: 36),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CountryBadge(flagCode: country.flagCode),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(country.name,
                          style: AppTheme.title(size: 16), maxLines: 1),
                      Text(country.englishName,
                          style: AppTheme.body(size: 11), maxLines: 1),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.timeline_rounded,
                              size: 13, color: country.themeColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('${country.periods.length} 阶段',
                                style: AppTheme.label(
                                    size: 10, color: country.themeColor)),
                          ),
                        ],
                      ),
                      ListenableBuilder(
                        listenable: ReadingProgressService.instance,
                        builder: (context, _) {
                          final visited = ReadingProgressService.instance
                              .visitedCountForCountry(country.id);
                          if (visited == 0) return const SizedBox(height: 4);
                          final ratio = visited / country.periods.length;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 4,
                                      backgroundColor: AppTheme.divider,
                                      color: country.themeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('$visited/${country.periods.length}',
                                    style: AppTheme.label(
                                        size: 9, color: country.themeColor)),
                              ],
                            ),
                          );
                        },
                      ),
                      Text(
                        country.earliestYear < 0
                            ? '前${-country.earliestYear}年—${country.latestYear}年'
                            : '${country.earliestYear}—${country.latestYear}年',
                        style: AppTheme.year(size: 10),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
