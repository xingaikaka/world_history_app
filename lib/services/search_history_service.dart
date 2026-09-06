import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchHistoryKind { country, figure, event }

class SearchHistoryService extends ChangeNotifier {
  SearchHistoryService._();

  static final SearchHistoryService instance = SearchHistoryService._();

  static const _prefsKey = 'search_history_v1';
  static const _maxPerKind = 8;

  final Map<SearchHistoryKind, List<String>> _items = {
    SearchHistoryKind.country: [],
    SearchHistoryKind.figure: [],
    SearchHistoryKind.event: [],
  };
  bool _loaded = false;

  List<String> forKind(SearchHistoryKind kind) =>
      List.unmodifiable(_items[kind] ?? []);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final kind in SearchHistoryKind.values) {
          final list = map[kind.name];
          if (list is List) {
            _items[kind] = list.cast<String>();
          }
        }
      } catch (_) {
        for (final kind in SearchHistoryKind.values) {
          _items[kind] = [];
        }
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(SearchHistoryKind kind, String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;

    final list = _items[kind] ?? [];
    list.remove(trimmed);
    list.insert(0, trimmed);
    if (list.length > _maxPerKind) {
      list.removeRange(_maxPerKind, list.length);
    }
    _items[kind] = list;
    await _persist();
    notifyListeners();
  }

  Future<void> remove(SearchHistoryKind kind, String query) async {
    _items[kind]?.remove(query);
    await _persist();
    notifyListeners();
  }

  Future<void> clear(SearchHistoryKind kind) async {
    _items[kind] = [];
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      for (final kind in SearchHistoryKind.values) kind.name: _items[kind],
    });
    await prefs.setString(_prefsKey, encoded);
  }
}
