
import 'package:flutter/material.dart';

class NotificationState extends ChangeNotifier {
  List<dynamic> _notificationList;

  void setNotificationList(List<dynamic> notificationList) {
    this._notificationList = notificationList;
    notifyListeners();
  }

  List<dynamic> getNotificationList() {
    return this._notificationList;
  }

  bool isExistNew(List<dynamic> notificationList) {
    if (notificationList != null) {
      for (int i = 0; i < notificationList.length; i++) {
        if (notificationList[i]["value"] == 1) {
          return true;
        }
      }
      return false;
    }
    else {
      return false;
    }
  }
}