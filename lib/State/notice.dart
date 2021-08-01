import "package:flutter/material.dart";

class Notice extends ChangeNotifier {
  //List<Widget> noticeList = [];
  Map<int, Widget> noticeMap = {};
  List<int> notRead = [];
  int count = 0;

  void add() {
    this.count++;
    notifyListeners();
  }

  void sub() {
    if (this.count > 0) this.count--;
    notifyListeners();
  }

  int getCount() {
    return this.count;
  }

  void setZero() {
    this.count = 0;
    notifyListeners();
  }


  void addWidget(int id, Widget widget) {
    this.noticeMap.addAll({id:widget});
    notifyListeners();
  }

  List<Widget> getWidgetList() {
    return this.noticeMap.values.toList();
  }

  List<int> getIdList() {
    return this.noticeMap.keys.toList();
  }

  void clearWidgetList() {
    this.noticeMap.clear();
    notifyListeners();
  }

  void deleteWidgetElement(int id) {
    this.noticeMap.remove(id);
    notifyListeners();
  }

  void addNotRead(int id) {
    this.notRead.add(id);
  }

  List<int> getNotRead() {
    return this.notRead;
  }

  void clearNotRead() {
    this.notRead.clear();
    notifyListeners();
  }
}