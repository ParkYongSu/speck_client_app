import 'package:flutter/material.dart';

class RegisterState extends ChangeNotifier {
  String _email;
  String _password;
  String _phoneNumber;
  String _gender;
  String _birthday1;
  String _birthday2;
  String _nickname;
  int _characterIndex;
  String _service;
  String _personalInformationCollection;
  String _receiveEventInformation;

  void setPhoneNumber(String phoneNumber) => this._phoneNumber = phoneNumber;
  void setGender(String gender) => this._gender = gender;
  void setBirthday1(String birthday) => this._birthday1 = birthday;
  void setBirthday2(String birthday) => this._birthday2 = birthday;
  void setEmail(String email) => this._email = email;
  void setPassword(String password) => this._password = password;
  void setNickname(String nickname) => this._nickname = nickname;
  void setCharacterIndex(int index) => this._characterIndex = index;
  void setService(String service) => this._service = service;
  void setPersonalInformationCollection(String personalInformationCollection)  => this._personalInformationCollection = personalInformationCollection;
  void setReceiveEventInformation(String receiveEventInformation) => this._receiveEventInformation = receiveEventInformation;

  String getEmail() => this._email;
  String getPassword() => this._password;
  String getPhoneNumber() => this._phoneNumber;
  String getGender() => this._gender;
  String getBirthday1() => this._birthday1;
  String getBirthday2() => this._birthday2;
  String getNickname() => this._nickname;
  int getCharacterIndex() => this._characterIndex;
  String getService() => this._service;
  String getPersonalInformationCollection() => this._personalInformationCollection;
  String getReceiveEventInformation() => this._receiveEventInformation;
}