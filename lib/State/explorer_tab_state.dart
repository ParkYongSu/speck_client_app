
import 'package:flutter/material.dart';

class ExplorerTabState extends ChangeNotifier {
  int _tabIndex = 1;

  void setTabIndex1(int tabIndex) {
    this._tabIndex = tabIndex;
  }

  void setTabIndex2(int tabIndex) {
    this._tabIndex = tabIndex;
    notifyListeners();
  }

  int getTabIndex() {
    return this._tabIndex;
  }
}