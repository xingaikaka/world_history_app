import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reading_progress_service.dart';

class ReadingGoalService extends ChangeNotifier {
  ReadingGoalService._();

  static final ReadingGoalService instance = ReadingGoalService._();

  static const _prefsKey = 'reading_goal_v1';
  static const defaultWeeklyTarget = 3;

  int _weeklyTarget = defaultWeeklyTarget;
  bool _loaded = false;

  int get weeklyTarget => _weeklyTarget;
  bool get isLoaded => _loaded;

  int get thisWeekCount => ReadingProgressService.instance.visitsThisWeek();

  double get weeklyProgress =>
      _weeklyTarget == 0 ? 0 : (thisWeekCount / _weeklyTarget).clamp(0.0, 1.0);

  bool get isGoalMet => thisWeekCount >= _weeklyTarget;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _weeklyTarget = prefs.getInt(_prefsKey) ?? defaultWeeklyTarget;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setWeeklyTarget(int target) async {
    _weeklyTarget = target.clamp(1, 20);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, _weeklyTarget);
    notifyListeners();
  }
}
