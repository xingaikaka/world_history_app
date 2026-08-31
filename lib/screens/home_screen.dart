import 'package:flutter/material.dart';
import '../data/countries_data.dart';
import '../models/country.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import 'country_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _regionFilter = '全部';
  String _search = '';

  List<Country> get _filtered {
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

  @override
  Widget build(BuildContext context) {
    final regions = [
      '全部',
      ...allCountries.map((c) => c.region).toSet(),
    ];

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
                                  color: AppTheme.primaryLight.withValues(alpha: 0.4)),
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
                                        color: Colors.white.withValues(alpha: 0.65))),
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
                        style: AppTheme.body(size: 14, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: '搜索国家、标签…',
                          hintStyle: AppTheme.body(size: 14, color: AppTheme.textSecondary),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
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
          if (_filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('未找到相关国家',
                          style: AppTheme.title(size: 17, color: AppTheme.textSecondary)),
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
                    final country = _filtered[index];
                    return _CountryCard(country: country);
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
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
                          Text('${country.periods.length} 阶段',
                              style: AppTheme.label(
                                  size: 10, color: country.themeColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
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
