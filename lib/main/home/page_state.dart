import 'package:flutter/material.dart';

class PageState extends ChangeNotifier {
  int _selectedIndex = 0;

  void setIndex(int index) {
    this._selectedIndex = index;
    notifyListeners();
  }

  void setIndex1(int index) {
    this._selectedIndex = index;
  }

  int getIndex() {
    return this._selectedIndex;
  }
}