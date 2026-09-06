import '../models/country.dart';
import '../data/countries_data.dart';
import '../data/event_figure_bindings.dart';
import '../data/supplementary_figures.dart';

/// 人物在某一阶段的出现记录
class FigurePeriodAppearance {
  final HistoryPeriod period;
  final KeyFigure figure;
  final int eventCount;

  const FigurePeriodAppearance({
    required this.period,
    required this.figure,
    required this.eventCount,
  });
}

/// 同名人物在其他国家的出现记录
class FigureGlobalAppearance {
  final Country country;
  final HistoryPeriod period;
  final KeyFigure figure;

  const FigureGlobalAppearance({
    required this.country,
    required this.period,
    required this.figure,
  });
}

/// 为事件节点匹配相关历史人物
class FigureLinkService {
  FigureLinkService._();

  static String bindingKey(String countryId, String periodId, String eventTitle) =>
      '$countryId|$periodId|$eventTitle';

  /// 阶段全部可用人物（keyFigures + 补充人物库）
  static List<KeyFigure> allFiguresForPeriod(String countryId, HistoryPeriod period) {
    final map = <String, KeyFigure>{};
    for (final figure in period.keyFigures) {
      map[figure.name] = figure;
    }
    final prefix = '$countryId|${period.id}|';
    for (final entry in supplementaryFigures.entries) {
      if (entry.key.startsWith(prefix)) {
        map[entry.value.name] = entry.value;
      }
    }
    return map.values.toList();
  }

  static KeyFigure? resolveFigure(
    String countryId,
    HistoryPeriod period,
    String name,
  ) {
    for (final figure in period.keyFigures) {
      if (figure.name == name) return figure;
    }
    return supplementaryFigures['$countryId|${period.id}|$name'];
  }

  /// 获取事件关联人物（手动绑定 > 事件内嵌 > 自动文本匹配）
  static List<KeyFigure> figuresForEvent(
    HistoryEvent event,
    HistoryPeriod period, {
    required String countryId,
  }) {
    if (event.relatedFigures.isNotEmpty) {
      return event.relatedFigures;
    }

    final manualNames = eventFigureBindings[bindingKey(countryId, period.id, event.title)];
    if (manualNames != null && manualNames.isNotEmpty) {
      final resolved = <KeyFigure>[];
      final seen = <String>{};
      for (final name in manualNames) {
        final figure = resolveFigure(countryId, period, name);
        if (figure != null && seen.add(figure.name)) {
          resolved.add(figure);
        }
      }
      if (resolved.isNotEmpty) return resolved;
    }

    return allFiguresForPeriod(countryId, period)
        .where((figure) => _matchesFigure(event, figure))
        .toList();
  }

  /// 获取与人物相关的全部事件（当前阶段内）
  static List<HistoryEvent> eventsForFigure(
    KeyFigure figure,
    HistoryPeriod period, {
    required String countryId,
  }) {
    return period.events.where((event) {
      final linked = figuresForEvent(event, period, countryId: countryId);
      return linked.any((f) => f.name == figure.name);
    }).toList();
  }

  /// 同一国家其他阶段是否也出现该人物
  static List<FigurePeriodAppearance> appearancesInCountry(
    Country country,
    String figureName, {
    String? excludePeriodId,
  }) {
    final results = <FigurePeriodAppearance>[];
    for (final period in country.periods) {
      if (period.id == excludePeriodId) continue;
      final figure = resolveFigure(country.id, period, figureName);
      if (figure == null) continue;
      final events = eventsForFigure(figure, period, countryId: country.id);
      final inKeyFigures = period.keyFigures.any((f) => f.name == figureName);
      if (events.isNotEmpty || inKeyFigures) {
        results.add(FigurePeriodAppearance(
          period: period,
          figure: figure,
          eventCount: events.length,
        ));
      }
    }
    return results;
  }

  /// 同名人物在其他国家的出现（排除当前国家）
  static List<FigureGlobalAppearance> appearancesGlobally(
    String figureName, {
    String? excludeCountryId,
  }) {
    final results = <FigureGlobalAppearance>[];
    for (final country in allCountries) {
      if (country.id == excludeCountryId) continue;
      for (final period in country.periods) {
        final figure = resolveFigure(country.id, period, figureName);
        if (figure == null) continue;
        final events = eventsForFigure(figure, period, countryId: country.id);
        final inKeyFigures = period.keyFigures.any((f) => f.name == figureName);
        if (events.isNotEmpty || inKeyFigures) {
          results.add(FigureGlobalAppearance(
            country: country,
            period: period,
            figure: figure,
          ));
        }
      }
    }
    return results;
  }

  /// 与当前人物共同参与历史事件的其他人物（同阶段）
  static List<KeyFigure> coFiguresForFigure(
    KeyFigure figure,
    HistoryPeriod period, {
    required String countryId,
  }) {
    final events = eventsForFigure(figure, period, countryId: countryId);
    final map = <String, KeyFigure>{};
    for (final event in events) {
      for (final linked in figuresForEvent(event, period, countryId: countryId)) {
        if (linked.name != figure.name) {
          map[linked.name] = linked;
        }
      }
    }
    return map.values.toList();
  }

  /// 某事件下除指定人物外的其他相关人物
  static List<KeyFigure> coFiguresForEvent(
    HistoryEvent event,
    HistoryPeriod period, {
    required String countryId,
    String? excludeFigureName,
  }) {
    return figuresForEvent(event, period, countryId: countryId)
        .where((f) => f.name != excludeFigureName)
        .toList();
  }

  static bool _matchesFigure(HistoryEvent event, KeyFigure figure) {
    final text = '${event.title} ${event.description}';
    final names = figure.name.split(RegExp(r'[与、及/·]'));
    for (final raw in names) {
      final name = raw.trim();
      if (name.length >= 2 && text.contains(name)) {
        return true;
      }
    }
    return false;
  }
}
