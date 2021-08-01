import 'dart:convert';

import 'package:http/http.dart' as http;

class TodoAuth {
  Future<dynamic> request(var url, int weekday, String memberEmail,String date) async {
    String params = "&weekday=$weekday&memberEmail=$memberEmail&date=$date";
    print("params $params");
    var realUrl = Uri.parse(url + params);
    print(realUrl);
    var response = await http.get(realUrl);
    dynamic result = jsonDecode(response.body);
    print(result);
    return Future(() {
      return result;
    });
  }
}