import '../data/countries_data.dart';
import '../models/country.dart';

/// 「历史上的今天」条目
class TodayHistoryHit {
  final Country country;
  final HistoryPeriod period;
  final HistoryEvent event;
  /// true = 月日精确匹配；false = 每日轮换推荐
  final bool dateMatched;

  const TodayHistoryHit({
    required this.country,
    required this.period,
    required this.event,
    required this.dateMatched,
  });
}

/// 根据当前日期匹配历史事件
class TodayInHistoryService {
  TodayInHistoryService._();

  static final _monthDayPattern = RegExp(r'(\d{1,2})月(\d{1,2})日');

  static List<TodayHistoryHit> forToday({DateTime? date, int limit = 4}) {
    final now = date ?? DateTime.now();
    final month = now.month;
    final day = now.day;

    final dateMatched = <TodayHistoryHit>[];
    final allEvents = <TodayHistoryHit>[];

    for (final country in allCountries) {
      for (final period in country.periods) {
        for (final event in period.events) {
          final hit = TodayHistoryHit(
            country: country,
            period: period,
            event: event,
            dateMatched: false,
          );
          allEvents.add(hit);

          if (_matchesMonthDay(event, month, day)) {
            dateMatched.add(TodayHistoryHit(
              country: country,
              period: period,
              event: event,
              dateMatched: true,
            ));
          }
        }
      }
    }

    if (dateMatched.isNotEmpty) {
      return dateMatched.take(limit).toList();
    }

    // 无月日匹配时，按日期确定性轮换展示
    final seed = now.year * 10000 + now.month * 100 + now.day;
    allEvents.sort((a, b) {
      final ha = _hash('${seed}_${a.country.id}_${a.period.id}_${a.event.title}');
      final hb = _hash('${seed}_${b.country.id}_${b.period.id}_${b.event.title}');
      return ha.compareTo(hb);
    });
    return allEvents.take(limit).toList();
  }

  static bool _matchesMonthDay(HistoryEvent event, int month, int day) {
    for (final text in [event.title, event.year, event.description]) {
      final parsed = _parseMonthDay(text);
      if (parsed != null && parsed.$1 == month && parsed.$2 == day) {
        return true;
      }
    }
    return false;
  }

  static (int, int)? _parseMonthDay(String text) {
    final match = _monthDayPattern.firstMatch(text);
    if (match == null) return null;
    final m = int.tryParse(match.group(1)!);
    final d = int.tryParse(match.group(2)!);
    if (m == null || d == null || m < 1 || m > 12 || d < 1 || d > 31) return null;
    return (m, d);
  }

  static int _hash(String input) {
    var h = 0;
    for (var i = 0; i < input.length; i++) {
      h = (h * 31 + input.codeUnitAt(i)) & 0x7fffffff;
    }
    return h;
  }
}
