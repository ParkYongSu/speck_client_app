import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoRegister {
  //todo.1 아이디 중복확인 가입된 이메일이 있는지 확인하는 거로 메서드 이름 바꾸기
  Future<bool> isIdDuplicated(String email) async {
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/members/email/get.do");
    String body = "email=$email";
    Map<String, String> header = {
      "Content-Type":"application/x-www-form-urlencoded"
    };
    var response = await http.post(url, body: body, headers: header);
    String result = response.body;
    if ("\"" + email + "\"" == result) {
      return new Future(() => true);
    }
    // 서버에서 받아온 값과 입력한 값이 다르면 false 리턴
    return new Future(() => false);
  }

// todo.4 네이버 클라우드 인증번호 보내기
  /// 회원이면 status 202 아니면 500을 응답으로 받음
  Future<dynamic> getAuthNumber(String phoneNumber) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("authTime", DateTime.now().toString());
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/sms/reg/receive.do");
    String pNum = phoneNumber;
    var response = await http.post(url,
        body: "pNum=$pNum",
        headers: {"Content-Type": "application/x-www-form-urlencoded"});
    print("response: $response");
    dynamic authNumber = jsonDecode(response.body);
    print("인증번호 응답");
    print("authNumber: $authNumber");
    return Future(() {
      return authNumber;
    });
  }

// todo.7 닉네임 중복확인
  Future<bool> isNicknameDuplicated(String nickname) async {
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/members/check/nick");
    String body = "nickname=$nickname";
    Map<String, String> header = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = utf8.decode(response.bodyBytes);
    print(result);
    // 닉네임 중복이면 true
    if ("\"" + nickname.toLowerCase() + "\"" == result.toLowerCase()) {
      return new Future(() => true);
    }
    // 중복이 아니면 false
    else {
      return new Future(() => false);
    }
  }

// todo.8 조건만족 시 회원가입 성공
  Future<String> register1(String email, String pw, String phoneNumber,
    String nickname, String sex, String bornTime) async {
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/members/register.do");
    String body =
        '''{"email":"$email","pw":"$pw","phoneNumber":"$phoneNumber","sex":"$sex","bornTime":"$bornTime","nickname":"$nickname"}''';
    print(body);
    Map<String, String> header = {"Content-Type":"application/json"};

    var response = await http.post(url, body: body, headers: header);
    String result = response.body;
    print("result: $result");
    // 회원가입 성공하면 100, 실패하면 101
    return new Future(() => result);
  }

  Future<int> requestUserDataProfile(String email, String pw, String phoneNumber, String nickname,
      String sex, String bornTime, int characterIndex, String service, String personalInformationCollection, String receiveEventInformation, File image) async {
    var url = Uri.parse("http://13.209.138.39:8080/signup/profile");
    var request = http.MultipartRequest('POST', url);
    String signUpData = """ {
      "email":"$email",
      "pw":"$pw",
      "phoneNumber":"$phoneNumber",
      "sex":"$sex",
      "bornTime":"$bornTime",
      "nickname":"$nickname",
      "characterIndex":$characterIndex
    } """;
    String terms = ''' {
      "service" : "$service",
      "personalInformationCollection" : "$personalInformationCollection",
      "receiveEventInformation" : "$receiveEventInformation"
    } ''';

    request.fields["signUpData"] = "$signUpData";
    request.fields["terms"] = "$terms";
    request.files.add(http.MultipartFile.fromBytes("profile", image.readAsBytesSync(), filename: ".jpg"));
    http.Response response = await http.Response.fromStream(await request.send());
    var result = int.parse(response.body);
    print("결과 $result");
    // return result;

    print("회원 데이터 요청결과 $result");
    return Future(() {
      return result;
    });
  }

  Future<int> requestUSerDataNoneProfile(String email, String pw, String phoneNumber, String nickname,
      String sex, String bornTime, int characterIndex, String service, String personalInformationCollection, String receiveEventInformation) async {
    var url = Uri.parse("http://13.209.138.39:8080/signup/none-profile");
    String body = """ {
      "email" : "$email", 
	    "pw" : "$pw", 
	    "bornTime" : "$bornTime",  
    	"sex" : "$sex",  
    	"nickname": "$nickname",
    	"phoneNumber" : "$phoneNumber",   
    	"characterIndex" : $characterIndex,
    	"service" : "$service",  
    	"personalInformationCollection" : "$personalInformationCollection", 
    	"receiveEventInformation" : "$receiveEventInformation" 
    } """;
    print(body);
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    var response = await http.post(url, headers: header, body: body);
    print(response);
    var code = int.parse(response.body);
    print(code);
    return Future(() {
      return code;
    });
  }

  // todo.9 3분 지났는지 확인
  Future<String> isTimeout(String dt) async {
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/members/phone/auth.do?now=$dt");
    var response = await http.get(url);
    String result = response.body;
    print(result);
    return Future(() {
      return result;
    });
  }
}
