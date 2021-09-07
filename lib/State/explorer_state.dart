import 'package:flutter/material.dart';

class ExplorerState extends ChangeNotifier {
  String _galaxyName; // 학교이름
  String _imagePath; // 프로필
  int _galaxyNum; // 학교아이디
  int _timeNum;
  int _official;
  String _selectedDate;
  String _selectedDateWeekdayText;
  List<dynamic> _timeList;

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
}