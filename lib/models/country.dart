import 'package:flutter/material.dart';

/// 历史时期内的具体事件节点
class HistoryEvent {
  final String year;
  final String title;
  final String description;

  const HistoryEvent({
    required this.year,
    required this.title,
    required this.description,
  });
}

/// 关键历史人物（含简介）
class KeyFigure {
  final String name;
  final String role;
  final String description;

  const KeyFigure({
    required this.name,
    required this.role,
    required this.description,
  });
}

/// 文化成就条目
class CulturalItem {
  final String title;
  final String description;

  const CulturalItem({
    required this.title,
    required this.description,
  });
}

/// 时间轴主轴：一个历史阶段
class HistoryPeriod {
  final String id;
  final int startYear;
  final int? endYear;
  final String title;
  final String subtitle;
  final String summary;
  final String background;
  final String politics;
  final String economy;
  final String society;
  final String imageAsset;
  final Color accentColor;
  final List<HistoryEvent> events;
  final List<KeyFigure> keyFigures;
  final List<CulturalItem> culturalHighlights;
  final String legacy;

  const HistoryPeriod({
    required this.id,
    required this.startYear,
    this.endYear,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.background,
    required this.politics,
    required this.economy,
    required this.society,
    required this.imageAsset,
    required this.accentColor,
    required this.events,
    required this.keyFigures,
    required this.culturalHighlights,
    required this.legacy,
  });

  String get yearRange {
    if (endYear == null) return '$startYear—至今';
    if (startYear < 0) {
      final s = '${-startYear} BC';
      final e = endYear! < 0 ? '${-endYear!} BC' : '$endYear';
      return '$s — $e';
    }
    return '$startYear — $endYear';
  }

  int get durationYears {
    final end = endYear ?? DateTime.now().year;
    return end - startYear;
  }
}

/// 国家及其完整历史时间线
class Country {
  final String id;
  final String name;
  final String englishName;
  final String flagCode;
  final String region;
  final String capital;
  final String imageAsset;
  final Color themeColor;
  final String overview;
  final List<String> tags;
  final List<HistoryPeriod> periods;

  const Country({
    required this.id,
    required this.name,
    required this.englishName,
    required this.flagCode,
    required this.region,
    required this.capital,
    required this.imageAsset,
    required this.themeColor,
    required this.overview,
    required this.tags,
    required this.periods,
  });

  int get earliestYear =>
      periods.map((p) => p.startYear).reduce((a, b) => a < b ? a : b);

  int get latestYear {
    final ends = periods.map((p) => p.endYear ?? DateTime.now().year);
    return ends.reduce((a, b) => a > b ? a : b);
  }
}
