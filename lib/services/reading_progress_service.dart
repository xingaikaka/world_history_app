import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/countries_data.dart';
import '../models/country.dart';
import 'reading_streak_service.dart';

class ReadingProgressEntry {
  final String countryId;
  final String periodId;
  final int visitedAt;

  const ReadingProgressEntry({
    required this.countryId,
    required this.periodId,
    required this.visitedAt,
  });

  String get storageKey => '$countryId|$periodId';

  Map<String, dynamic> toJson() => {
        'countryId': countryId,
        'periodId': periodId,
        'visitedAt': visitedAt,
      };

  factory ReadingProgressEntry.fromJson(Map<String, dynamic> json) {
    return ReadingProgressEntry(
      countryId: json['countryId'] as String,
      periodId: json['periodId'] as String,
      visitedAt: json['visitedAt'] as int,
    );
  }

  Country? get country => countryById(countryId);

  HistoryPeriod? get period {
    final c = country;
    if (c == null) return null;
    try {
      return c.periods.firstWhere((p) => p.id == periodId);
    } catch (_) {
      return null;
    }
  }
}

class ReadingProgressService extends ChangeNotifier {
  ReadingProgressService._();

  static final ReadingProgressService instance = ReadingProgressService._();

  static const _prefsKey = 'reading_progress_v1';

  final Map<String, ReadingProgressEntry> _entries = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get totalVisitedPeriods => _entries.length;

  int get totalPeriodCount =>
      allCountries.fold<int>(0, (sum, c) => sum + c.periods.length);

  double get overallProgress =>
      totalPeriodCount == 0 ? 0 : totalVisitedPeriods / totalPeriodCount;

  int get countriesStartedCount =>
      _entries.values.map((e) => e.countryId).toSet().length;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _entries.clear();
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final entry in list) {
          final item = ReadingProgressEntry.fromJson(entry as Map<String, dynamic>);
          _entries[item.storageKey] = item;
        }
      } catch (_) {
        _entries.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> recordPeriodVisit(String countryId, String periodId) async {
    final key = '$countryId|$periodId';
    _entries[key] = ReadingProgressEntry(
      countryId: countryId,
      periodId: periodId,
      visitedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _persist();
    await ReadingStreakService.instance.recordActivity();
    notifyListeners();
  }

  bool hasVisited(String countryId, String periodId) =>
      _entries.containsKey('$countryId|$periodId');

  int visitedCountForCountry(String countryId) =>
      _entries.values.where((e) => e.countryId == countryId).length;

  double progressForCountry(Country country) {
    if (country.periods.isEmpty) return 0;
    return visitedCountForCountry(country.id) / country.periods.length;
  }

  List<ReadingProgressEntry> recentEntries({int limit = 3}) {
    final sorted = _entries.values.toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    return sorted.take(limit).toList();
  }

  int visitsThisWeek() {
    final now = DateTime.now();
    final weekStart =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return _entries.values.where((entry) {
      final visited = DateTime.fromMillisecondsSinceEpoch(entry.visitedAt);
      return !visited.isBefore(weekStart);
    }).length;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _entries.values.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }
}
