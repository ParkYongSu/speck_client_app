import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speck_app/State/notice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';

class TodoNotice {
  // 서버에서 알림 리스트를 가져옴
  Future<List<dynamic>> getNoticeList() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    String token = sp.getString("token");
    print('email = $email');
    print('token = ${token.substring(1, token.length - 1)}');
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/split/alarm/get.do");
    String body = "email=$email";
    Map<String, String> header = {
      "member-token": "${token.substring(1, token.length - 1)}",
      "member-email": "$email",
      "Content-Type": "application/x-www-form-urlencoded"
    };
    var response = await http.post(url, headers: header, body: body);
    print('response = $response');
    var utf = utf8.decode(response.bodyBytes);
    List<dynamic> result = json.decode(utf);
    print("result: $result");
    print(result.runtimeType);
    return Future(() {
      return result;
    });
  }

  Future<String> deleteNotice(int id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    String token = sp.getString("token");
    print(id);
    print(email);
    print(token.substring(1, token.length - 1));
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/split/alarm/delete.do?alarmId=$id");
    Map<String, String> header = {
      "member-token" : "${token.substring(1, token.length - 1)}",
      "member-email" : "$email"
    };
    var response = await http.get(url, headers: header);
    var result = response.body;
    print("삭제 $result");
    return Future(() {
      return result;
    });
  }

  Widget systemNotice(BuildContext context, int id, String imagePath, String content, String transferTime) {
    UICriteria uiCriteria = new UICriteria();
    uiCriteria.init(context);
    Notice notice = Provider.of<Notice>(context, listen: false);
    return GestureDetector(
        child: AspectRatio(
          aspectRatio: 375/103,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraint) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.2330),
                  decoration: BoxDecoration(
                    color: (notice.getNotRead().contains(id))?Color(0XFFEFDC8B):Colors.white,
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: constraint.maxHeight * 0.3203,
                                width: constraint.maxHeight * 0.3203,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: greyD8D8D8, width: 0.5),
                                  image: DecorationImage(
                                    image: NetworkImage("$imagePath")
                                  )
                                ),
                              ),
                            ]
                        ),
                        SizedBox(width: constraint.maxWidth * 0.032),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                // margin: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  "$content",
                                  style: TextStyle(letterSpacing: 0.48, fontWeight: FontWeight.w500, color: mainColor, fontSize: uiCriteria.textSize3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text("시스템 · $transferTime", style: TextStyle(color: greyAAAAAA, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500)),
                            ]
                        ),
                      ]
                  )
              );
            },
          ),
        )
    );
  }

  Widget addFriendNotice(BuildContext context, int id, String imagePath, String nickname, String transferTime) {
    Notice notice = Provider.of<Notice>(context, listen: false);
    TodoNotice todoNotice = new TodoNotice();
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
              icon: Icons.delete,
              color: Color(0XFFe7535c),
              onTap: () async {
                Future future = todoNotice.deleteNotice(id);
                await future.then((value) {
                  if (value == "1") {
                    notice.deleteWidgetElement(id);
                    notice.sub();
                  }
                }, onError: (e) => print(e));
              }
          )
        ],
        child: GestureDetector(
            onTap: () {
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              height: MediaQuery.of(context).size.height * 0.11,
              decoration: BoxDecoration(
                  color: (notice.getNotRead().contains(id))?Color(0XFFEFF8FA):Colors.white,
                  border: Border(
                      bottom: BorderSide(
                          color: Color(0XFFE3E3E3)))),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 3.0, right: 10.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipOval(
                                child: Image.network("$imagePath",
                                    height: 35.0, width: 35.0)),
                          ]
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: Text(
                                "$nickname님이 회원님에게 친구요청을 보냈습니다.",
                                style: TextStyle(color: Colors.black, fontSize: 13.0),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text("유저 · $transferTime", style: TextStyle(color: Color(0XFFBDBDBD), fontSize: 10.0)),
                          ]
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom:5.0),
                                  width: 45,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: Color(0XFF4192EF),
                                      borderRadius: BorderRadius.circular(5.0)
                                  ),
                                  child: Text("수락", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0))
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text("밀어서 삭제", style: TextStyle(color: Color(0XFFBDBDBD), fontSize: 10.0))
                                  ]
                              )
                            ]
                        )
                    )
                  ]),
            )
        )
    );
  }
}