
import 'package:flutter/material.dart';

class AuthStatus extends ChangeNotifier {
  int _status = 200;

  int getStatus() {
    return this._status;
  }

  void setStatus(int status) {
    this._status = status;
  }
}