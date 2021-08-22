import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/util/util.dart';

class TodoRegister {
  //todo.1 아이디 중복확인 가입된 이메일이 있는지 확인하는 거로 메서드 이름 바꾸기
  Future<bool> isIdDuplicated(String email) async {
    var url = Uri.parse("$speckUrl/signup/isExist/email");
    String body = """{
      "userEmail" : "$email"
    }""";
    Map<String, String> header = {
      "Content-Type":"application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = utf8.decode(response.bodyBytes);
    print(result);
    return Future(() {
      if (result == "true") {
        return true;
      }
      return false;
    });
  }

  Future<bool> isPhoneNumberDuplicated(String phoneNumber) async {
    var url = Uri.parse("$speckUrl/signup/isExist/phoneNumber");
    String body = """{
      "phoneNumber" : "$phoneNumber"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var result = utf8.decode(response.bodyBytes);
    print(result);
    return Future(() {
      if (result == "true") {
        return true;
      }
      return false;
    });
  }



// todo.4 네이버 클라우드 인증번호 보내기
  /// 회원이면 status 202
  Future<dynamic> getAuthNumber(String phoneNumber) async {
      var url = Uri.parse("$speckUrl/sms/join");
      String body = """{
        "phoneNum" : "$phoneNumber"
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

// todo.7 닉네임 중복확인
  Future<bool> isNicknameDuplicated(String nickname) async {
    var url = Uri.parse("$speckUrl/signup/isExist/nickName");
    String body = """{
      "nickName" : "$nickname"
    }""";
    Map<String, String> header = {
      "Content-Type": "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = utf8.decode(response.bodyBytes);
    print("result343 $result");
    // 닉네임 중복이면 true
    return Future(() {
      if (result == "true") {
        return true;
      }
      return false;
    });
  }

// todo.8 조건만족 시 회원가입
  Future<int> requestUserDataProfile(String email, String pw, String phoneNumber, String nickname,
      String sex, String bornTime, int characterIndex, String service, String personalInformationCollection, String receiveEventInformation, File image) async {
    var url = Uri.parse("$speckUrl/signup/profile");
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
    var url = Uri.parse("$speckUrl/signup/none-profile");
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
    var response = await http.post(url, headers: header, body: body);
    var code = int.parse(response.body);
    print(code);
    return Future(() {
      return code;
    });
  }
}
