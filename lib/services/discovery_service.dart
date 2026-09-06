import 'dart:math';

import '../data/countries_data.dart';
import '../models/country.dart';
import 'figure_link_service.dart';

class DiscoveryPick {
  final Country country;
  final HistoryPeriod period;
  final KeyFigure? spotlightFigure;
  final String tagline;

  const DiscoveryPick({
    required this.country,
    required this.period,
    required this.spotlightFigure,
    required this.tagline,
  });
}

/// 每日探索推荐：按日期确定性轮换国家/阶段/人物
class DiscoveryService {
  DiscoveryService._();

  static final _taglines = [
    '今日值得一读的历史阶段',
    '随机探索世界历史',
    '发现新的历史篇章',
    '展开一段未曾阅读的历史',
  ];

  static DiscoveryPick forToday({DateTime? date}) {
    final now = date ?? DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final countries = List<Country>.from(allCountries)..shuffle(random);
    final country = countries.first;
    final periods = List<HistoryPeriod>.from(country.periods)..shuffle(random);
    final period = periods.first;

    final figures = FigureLinkService.allFiguresForPeriod(country.id, period);
    KeyFigure? spotlight;
    if (figures.isNotEmpty) {
      spotlight = figures[random.nextInt(figures.length)];
    }

    final tagline = _taglines[random.nextInt(_taglines.length)];
    return DiscoveryPick(
      country: country,
      period: period,
      spotlightFigure: spotlight,
      tagline: tagline,
    );
  }

  static DiscoveryPick randomPick({int salt = 0}) {
    final random = Random(DateTime.now().millisecondsSinceEpoch + salt);
    final country = allCountries[random.nextInt(allCountries.length)];
    final period = country.periods[random.nextInt(country.periods.length)];
    final figures = FigureLinkService.allFiguresForPeriod(country.id, period);
    KeyFigure? spotlight;
    if (figures.isNotEmpty) {
      spotlight = figures[random.nextInt(figures.length)];
    }
    return DiscoveryPick(
      country: country,
      period: period,
      spotlightFigure: spotlight,
      tagline: '换一换，探索新历史',
    );
  }
}
