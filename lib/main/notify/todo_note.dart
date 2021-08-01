import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoNote {
  Future<List<dynamic>> getNoteList() async {
    // 캐시에서 이메일과 토큰을 가져옴
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    String token = sp.getString("token");
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/note/all/noteBoxes/get.do?toEmail=$email");
    var response = await http.post(url);
    dynamic utf = utf8.decode(response.bodyBytes);
    dynamic result = jsonDecode(utf);
    print(result);
    print(result.runtimeType);
    return Future(() {
      return result;
    });
  }

  void addNoteList(BuildContext context, List<Widget> noteList) async {
    // 결과를 담을 리스트 생성
    List<dynamic> result;
    Future future = getNoteList();
    await future.then((value) => result = value, onError: (e) => print(e));
    // 결과를 위젯에 할당
    for (int i = 0; i < result.length; i++) {
      String nickname = result[i]["nickname"]; // 닉네임
      String content = result[i]["content"]; // 마지막으로 보낸 쪽지
      int notRead = result[i]["notRead"]; // 안읽은 쪽지 개수
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(result[i]["noteTime"]);
      String noteTime = dt.year.toString() + "." + dt.month.toString() + "." + dt.day.toString()
          + " " + dt.hour.toString() + ":" + dt.minute.toString(); // 마지막으로 쪽지 보낸시간
      // 리스트에 추가
      String uuid = result[i]["uuid"]; // 채팅방 고유식별자
      String fromEmail = result[i]["fromEmail"]; // 누구로부터 온 채팅방인지
      noteList.add(
          GestureDetector(
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0XFFEEEFEF)))
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                height: MediaQuery.of(context).size.height * 0.11,
                width: MediaQuery.of(context).size.width,
                child: Row(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ClipOval(

                            ),
                            SizedBox(
                                width: 10.0
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("$nickname", style: TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold),),
                                  Text("$content", style: TextStyle(fontSize: 12.0, color: Colors.black,),),
                                  Text("$noteTime", style: TextStyle(fontSize: 10.0, color: Color(0XFF888888)))
                                ]
                            )
                          ]
                      ),
                      (notRead != 0)
                          ?Expanded(
                          child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Color(0XFFFFDD96),
                                  shape: BoxShape.circle
                              ),
                              child: Text("$notRead", style: TextStyle(color: Colors.white, fontSize: 10.0))
                          )
                      )
                          : Container()
                    ]
                )
            ),
          )
      );
    }
  }

  Future<List<dynamic>> getPostNotes(String fromEmail, String uuid) async {
    var url = Uri.parse("http://studyplant.kr/note/all/notes/get.do");
    String body = "fromEmail=$fromEmail&uuid=$uuid";
    var response = await http.post(url, body: body);
    var utf = utf8.decode(response.bodyBytes);
    dynamic result = json.decode(utf); // 해당 유저와의 모든 쪽지
    print(result);

    return Future(() {
      return result;
    });
  }

}