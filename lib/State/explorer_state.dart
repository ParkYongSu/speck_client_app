import 'package:flutter/material.dart';

class ExplorerState extends ChangeNotifier {
  String _galaxyName; // 학교이름
  String _imagePath; // 프로필
  String _totalPayment; // 누적 보증
  int _sumPerson; // 누적인원
  int _galaxyNum; // 학교아이디
  int _timeNum;
  int _official;
  String _selectedDate;
  String _selectedDateWeekdayText;
  int _route;
  List<dynamic> _timeList;
  int _bookInfo;

  String getGalaxyName() => _galaxyName;

  void setGalaxyName(String value) {
    _galaxyName = value;
  }

  String getImagePath() => _imagePath;

  void setImagePath(String value) {
    _imagePath = value;
  }

  List<dynamic> getTimeList() => _timeList;

  void setTimeList(List<dynamic> value) {
    _timeList = value;
  }

  int getRoute() => _route;

  void setRoute(int value) {
    _route = value;
  }

  String getSelectedDateWeekdayText() => _selectedDateWeekdayText;

  void setSelectedDateWeekdayText(String value) {
    _selectedDateWeekdayText = value;
    notifyListeners();
  }

  String getSelectedDate() => _selectedDate;

  void setSelectedDate(String value) {
    _selectedDate = value;
    notifyListeners();
  }

  int getOfficial() => _official;

  void setOfficial(int value) {
    _official = value;
  }

  int getTimeNum() => _timeNum;

  void setTimeNum(int value) {
    _timeNum = value;
  }

  int getGalaxyNum() => _galaxyNum;

  void setGalaxyNum(int value) {
    _galaxyNum = value;
  }

  int getSumPerson() => _sumPerson;

  void setSumPerson(int value) {
    _sumPerson = value;
  }

  String getTotalPayment() => _totalPayment;

  void setTotalPayment(String value) {
    _totalPayment = value;
  }

  int getBookInfo() => _bookInfo;

  void setBookInfo(int bookInfo) {
    _bookInfo = bookInfo;
  }
}