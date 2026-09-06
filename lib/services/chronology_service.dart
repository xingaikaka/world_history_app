import '../data/countries_data.dart';
import '../models/country.dart';

class ChronologyEntry {
  final Country country;
  final HistoryPeriod period;
  final HistoryEvent event;
  final int sortYear;

  const ChronologyEntry({
    required this.country,
    required this.period,
    required this.event,
    required this.sortYear,
  });
}

/// 跨国家历史事件年表
class ChronologyService {
  ChronologyService._();

  static final _yearPattern = RegExp(r'(-?\d{1,4})');

  static List<ChronologyEntry> all({String? regionFilter, String? query, int limit = 120}) {
    final q = query?.trim();
    final entries = <ChronologyEntry>[];

    for (final country in allCountries) {
      if (regionFilter != null &&
          regionFilter != '全部' &&
          country.region != regionFilter) {
        continue;
      }
      for (final period in country.periods) {
        for (final event in period.events) {
          final year = parseYear(event.year);
          if (year == null) continue;
          if (q != null && q.isNotEmpty && !_matches(q, country, period, event)) {
            continue;
          }
          entries.add(ChronologyEntry(
            country: country,
            period: period,
            event: event,
            sortYear: year,
          ));
        }
      }
    }

    entries.sort((a, b) => a.sortYear.compareTo(b.sortYear));
    return entries.take(limit).toList();
  }

  static int? parseYear(String yearText) {
    final match = _yearPattern.firstMatch(yearText);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static String formatYear(int year) {
    if (year < 0) return '前${-year}年';
    return '$year年';
  }

  static bool _matches(
    String query,
    Country country,
    HistoryPeriod period,
    HistoryEvent event,
  ) {
    if (event.title.contains(query)) return true;
    if (event.year.contains(query)) return true;
    if (event.description.contains(query)) return true;
    if (country.name.contains(query)) return true;
    if (period.title.contains(query)) return true;
    return false;
  }
}
