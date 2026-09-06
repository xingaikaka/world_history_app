import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/reading_progress_service.dart';
import '../services/related_countries_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../widgets/timeline_widget.dart';
import 'period_detail_screen.dart';

class CountryScreen extends StatelessWidget {
  final Country country;

  const CountryScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.headerDark,
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
                    country.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: country.themeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CountryCircle(flagCode: country.flagCode, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(country.name,
                                      style: AppTheme.title(
                                          size: 26, color: Colors.white)),
                                  Text(country.englishName,
                                      style: AppTheme.body(
                                          size: 13,
                                          color:
                                              Colors.white.withValues(alpha: 0.7))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Chip(label: country.region),
                            _Chip(label: country.capital),
                            ...country.tags.take(2).map((t) => _Chip(label: t)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('历史概览', style: AppTheme.title(size: 18)),
                  const SizedBox(height: 10),
                  Text(country.overview,
                      style: AppTheme.body(size: 14, height: 1.7)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatBox(
                        label: '历史跨度',
                        value: country.earliestYear < 0
                            ? '${-country.earliestYear} BC'
                            : '${country.earliestYear}',
                        suffix: '— ${country.latestYear}',
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        label: '时间阶段',
                        value: '${country.periods.length}',
                        suffix: ' 个',
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: ReadingProgressService.instance,
                    builder: (context, _) {
                      final visited =
                          ReadingProgressService.instance.visitedCountForCountry(country.id);
                      if (visited == 0) return const SizedBox.shrink();
                      final ratio = visited / country.periods.length;
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('阅读进度',
                                    style: AppTheme.label(size: 11)),
                                const Spacer(),
                                Text('已读 $visited / ${country.periods.length} 个阶段',
                                    style: AppTheme.label(
                                        size: 11, color: AppTheme.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: AppTheme.divider,
                                color: country.themeColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: country.themeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('历史时间线', style: AppTheme.title(size: 18)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('点击各阶段查看详细历史事件与人物',
                      style: AppTheme.body(size: 12)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TimelineWidget(
              periods: country.periods,
              onPeriodTap: (period) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PeriodDetailScreen(
                    country: country,
                    period: period,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _RelatedCountriesSection(country: country)),
        ],
      ),
    );
  }
}

class _RelatedCountriesSection extends StatelessWidget {
  final Country country;

  const _RelatedCountriesSection({required this.country});

  @override
  Widget build(BuildContext context) {
    final related = RelatedCountriesService.relatedTo(country);
    if (related.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_rounded, size: 18, color: country.themeColor),
              const SizedBox(width: 8),
              Text('相关国家', style: AppTheme.title(size: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text('同地区或相似历史主题',
              style: AppTheme.body(size: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = related[index];
                return Material(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CountryScreen(country: item),
                      ),
                    ),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CountryBadge(flagCode: item.flagCode),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(item.name,
                                    style: AppTheme.title(size: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(item.region,
                              style: AppTheme.label(size: 10, color: item.themeColor)),
                          Text('${item.periods.length} 个阶段',
                              style: AppTheme.body(size: 10)),
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

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: AppTheme.label(size: 11, color: Colors.white.withValues(alpha: 0.9))),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;

  const _StatBox({
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.label(size: 11)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTheme.year(size: 18, color: AppTheme.primary),
                  ),
                  TextSpan(
                    text: suffix,
                    style: AppTheme.body(size: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
