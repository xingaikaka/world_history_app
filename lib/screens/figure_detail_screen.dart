import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/favorites_service.dart';
import '../services/figure_link_service.dart';
import '../services/notes_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/country_badge.dart';
import '../widgets/figure_intro_card.dart';
import '../widgets/note_editor_sheet.dart';
import 'period_detail_screen.dart';

class FigureDetailScreen extends StatelessWidget {
  final Country country;
  final HistoryPeriod period;
  final KeyFigure figure;

  const FigureDetailScreen({
    super.key,
    required this.country,
    required this.period,
    required this.figure,
  });

  FavoriteItem get _favoriteItem => FavoriteItem(
        kind: FavoriteKind.figure,
        countryId: country.id,
        periodId: period.id,
        figureName: figure.name,
        title: figure.name,
        subtitle: '${country.name} · ${period.title}',
      );

  void _openEvent(BuildContext context, HistoryEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PeriodDetailScreen(
          country: country,
          period: period,
          initialTabIndex: PeriodDetailScreen.eventsTabIndex,
          highlightEventTitle: event.title,
        ),
      ),
    );
  }

  void _openFigure(BuildContext context, HistoryPeriod targetPeriod, KeyFigure targetFigure) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FigureDetailScreen(
          country: country,
          period: targetPeriod,
          figure: targetFigure,
        ),
      ),
    );
  }

  void _openGlobalFigure(BuildContext context, FigureGlobalAppearance appearance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FigureDetailScreen(
          country: appearance.country,
          period: appearance.period,
          figure: appearance.figure,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final relatedEvents = FigureLinkService.eventsForFigure(
      figure,
      period,
      countryId: country.id,
    );
    final coFigures = FigureLinkService.coFiguresForFigure(
      figure,
      period,
      countryId: country.id,
    );
    final otherPeriods = FigureLinkService.appearancesInCountry(
      country,
      figure.name,
      excludePeriodId: period.id,
    );
    final globalAppearances = FigureLinkService.appearancesGlobally(
      figure.name,
      excludeCountryId: country.id,
    );
    final favorites = FavoritesService.instance;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: period.accentColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              NoteIconButton(
                storageKey: NotesService.figureKey(country.id, period.id, figure.name),
                title: figure.name,
                subtitle: '${country.name} · ${period.title}',
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => ShareService.shareFigure(
                  country: country,
                  period: period,
                  figure: figure,
                ),
              ),
              ListenableBuilder(
                listenable: favorites,
                builder: (context, _) {
                  final saved = favorites.isFigureFavorite(
                    country.id,
                    period.id,
                    figure.name,
                  );
                  return IconButton(
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_outline,
                      color: Colors.white,
                    ),
                    onPressed: () => favorites.toggle(_favoriteItem),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      period.accentColor,
                      period.accentColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CountryBadge(flagCode: country.flagCode),
                            const SizedBox(width: 8),
                            Text(
                              '${country.name} · ${period.title}',
                              style:
                                  AppTheme.label(size: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                figure.name.characters.first,
                                style:
                                    AppTheme.title(size: 24, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(figure.name,
                                      style: AppTheme.title(
                                          size: 24, color: Colors.white)),
                                  Text(figure.role,
                                      style: AppTheme.body(
                                          size: 13, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoBlock(
                    title: '人物简介',
                    icon: Icons.person_outline_rounded,
                    content: figure.description,
                    color: period.accentColor,
                  ),
                  const SizedBox(height: 16),
                  _InfoBlock(
                    title: '所处阶段',
                    icon: Icons.timeline_rounded,
                    content: '${period.yearRange} · ${period.subtitle}',
                    color: period.accentColor,
                  ),
                  const SizedBox(height: 16),
                  _InfoBlock(
                    title: '阶段背景',
                    icon: Icons.auto_stories_rounded,
                    content: period.summary,
                    color: period.accentColor,
                  ),
                  if (coFigures.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      icon: Icons.people_outline_rounded,
                      title: '同场人物',
                      subtitle: '${coFigures.length} 位',
                      color: period.accentColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '与 ${figure.name} 在同一历史事件节点出现的人物',
                      style: AppTheme.body(size: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    ...coFigures.map(
                      (f) => FigureIntroCard(
                        figure: f,
                        color: period.accentColor,
                        compact: true,
                        onTap: () => _openFigure(context, period, f),
                      ),
                    ),
                  ],
                  if (otherPeriods.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      icon: Icons.swap_horiz_rounded,
                      title: '其他历史阶段',
                      subtitle: '${otherPeriods.length} 个阶段',
                      color: period.accentColor,
                    ),
                    const SizedBox(height: 10),
                    ...otherPeriods.map(
                      (appearance) => _OtherPeriodTile(
                        appearance: appearance,
                        color: period.accentColor,
                        onTap: () => _openFigure(
                          context,
                          appearance.period,
                          appearance.figure,
                        ),
                      ),
                    ),
                  ],
                  if (globalAppearances.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      icon: Icons.public_rounded,
                      title: '同名人物 · 其他国家',
                      subtitle: '${globalAppearances.length} 处',
                      color: period.accentColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '与 ${figure.name} 同名的人物在世界史其他国家的记录',
                      style: AppTheme.body(size: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    ...globalAppearances.map(
                      (appearance) => _GlobalAppearanceTile(
                        appearance: appearance,
                        color: period.accentColor,
                        onTap: () => _openGlobalFigure(context, appearance),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _SectionHeader(
                    icon: Icons.event_note_rounded,
                    title: '相关历史事件',
                    subtitle: '${relatedEvents.length} 个',
                    color: period.accentColor,
                  ),
                  const SizedBox(height: 12),
                  if (relatedEvents.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Text(
                        '当前阶段暂无与该人物绑定的事件节点',
                        style: AppTheme.body(size: 13),
                      ),
                    )
                  else
                    ...relatedEvents.map(
                      (event) {
                        final eventCoFigures =
                            FigureLinkService.coFiguresForEvent(
                          event,
                          period,
                          countryId: country.id,
                          excludeFigureName: figure.name,
                        );
                        return _RelatedEventTile(
                          event: event,
                          color: period.accentColor,
                          coFigures: eventCoFigures,
                          onTap: () => _openEvent(context, event),
                          onCoFigureTap: (f) => _openFigure(context, period, f),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.title(size: 16)),
        const Spacer(),
        Text(subtitle, style: AppTheme.body(size: 12)),
      ],
    );
  }
}

class _OtherPeriodTile extends StatelessWidget {
  final FigurePeriodAppearance appearance;
  final Color color;
  final VoidCallback onTap;

  const _OtherPeriodTile({
    required this.appearance,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appearance.period.title,
                          style: AppTheme.title(size: 14)),
                      Text(
                        '${appearance.period.yearRange} · ${appearance.figure.role}',
                        style: AppTheme.body(size: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (appearance.eventCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${appearance.eventCount} 事件',
                        style: AppTheme.label(size: 10, color: color)),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalAppearanceTile extends StatelessWidget {
  final FigureGlobalAppearance appearance;
  final Color color;
  final VoidCallback onTap;

  const _GlobalAppearanceTile({
    required this.appearance,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final periodColor = appearance.period.accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                CountryBadge(flagCode: appearance.country.flagCode),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appearance.country.name} · ${appearance.period.title}',
                        style: AppTheme.title(size: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appearance.figure.role,
                        style: AppTheme.body(size: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: periodColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedEventTile extends StatelessWidget {
  final HistoryEvent event;
  final Color color;
  final List<KeyFigure> coFigures;
  final VoidCallback onTap;
  final ValueChanged<KeyFigure> onCoFigureTap;

  const _RelatedEventTile({
    required this.event,
    required this.color,
    required this.coFigures,
    required this.onTap,
    required this.onCoFigureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(event.year,
                          style: AppTheme.year(size: 11, color: color)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: AppTheme.title(size: 14)),
                          const SizedBox(height: 6),
                          Text(
                            event.description,
                            style: AppTheme.body(size: 12, height: 1.55),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary, size: 20),
                  ],
                ),
                if (coFigures.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: coFigures.map((f) {
                      return ActionChip(
                        label: Text(f.name, style: AppTheme.label(size: 11)),
                        backgroundColor: color.withValues(alpha: 0.08),
                        side: BorderSide(color: color.withValues(alpha: 0.25)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onCoFigureTap(f),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final Color color;

  const _InfoBlock({
    required this.title,
    required this.icon,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.title(size: 16)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Text(content, style: AppTheme.body(size: 14, height: 1.8)),
        ),
      ],
    );
  }
}
