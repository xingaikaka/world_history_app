import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingStreakService extends ChangeNotifier {
  ReadingStreakService._();

  static final ReadingStreakService instance = ReadingStreakService._();

  static const _prefsKey = 'reading_streak_v1';

  int _currentStreak = 0;
  int _longestStreak = 0;
  String? _lastActiveDate;
  bool _loaded = false;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _currentStreak = map['current'] as int? ?? 0;
        _longestStreak = map['longest'] as int? ?? 0;
        _lastActiveDate = map['lastDate'] as String?;
      } catch (_) {
        _currentStreak = 0;
        _longestStreak = 0;
        _lastActiveDate = null;
      }
    }
    _loaded = true;
    await recordActivity();
  }

  Future<void> recordActivity() async {
    final today = _dateKey(DateTime.now());
    if (_lastActiveDate == today) return;

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (_lastActiveDate == yesterday) {
      _currentStreak += 1;
    } else {
      _currentStreak = 1;
    }
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
    _lastActiveDate = today;
    await _persist();
    notifyListeners();
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'current': _currentStreak,
        'longest': _longestStreak,
        'lastDate': _lastActiveDate,
      }),
    );
  }
}
