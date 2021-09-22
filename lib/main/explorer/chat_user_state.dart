import 'package:flutter/material.dart';

class ChatUserState extends ChangeNotifier {
  int _count;

  void setCount(int count) {
    this._count = count;
    notifyListeners();
  }

  int getCount() {
    return this._count;
  }
}