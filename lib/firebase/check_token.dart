import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/firebase/token_init_state.dart';
import 'package:speck_app/util/util.dart';

/// 토큰 갱신
Future<int> _checkToken() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String email = sp.getString("email");
  String token = sp.getString("fcmToken");

  var url = Uri.parse("$speckUrl/fcm/check/token");
  String body = """{
    "email" : "$email",
    "token" : "$token"
  }""";
  Map<String, String> header = {
    "Content-Type" : "application/json"
  };
  var response = await http.post(url, headers: header, body: body);
  var result = response.body;
  print("result $result");
  return Future(() {
    return int.parse(result);
  });
}

void initToken(String email, BuildContext context) async {
  TokenInitState tis = Provider.of<TokenInitState>(context, listen: false);
  if (!tis.getIsTokenInit() && email != null) {
    tis.setIsTokenInit(true);
    Future future = _checkToken();
    future.then((value) => print("토큰 갱신 결과: $value"));
  }
}