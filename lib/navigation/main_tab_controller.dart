import 'package:flutter/foundation.dart';

/// 底部导航 Tab 切换（供首页等子页面跳转 Tab 使用）
class MainTabController extends ChangeNotifier {
  MainTabController._();

  static final MainTabController instance = MainTabController._();

  int _index = 0;

  int get index => _index;

  void switchTo(int index) {
    if (index < 0 || index > 4 || _index == index) return;
    _index = index;
    notifyListeners();
  }
}

enum MainTab {
  home(0),
  chronology(1),
  quiz(2),
  favorites(3),
  profile(4);

  final int tabIndex;
  const MainTab(this.tabIndex);
}
