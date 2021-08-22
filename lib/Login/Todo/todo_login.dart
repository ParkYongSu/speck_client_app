import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'package:speck_app/util/util.dart';

class TodoLogin {
// todo 로그인하면 서버로부터 토큰을 받아와서 SharedPreference 로 저장

  Future<dynamic> login(String email, String pw) async {
    var url = Uri.parse("$speckUrl/user/login");
    String body = """{
      "userEmail" : "$email",
      "password" : "$pw" 
    }""";
    print(body);
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("result $result");
    return result;
  }
}



