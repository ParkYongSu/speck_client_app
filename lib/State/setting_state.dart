import 'package:flutter/material.dart';

class SettingState extends ChangeNotifier {
  String _profile;
  String _character;
  String _phoneNumber;
  String _gender;
  String _bornTime;

  String getProfile() {
    return this._profile;
  }

  void setProfile(String nickname) {
    this._profile = nickname;
    notifyListeners();
  }

  String getCharacter() {
    return this._character;
  }

  void setCharacter(String character) {
    this._character = character;
    notifyListeners();
  }


  String getBornTime() => _bornTime;

  setBornTime(String value) {
    _bornTime = value;
    notifyListeners();
  }

  String getGender() => _gender;

  setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  String getPhoneNumber() => _phoneNumber;

  setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }
}