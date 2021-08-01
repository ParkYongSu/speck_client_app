import 'dart:async';

import 'package:flutter/material.dart';

class AuthTimer extends ChangeNotifier {
  int _sec = 180;
  Timer _timer;
  bool _isRunning = false;

  int getSeconds() {
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
    notifyListeners();
  }

  // 인증요청 버튼 클릭 시 타이머 시작, 재전송 버튼 클릭 시에도 동일
  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    this._sec = 180;
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
        notifyListeners();
      }
    });
  }
}
