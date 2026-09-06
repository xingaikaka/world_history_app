import '../data/countries_data.dart';
import '../models/country.dart';
import 'figure_link_service.dart';

/// 人物检索结果
class FigureSearchHit {
  final Country country;
  final HistoryPeriod period;
  final KeyFigure figure;

  const FigureSearchHit({
    required this.country,
    required this.period,
    required this.figure,
  });
}

/// 跨国家/阶段人物搜索
class FigureSearchService {
  FigureSearchService._();

  static List<FigureSearchHit> search(String query, {int limit = 50}) {
    final q = query.trim();
    if (q.isEmpty) return [];

    final hits = <FigureSearchHit>[];
    final seen = <String>{};

    for (final country in allCountries) {
      for (final period in country.periods) {
        for (final figure in FigureLinkService.allFiguresForPeriod(country.id, period)) {
          final key = '${country.id}|${period.id}|${figure.name}';
          if (!seen.add(key)) continue;
          if (!_matches(q, figure)) continue;
          hits.add(FigureSearchHit(country: country, period: period, figure: figure));
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }

  static bool _matches(String query, KeyFigure figure) {
    if (figure.name.contains(query)) return true;
    if (figure.role.contains(query)) return true;
    if (figure.description.contains(query)) return true;
    return false;
  }
}
