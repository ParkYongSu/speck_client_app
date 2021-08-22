import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speck_app/State/notice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';

class MainNotifyPage extends StatefulWidget {
  @override
  MainNotifyPageState createState() => MainNotifyPageState();
}

class MainNotifyPageState extends State<MainNotifyPage> {

  @override
  Widget build(BuildContext context) {
    Notice _notice = Provider.of<Notice>(context, listen: false);
    return _notificationPage();
  }

  Widget _notificationPage() {
    return FutureBuilder(
      future: _getNotification(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<dynamic> notifyList = snapshot.data;
          if (notifyList.isNotEmpty) {
            return _notificationList(snapshot.data);
          }
          return Center(
            child: Text("아직 도착한 알림이 없어요", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700, letterSpacing: 0.7),),
          );
          }
        return loader(context, 0);
      }
    );
  }

  Future<List<dynamic>> _getNotification() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/user/notification");
    String body = """{
      "email" : "${sp.getString("email")}"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return Future(() {
      return result;
    });
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
      result.add(_notification(imageUrl, body, time, who));
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

  Widget _notification(String imageUrl, String body, String time, String who) {
    String date = _calDiff(time);

    return AspectRatio(
      aspectRatio: 375/103,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(flex: 24,),
                    Text(body, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.48),),
                    Spacer(flex: 10,),
                    Row(
                      children: <Widget>[
                        Text("$who ∙ ", style: TextStyle(color: greyAAAAAA, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w700, letterSpacing: 0.48)),
                        Text(date, style: TextStyle(color: greyAAAAAA, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w700, letterSpacing: 0.48))
                      ],
                    ),
                    Spacer(flex: 24,),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _noticeList;
  List<Widget> _noteList;
  @override
  void initState() {
    super.initState();
    _noticeList = [];
    _noteList = [];
  }

}

