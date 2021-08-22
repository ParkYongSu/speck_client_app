import 'package:flutter/material.dart';

class TokenInitState extends ChangeNotifier {
  bool _isTokenInit = false;

  bool getIsTokenInit() {
    return this._isTokenInit;
  }

  setIsTokenInit(bool value) {
    _isTokenInit = value;
  }
}