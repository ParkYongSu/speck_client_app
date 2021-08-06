import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';
Future<String> requestSetting() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String email = sp.getString("email");
  String pw = sp.getString("pw");
  String phoneNumber = sp.getString("phoneNumber");
  String sex = sp.getString("sex");
  String bornTime = sp.get("bornTime");
  String nickname = sp.get("nickname");
  int characterIndex = sp.get("characterIndex");
  List<int> imageBytes = jsonDecode(sp.get("image"));

  Uri url = Uri.parse("http://$speckUrl/members/revise.do");
  var request = http.MultipartRequest('POST', url);
  String body = """{
    "email" : "$email",
    "pw" = "$pw",
    "phoneNumber" : "$phoneNumber",
    "sex" : "$sex",
    "bornTime" : "$bornTime",
    "nickname" : "$nickname",
    "characterIndex":"$characterIndex
  }""";
  Map<String, String> header = {
    "Content-Type" : "application/json"
  };
  request.fields["body"] = jsonEncode(body);
  request.files.add(http.MultipartFile.fromBytes("profile", imageBytes));


  var response = await request.send();
  var result;
  response.stream.transform(utf8.decoder).listen((value) {
    result = value;
  });
  return result;
}

Future<String> requestSetAccount(String accountOwner, String account, String subAccountOwner, String subAccount) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String email = sp.get("email");
  Uri url = Uri.parse("http://$speckUrl/money/set");
  String body = """{
    "email":"$email",
    "accountOwner":"$accountOwner",
    "account":"$account",
    "subAccountOwner":"$subAccountOwner",
    "subAccount":"$subAccount"
  }""";
  Map<String, String> header = {
    "Content-Type":"application/json"
  };

  var response = await http.post(url, body: body, headers: header);
  var result = jsonDecode(response.body);
  return Future(() {
    return result;
  });
}
