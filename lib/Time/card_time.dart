import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class CardTime extends ChangeNotifier {
  bool _isRunning = false;
  int _sec;
  Timer _timer;

  void setSeconds(int seconds) {
    if (seconds < 0) {
      this._sec = 0;
    }
    else {
      this._sec = seconds;
    }
  }
  // 지금 실행중인지 여부
  bool get isRunning => this._isRunning;

  // 초 가져오기
  int get seconds => this._sec;

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void stopTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    this._isRunning = true;
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      // 0초가 아닐 때까지 1씩 감소
      if (_sec > 0) {
        this._sec--;
        notifyListeners();
      }
      else {
        this._timer.cancel();
        this._isRunning = false;
      }
    });
  }
}
