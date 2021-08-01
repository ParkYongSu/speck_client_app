import 'package:flutter/material.dart';

class TimeSort extends ChangeNotifier {
  String _sortName = "예약자순";

  String getSortName() => _sortName;

  void setSortName(String sortName) {
    this._sortName = sortName;
    notifyListeners();
  }
}