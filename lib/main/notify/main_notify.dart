
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/Main/home/page_state.dart';
import 'package:speck_app/main/notify/notification_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';

class MainNotifyPage extends StatefulWidget {

  @override
  MainNotifyPageState createState() => MainNotifyPageState();
}

class MainNotifyPageState extends State<MainNotifyPage> {
  NotificationState _ns;
  PageState _ps;
  ReceivePort _receivePort;
  Isolate _isolate;

  @override
  void initState() {
    super.initState();
    _confirmIsolate();
  }

  @override
  Widget build(BuildContext context) {
    _ns = Provider.of<NotificationState>(context, listen: false);
    _ps = Provider.of<PageState>(context, listen: false);
    return _notificationPage();
  }

  Widget _notificationPage() {
    return _notificationList(_ns.getNotificationList());
  }

  void _selectionSort(List<dynamic> list) {
    for (int i = 0; i < list.length - 1; i++) {
      int min = i;
      for (int j = i + 1; j < list.length; j++) {
        if (DateTime.parse(list[min]["date"]).isBefore(DateTime.parse(list[j]["date"]))) {
          min = j;
        }
      }
      dynamic temp = list[i];
      list[i] = list[min];
      list[min] = temp;
    }
  }

  Widget _notificationList(List<dynamic> data) {
    _selectionSort(data);
    List<Widget> result = [];
    for (int i = 0; i < data.length; i++) {
      String imageUrl = data[i]["imageUrl"];
      String body = data[i]["body"];
      String time = data[i]["date"];
      String who = data[i]["who"];
      int value = data[i]["value"];
      int notificationId = data[i]["notificationId"];
      result.add(_notification(notificationId, imageUrl, body, time, who, value));
    }

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (BuildContext context, int index) {
        return result[index];
      },
    );
  }

  String _calDiff(String time) {
    String result;
    DateTime sendDate = DateTime.parse(time);
    Duration diff = DateTime.now().difference(sendDate);
    if (diff.inHours == 0) {
      result = "방금전";
    }
    else if (diff.inHours < 24) {
      result = "${diff.inHours}시간전";
    }
    else {
      result = "${diff.inDays}일전";
    }
    return result;
  }

  Widget _notification(int notificationId, String imageUrl, String body, String time, String who, int value) {
    String date = _calDiff(time);

    return GestureDetector(
      onTap: (notificationId == 3)
      ? () {
        _ps.setIndex(1);
      }
      : null,
      child: AspectRatio(
        aspectRatio: 375 / 103,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              decoration: BoxDecoration(
                  color: (value == 0) ? Colors.white : Color(0XFFEFDC8B)
                      .withOpacity(0.1)
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: uiCriteria.horizontalPadding),
              child: Row(
                children: <Widget>[
                  Column(
                    children: [
                      Spacer(flex: 24,),
                      Container(
                        width: constraint.maxHeight * 0.32,
                        height: constraint.maxHeight * 0.32,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                            )
                        ),
                      ),
                      Spacer(flex: 46,),
                    ],
                  ),
                  SizedBox(width: uiCriteria.screenHeight * 0.032,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Spacer(flex: 24,),
                        Text(body, style: TextStyle(color: mainColor,
                            fontSize: uiCriteria.textSize3,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.48),),
                        Spacer(flex: 10,),
                        Row(
                          children: <Widget>[
                            Text("$who ∙ ", style: TextStyle(color: greyAAAAAA,
                                fontSize: uiCriteria.textSize5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.48)),
                            Text(date, style: TextStyle(color: greyAAAAAA,
                                fontSize: uiCriteria.textSize5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.48))
                          ],
                        ),
                        Spacer(flex: 24,),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void confirmNotification(List<Object> data) async {
    SendPort sendPort = data[0];
    String email = data[1];
    var url = Uri.parse("$speckUrl/user/notification/confirm");
    String body = """{
      "email" : "$email"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    dynamic result = response.body;
    print("result $result");
    sendPort.send(result);
  }

  void _confirmIsolate() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    _receivePort = new ReceivePort();
    _isolate = await Isolate.spawn(confirmNotification, [_receivePort.sendPort, email]);
    _receivePort.listen(_handleMessage);
  }

  void _handleMessage(dynamic message) {
    print(message);
    if (int.parse(message) == 200) {
      _receivePort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    else {
      _confirmIsolate();
    }
  }
}

