import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AboutTime extends ChangeNotifier {
  bool _isRunning = false;
  int _secs = 0;
  Timer _timer;

  // 지금 실행중인지 여부
  bool get isRunning => this._isRunning;

  // 초 가져오기
  int get seconds => this._secs;

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void startTimer() async{
    this._isRunning = true;
    _secs = 0;
    _timer = Timer.periodic((Duration(seconds: 1)), (Timer timer) {
      _secs++;
      notifyListeners();
    });
  }

  void pauseTimer() async {
    if (_isRunning & (_timer != null)) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setInt("seconds", seconds + sp.getInt("seconds"));
      print(sp.getInt("seconds"));
      _timer.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _secs = 0;
    _isRunning = false;
    notifyListeners();
  }
}
