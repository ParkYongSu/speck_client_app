import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/firebase/firebase_init.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:http/http.dart' as http;

class SetNotification extends StatefulWidget {
  @override
  _SetNotificationState createState() => _SetNotificationState();
}

class _SetNotificationState extends State<SetNotification> {
  bool _todayAttendanceNotification;
  bool _timeLimit10;
  bool _pushNotification;
  bool _newGalaxy;

  SharedPreferences _sp;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyF0F0F1,
      appBar: appBar(context, "알림 설정"),
      body: _notificationSettingPage()
    );
  }

  Widget _notificationSettingPage() {
    return FutureBuilder(
      future: _getSharePreferencesInstance(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _timeLimit10 = _sp.getBool("before10")??true;
          _todayAttendanceNotification = _sp.getBool("todayAttendance")??true;
          _pushNotification = _sp.getBool("pushNotification")??true;
          _newGalaxy = _sp.getBool("newGalaxy")??true;
          return Container(
            child: Column(
              children: <Widget>[
                _title("나의 알림"),
                _myNotification(),
                _title("전체 알림"),
                _totalNotification()
              ],
            ),
          );
        }
        else {
          return loader(context, 0);
        }
      },
    );
  }

  Future<SharedPreferences> _getSharePreferencesInstance() async {
    _sp = await SharedPreferences.getInstance();
    return Future(() {
      return _sp;
    });
  }

  Widget _title(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(uiCriteria.horizontalPadding, uiCriteria.verticalPadding, 0, uiCriteria.totalHeight * 0.0147),
      child: Text(title, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),),
    );
  }

  Widget _myNotification() {
    return AspectRatio(
      aspectRatio: 375/74,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: uiCriteria.horizontalPadding, right: uiCriteria.horizontalPadding / 2),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("출석 시작 알림", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3),),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        activeColor: mainColor,
                        trackColor: greyD8D8D8,
                        value: _todayAttendanceNotification,
                        onChanged: (bool value) {
                          _setTodayAttendance();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: uiCriteria.horizontalPadding, right: uiCriteria.horizontalPadding / 2),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: greyD8D8D8))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("출석까지 10분 남았을 때", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3),),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        activeColor: mainColor,
                        trackColor: greyD8D8D8,
                        value: _timeLimit10,
                        onChanged: (bool value) {
                          _setBefore10();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalNotification() {
    return AspectRatio(
      aspectRatio: 375/74,
      child:  Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: uiCriteria.horizontalPadding, right: uiCriteria.horizontalPadding / 2),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5)),
                  color: Colors.white
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("갤럭시 업데이트 알림", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3),),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      activeColor: mainColor,
                      trackColor: greyD8D8D8,
                      value: _newGalaxy,
                      onChanged: (bool value) {
                        _setNewGalaxy();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: uiCriteria.horizontalPadding, right: uiCriteria.horizontalPadding / 2),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8)),
                  color: Colors.white
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("마케팅 알림", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3),),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      activeColor: mainColor,
                      trackColor: greyD8D8D8,
                      value: _pushNotification,
                      onChanged: (bool value) {
                        _setPushNotification();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Future<int> _setReceiveValue(int index, String value) async {
    var url = Uri.parse("$speckUrl/fcm/set/receive");
    String email = _sp.getString("email");
    String body = """{
      "email" : "$email",
      "index" : $index,
      "value" : "$value"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, body: body, headers: header);
    return int.parse(response.body);
  }

  void _setTodayAttendance() async {
    setState(() {
      _todayAttendanceNotification = !_todayAttendanceNotification;
    });
    if (_todayAttendanceNotification) {
      _setReceiveValue(0, "Y");
      await _sp.setBool("todayAttendance", true);
    }
    else {
      _setReceiveValue(0, "N");
      await _sp.setBool("todayAttendance", false);
    }
  }

  void _setBefore10() async {
    setState(() {
      _timeLimit10 = !_timeLimit10;
    });
    if (_timeLimit10) {
      _setReceiveValue(1, "Y");
      await _sp.setBool("before10", true);
    }
    else {
      _setReceiveValue(1, "N");
      await _sp.setBool("before10", false);
    }
  }

  void _setNewGalaxy() async {
    setState(() {
      _newGalaxy = !_newGalaxy;
    });
    if (_newGalaxy) {
      _setReceiveValue(2, "Y");
      firebaseMessaging.subscribeToTopic("newGalaxy");
      await _sp.setBool("newGalaxy", true);
    }
    else {
      _setReceiveValue(2, "N");
      firebaseMessaging.unsubscribeFromTopic("newGalaxy");
      await _sp.setBool("newGalaxy", false);
    }
  }

  void _setPushNotification() async {
    setState(() {
      _pushNotification = !_pushNotification;
    });
    if (_pushNotification) {
      _setReceiveValue(3, "Y");
      firebaseMessaging.subscribeToTopic("pushNotification");
      await _sp.setBool("pushNotification", true);
    }
    else {
      _setReceiveValue(3, "N");
      firebaseMessaging.unsubscribeFromTopic("pushNotification");
      await _sp.setBool("pushNotification", false);
    }
  }
}
