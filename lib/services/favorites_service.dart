import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/countries_data.dart';
import '../models/country.dart';
import 'figure_link_service.dart';

enum FavoriteKind { figure, event }

class FavoriteItem {
  final FavoriteKind kind;
  final String countryId;
  final String periodId;
  final String title;
  final String subtitle;
  final String? figureName;

  const FavoriteItem({
    required this.kind,
    required this.countryId,
    required this.periodId,
    required this.title,
    required this.subtitle,
    this.figureName,
  });

  String get storageKey => switch (kind) {
        FavoriteKind.figure => 'f|$countryId|$periodId|$figureName',
        FavoriteKind.event => 'e|$countryId|$periodId|$title',
      };

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'countryId': countryId,
        'periodId': periodId,
        'title': title,
        'subtitle': subtitle,
        if (figureName != null) 'figureName': figureName,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      kind: FavoriteKind.values.byName(json['kind'] as String),
      countryId: json['countryId'] as String,
      periodId: json['periodId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      figureName: json['figureName'] as String?,
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

  KeyFigure? get figure {
    if (kind != FavoriteKind.figure || figureName == null) return null;
    final p = period;
    final c = country;
    if (p == null || c == null) return null;
    return FigureLinkService.resolveFigure(c.id, p, figureName!);
  }

  HistoryEvent? get event {
    if (kind != FavoriteKind.event) return null;
    final p = period;
    if (p == null) return null;
    try {
      return p.events.firstWhere((e) => e.title == title);
    } catch (_) {
      return null;
    }
  }
}

class FavoritesService extends ChangeNotifier {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  static const _prefsKey = 'favorites_v1';

  final List<FavoriteItem> _items = [];
  bool _loaded = false;

  List<FavoriteItem> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _items.clear();
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final entry in list) {
          _items.add(FavoriteItem.fromJson(entry as Map<String, dynamic>));
        }
      } catch (_) {
        _items.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(FavoriteItem item) =>
      _items.any((i) => i.storageKey == item.storageKey);

  bool isFigureFavorite(String countryId, String periodId, String figureName) {
    return _items.any(
      (i) =>
          i.kind == FavoriteKind.figure &&
          i.countryId == countryId &&
          i.periodId == periodId &&
          i.figureName == figureName,
    );
  }

  bool isEventFavorite(String countryId, String periodId, String eventTitle) {
    return _items.any(
      (i) =>
          i.kind == FavoriteKind.event &&
          i.countryId == countryId &&
          i.periodId == periodId &&
          i.title == eventTitle,
    );
  }

  Future<void> toggle(FavoriteItem item) async {
    final index = _items.indexWhere((i) => i.storageKey == item.storageKey);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.insert(0, item);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(FavoriteItem item) async {
    _items.removeWhere((i) => i.storageKey == item.storageKey);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }
}
