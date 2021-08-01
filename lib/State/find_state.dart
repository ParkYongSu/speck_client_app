import 'package:flutter/material.dart';

class FindState extends ChangeNotifier {
  String _info;
  String _registerDate;

  void setInfo(String info) {
    this._info = info;
  }

  void setRegisterDate(String registerDate) {
    this._registerDate = registerDate;
  }

  String getInfo() => this._info;
  String getRegisterDate() => this._registerDate;
}