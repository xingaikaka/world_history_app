import 'package:flutter/material.dart';

import '../data/countries_data.dart';
import '../services/chronology_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import 'period_detail_screen.dart';

class ChronologyScreen extends StatefulWidget {
  const ChronologyScreen({super.key});

  @override
  State<ChronologyScreen> createState() => _ChronologyScreenState();
}

class _ChronologyScreenState extends State<ChronologyScreen> {
  String _region = '全部';
  String _query = '';

  List<String> get _regions => [
        '全部',
        ...allCountries.map((c) => c.region).toSet(),
      ];

  List<ChronologyEntry> get _entries => ChronologyService.all(
        regionFilter: _region,
        query: _query.isEmpty ? null : _query,
      );

  @override
  Widget build(BuildContext context) {
    final entries = _entries;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('世界史年表', style: AppTheme.title(size: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppTheme.body(size: 14),
              decoration: InputDecoration(
                hintText: '搜索事件、国家…',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final region = _regions[index];
                final selected = _region == region;
                return FilterChip(
                  label: Text(region, style: AppTheme.label(size: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _region = region),
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primary,
                  side: BorderSide(
                    color: selected ? AppTheme.primary : AppTheme.divider,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '共 ${entries.length} 条事件（按年代排序）',
                style: AppTheme.label(size: 11, color: AppTheme.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text('暂无匹配事件',
                        style: AppTheme.body(size: 14, color: AppTheme.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final color = entry.period.accentColor;
                      return Material(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PeriodDetailScreen(
                                country: entry.country,
                                period: entry.period,
                                initialTabIndex: PeriodDetailScreen.eventsTabIndex,
                                highlightEventTitle: entry.event.title,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    ChronologyService.formatYear(entry.sortYear),
                                    style: AppTheme.year(size: 11, color: color),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.event.title,
                                          style: AppTheme.title(size: 14)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          CountryBadge(flagCode: entry.country.flagCode),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${entry.country.name} · ${entry.period.title}',
                                              style: AppTheme.body(size: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
