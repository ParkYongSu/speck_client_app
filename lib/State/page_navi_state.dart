import 'package:flutter/material.dart';

class PageNaviState extends ChangeNotifier {
  String _start;

  void setStart(String start) {
    this._start = start;
  }

  String getStart() => this._start;
}