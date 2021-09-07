import 'package:flutter/material.dart';

class TutorialState extends ChangeNotifier {
  int _isTutorialState = 0;
  bool _isTutorialOpened = false;

  void setTutorialState(int tutorial) {
    this._isTutorialState = tutorial;
    notifyListeners();
  }

  int getTutorialState() {
    return this._isTutorialState;
  }

  void setTutorialOpened(bool value) {
    this._isTutorialOpened = value;
  }

  bool getTutorialOpened() {
    return this._isTutorialOpened;
  }
}
