import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'package:speck_app/util/util.dart';

class TodoLogin {
// todo 로그인하면 서버로부터 토큰을 받아와서 SharedPreference 로 저장
  Future<bool> confirmInfo(String email, String pw) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var f = new DateFormat("yyyy-MM-dd hh:mm:ss");
    // 갱신시간
    String current = f.format(DateTime.now().add(Duration(hours: 9)));
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/members/login");
    String body = "email=$email&pw=$pw";
    Map<String, String> header = {"Content-Type":"application/x-www-form-urlencoded"};
    var response = await http.post(url, body: body, headers: header);
    String token = response.body;
    print("token $token");
    if (token != "\"fail\"") { // 되게 위험한 로직
      try {
        jsonDecode(token);
        await sp.setString("tokenUpdateDate", current);
        // await sp.setString("email", email);
        await sp.setString("token", token);
        return new Future(() => true);
      }
      on Exception {
        return new Future(() => false);
      }
    }
    return new Future(() => false);
  }

  Future<dynamic> login(String email) async {
    Uri url = Uri.parse("http://$speckUrl/login");
    String body = '''{
      "email":"$email"
    }''';
    Map<String, String> header = {
      "Content-Type":"application/json"
    };

    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("result $result");
    return Future(() {
      return result;
    });
  }
}



