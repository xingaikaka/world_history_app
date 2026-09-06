import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import 'figure_detail_screen.dart';
import 'period_detail_screen.dart';

enum _FavoriteFilter { all, figure, event }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  _FavoriteFilter _filter = _FavoriteFilter.all;

  List<FavoriteItem> _filteredItems(List<FavoriteItem> items) {
    return switch (_filter) {
      _FavoriteFilter.all => items,
      _FavoriteFilter.figure =>
        items.where((i) => i.kind == FavoriteKind.figure).toList(),
      _FavoriteFilter.event =>
        items.where((i) => i.kind == FavoriteKind.event).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesService.instance;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('我的收藏', style: AppTheme.title(size: 18)),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: favorites,
        builder: (context, _) {
          final allItems = favorites.items;
          final items = _filteredItems(allItems);

          if (allItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_rounded,
                        size: 56,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('还没有收藏',
                        style:
                            AppTheme.title(size: 17, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      '在人物详情或大事记事件中点击书签即可收藏',
                      style: AppTheme.body(size: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    _FilterChip(
                      label: '全部 (${allItems.length})',
                      selected: _filter == _FavoriteFilter.all,
                      onTap: () => setState(() => _filter = _FavoriteFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '人物',
                      selected: _filter == _FavoriteFilter.figure,
                      onTap: () => setState(() => _filter = _FavoriteFilter.figure),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '事件',
                      selected: _filter == _FavoriteFilter.event,
                      onTap: () => setState(() => _filter = _FavoriteFilter.event),
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      '该分类下暂无收藏',
                      style: AppTheme.body(size: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final country = item.country;
                      final period = item.period;
                      if (country == null || period == null) {
                        return _InvalidFavoriteTile(
                          item: item,
                          onRemove: () => favorites.remove(item),
                        );
                      }

                      final color = period.accentColor;
                      final isFigure = item.kind == FavoriteKind.figure;

                      return Material(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (isFigure) {
                              final figure = item.figure;
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
                                    highlightEventTitle: item.title,
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
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    isFigure
                                        ? Icons.person_outline_rounded
                                        : Icons.event_note_rounded,
                                    color: color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CountryBadge(flagCode: country.flagCode),
                                          const SizedBox(width: 6),
                                          Text(
                                            isFigure ? '人物' : '事件',
                                            style: AppTheme.label(size: 10, color: color),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(item.title,
                                          style: AppTheme.title(size: 15),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(item.subtitle,
                                          style: AppTheme.body(size: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_rounded, size: 20),
                                  color: AppTheme.textSecondary,
                                  onPressed: () {
                                    if (isFigure) {
                                      final figure = item.figure;
                                      if (figure == null) return;
                                      ShareService.shareFigure(
                                        country: country,
                                        period: period,
                                        figure: figure,
                                      );
                                    } else {
                                      final event = item.event;
                                      if (event == null) return;
                                      ShareService.shareEvent(
                                        country: country,
                                        period: period,
                                        event: event,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 20),
                                  color: AppTheme.textSecondary,
                                  onPressed: () => favorites.remove(item),
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
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: AppTheme.label(size: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primary.withValues(alpha: 0.15),
      checkmarkColor: AppTheme.primary,
      side: BorderSide(
        color: selected ? AppTheme.primary : AppTheme.divider,
      ),
    );
  }
}

class _InvalidFavoriteTile extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onRemove;

  const _InvalidFavoriteTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '数据已失效：${item.title}',
              style: AppTheme.body(size: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
