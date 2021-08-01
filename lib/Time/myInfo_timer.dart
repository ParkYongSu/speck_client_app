import 'dart:async';

import 'package:flutter/material.dart';

class MyInfoTimer extends ChangeNotifier {
  int _sec;
  Timer _timer;
  bool _isRunning = false;

  void setTime(int second) {
    if (second < 0) {
      this._sec = 0;
    }
    else {
      this._sec = second;
    }
  }

  int getTime() {
    return this._sec;
  }

  bool getIsRunning() {
    return this._isRunning;
  }

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