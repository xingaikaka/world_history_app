import '../data/countries_data.dart';
import '../models/country.dart';

class EventSearchHit {
  final Country country;
  final HistoryPeriod period;
  final HistoryEvent event;

  const EventSearchHit({
    required this.country,
    required this.period,
    required this.event,
  });
}

/// 跨国家/阶段历史事件搜索
class EventSearchService {
  EventSearchService._();

  static List<EventSearchHit> search(String query, {int limit = 50}) {
    final q = query.trim();
    if (q.isEmpty) return [];

    final hits = <EventSearchHit>[];
    for (final country in allCountries) {
      for (final period in country.periods) {
        for (final event in period.events) {
          if (!_matches(q, event)) continue;
          hits.add(EventSearchHit(country: country, period: period, event: event));
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }

  static bool _matches(String query, HistoryEvent event) {
    if (event.title.contains(query)) return true;
    if (event.year.contains(query)) return true;
    if (event.description.contains(query)) return true;
    return false;
  }
}
