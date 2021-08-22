import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/Main/my/account/my_account_info.dart';
import 'package:speck_app/Main/my/setting/setting_all_info.dart';
import 'package:speck_app/main/home/page_state.dart';
import 'package:speck_app/main/my/setting/setting_notification.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';

class Settings extends StatelessWidget {
  final UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "내 설정",
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: mainColor,
          centerTitle: true,
          titleSpacing: 0,
          toolbarHeight: _uiCriteria.appBarHeight,
          backwardsCompatibility: false,
          // brightness: Brightness.dark,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
          title: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: _uiCriteria.screenWidth,
                child: Text("내 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
              GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Icon(Icons.chevron_left_rounded,
                        color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
        body: Container(
          width: _uiCriteria.screenWidth,
          height: _uiCriteria.totalHeight,
          padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0283),
          decoration: BoxDecoration(
            color: greyF0F0F1
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _userSettingTitle(context),
              _userSettingList(context),
              _serviceInfoTitle(context),
              _serviceInfoList(context),
              _logOutButton(context),
              _withdrawal(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userSettingTitle(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.0135),
        child: Text("사용자 설정", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),));
  }

  Widget _userSettingList(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/111,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              child: Container(
                width: _uiCriteria.screenWidth,
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("프로필 설정", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                    Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                  ],
                ),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileInfo())),
            ),
          ),
          Expanded(
            child: GestureDetector(
              child: Container(
                width: _uiCriteria.screenWidth,
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("알림 설정", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                    Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                  ],
                ),
              ),
              onTap: () => _navigateSetNotification(context),
            ),
          ),
          Expanded(
            child: GestureDetector(
              child: Container(
                width: _uiCriteria.screenWidth,
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("계좌 설정", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                    Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                  ],
                ),
              ),
              onTap: () => _navigateSetAccount(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceInfoTitle(BuildContext context) {
    return  Container(
        padding: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.0283, left: _uiCriteria.horizontalPadding, bottom: _uiCriteria.totalHeight * 0.0135),
        child: Text("서비스 정보", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),));
  }

  Widget _serviceInfoList(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/74,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => _connectNotion("https://www.notion.so/d173ec91ada74971b53d071f41208457"),
              child: Container(
                width: _uiCriteria.screenWidth,
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("이용약관", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                    Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _connectNotion("https://www.notion.so/e995ecdc270442668013e096c22d6a23"),
              child: Container(
                width: _uiCriteria.screenWidth,
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("개인정보 처리방침", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                    Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                  ],
                ),
              ),
            ),
          ),
          // Expanded(
          //   child: GestureDetector(
          //     child: Container(
          //       width: _uiCriteria.screenWidth,
          //       padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
          //       decoration: BoxDecoration(
          //           color: Colors.white,
          //           border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Row(
          //               children: <Widget>[
          //                 Text("버전 정보",style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
          //                 Text(" 1.0.0", style: TextStyle(letterSpacing: 0.6, color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),)
          //               ]
          //           ),
          //           Row(
          //             children: [
          //               Text("최신버전", style: TextStyle(letterSpacing: 0.6, color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
          //               SizedBox(width: _uiCriteria.screenWidth * 0.032,),
          //               Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,),
          //             ],
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _logOutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.0283),
      child: AspectRatio(
        aspectRatio: 375/37,
        child:  GestureDetector(
          onTap: () {
            _showLogoutDialog(context);
          },
          child: Container(
            width: _uiCriteria.screenWidth,
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("로그아웃", style: TextStyle(letterSpacing: 0.6, color: Color(0XFFe7535c), fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _logoutDialog(context);
        });
  }

  Widget _logoutDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      content: Container(
        width: _uiCriteria.screenWidth,
        child: AspectRatio(
          aspectRatio: 260/105,
          child: Column(
            children: [
              Expanded(
                  flex: 619,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      alignment: Alignment.center,
                      child: Text("정말 로그아웃하시겠어요?", style: TextStyle(letterSpacing: 0.7,color: mainColor, fontSize: _uiCriteria.screenWidth * 0.042, fontWeight: FontWeight.w700),))),
              Expanded(
                flex: 371,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                alignment: Alignment.center,
                                child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFF3478F6), fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
                            )
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _logout(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: greyD8D8D8, width: 0.5))),
                                alignment: Alignment.center,
                                child: Text("로그아웃", style: TextStyle(letterSpacing: 0.7, color: Color(0XFFe7535c), fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _withdrawalDialog(context);
        });
  }

  Widget _withdrawalDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      content: Container(
        width: _uiCriteria.screenWidth,
        child: AspectRatio(
          aspectRatio: 260/122,
          child: Column(
            children: [
              Expanded(
                  flex: 82,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(flex: 235,),
                          Text("정말 회원탈퇴 하시겠어요?", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.screenWidth * 0.042, fontWeight: FontWeight.w700),),
                          Spacer(flex: 50),
                          Text("탈퇴시 모든 데이터는 삭제됩니다", style: TextStyle(letterSpacing: 0.5, color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),),
                          Spacer(flex: 245,)
                        ],
                      ))),
              Expanded(
                flex: 39,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                alignment: Alignment.center,
                                child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFF3478F6), fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
                            )
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                alignment: Alignment.center,
                                child: Text("회원탈퇴", style: TextStyle(letterSpacing: 0.7, color: Color(0XFFe7535c), fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                            onTap:() => _requestWithdrawal(context),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _withdrawal(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWithdrawalDialog(context),
      child: Container(
        width: _uiCriteria.screenWidth,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0071),
        child: Text("회원탈퇴", style: TextStyle(letterSpacing: 0.5,color: greyAAAAAA, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize5, decoration: TextDecoration.underline)),
      ),
    );
  }

  /// 알림 설정 페이지로 이동
  void _navigateSetNotification(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SetNotification()));
  }

  void _navigateSetAccount(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AccountInfo()));
  }

  void _connectNotion(String url) async{
    await launch(url);
  }
  
  /// 기존서버
  void _logout(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    String token = sp.getString("token");
    var url = Uri.parse("$speckUrl/user/logout");
    String body = """{
      "userEmail" : "$email"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json",
      "Authorization" : "$token"
    };
    print(body);
    print(token);

    var response = await http.post(url, headers: header, body: body);
    var result = response.body;
    print(result);
    if (result == "true") {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmailLoginPage()), (route) => false);
    }
    else {
      errorToast("다시 한번 시도해주세요");
    }
  }

  void  _requestWithdrawal(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    String token = sp.getString("token");
    var url = Uri.parse("$speckUrl/withdraw");
    String body = """{
      "userEmail" : "$email"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json",
      "Authorization" : "$token"
    };
    print(header);
    var response = await http.post(url, headers: header, body: body);
    int code = int.parse(response.body);
    print(code);
    if (code == 100) {
      sp.clear();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmailLoginPage()), (route) => false);
    }
    else {
      errorToast("다시 한번 시도해주세요");
    }
  }

  void _requestWithdrawal2(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/withdraw");
    String body = '''{
      "email" : "${sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response= await http.post(url, headers: header, body: body);
    var code = int.parse(utf8.decode(response.bodyBytes));
    print(code);
    if (code == 100) {
      sp.clear();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmailLoginPage()), (route) => false);
    }
    else {

    }
  }
}
