import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/State/find_state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'find_password_result.dart';

class FindPasswordPage extends StatefulWidget {
  @override
  State createState() => FindPasswordPageState();


}

class FindPasswordPageState extends State<FindPasswordPage> {
  final TextEditingController _emailController = new TextEditingController();
  final UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "비밀번호 찾기 페이지",
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: _uiCriteria.appBarHeight,
          centerTitle: true,
          elevation: 0,
          backgroundColor: mainColor,
          titleSpacing: 0,
          backwardsCompatibility: false,
          // brightness: Brightness.dark,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
          title: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.008),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                          child: Icon(Icons.chevron_left_rounded,
                              color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                          onTap: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Text("비밀번호 찾기",
                    style: TextStyle(
                      letterSpacing: 0.8,
                      fontSize: _uiCriteria.textSize16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
              ]
          ),
          // title: Text("비밀번호 찾기",
          //     style: TextStyle(fontSize: _uiCriteria.textSize16, color: Colors.black, fontWeight: FontWeight.w700)),

        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
            decoration: BoxDecoration(
                color: Colors.white),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("$_labelEmail", style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: _emailFW, color: mainColor)),
                ),
                AspectRatio(aspectRatio: 343/11),
                AspectRatio(
                  aspectRatio: 343/50,
                  child: TextField(
                    style: TextStyle(
                      letterSpacing: 0.7,
                      fontSize: _uiCriteria.textSize2, color: mainColor,),
                    cursorColor: mainColor,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          isDense: true,
                          suffixIcon: (_isTryAuth)
                              ? (_isRegistered)
                              ? null
                              : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,)
                              : null,
                          // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        hintText: "가입된 이메일 입력",
                        hintStyle: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.5),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: greyB3B3BC, width: 0.5)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: (_isTryAuth)
                              ? (_isRegistered)
                              ? BorderSide(color: greyB3B3BC, width: 0.5)
                              : BorderSide(color: mainColor, width: 1.5)
                              : BorderSide(color: greyB3B3BC, width: 0.5)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: (_isTryAuth)
                                ? (_isRegistered)
                                ? BorderSide(color: greyB3B3BC, width: 0.5)
                                : BorderSide(color: mainColor, width: 1.5)
                                : BorderSide(color: greyB3B3BC, width: 0.5))),
                    onChanged: (String value) {
                      if (value.length > 0) {
                        setState(() {
                          _isEmailEmpty = false;
                        });
                      } else {
                        setState(() {
                          _isEmailEmpty = true;
                        });
                      }
                    },
                  )
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 343/50,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.5)
                            ),
                            color:  mainColor,
                            disabledColor: greyD8D8D8,
                            onPressed:(!_isEmailEmpty)
                                ? () {
                              _receivePassword();
                              print(_isTryAuth);
                              //print(emptyOrNot.getIsEmpty());
                            }
                                : null,
                            child: Text("확인", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      )
                    ]
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isEmailEmpty;
  bool _isTryAuth;
  bool _isRegistered;
  String _labelEmail;
  FontWeight _emailFW;

  @override
  void initState() {
    super.initState();
    _isEmailEmpty = true; // 이메일이 비어있는지를 알려주는 변수
    _isTryAuth = false; // 인증요청 시도했는지
    _isRegistered = false;
    _labelEmail = "이메일";
    _emailFW = FontWeight.w700;
  }


  void _receivePassword() async {
    String email = _emailController.text;
    Future future = _checkEmail(email);
    dynamic result;
    print(result);
    await future.then((value) => result = value);
    int code = result["status"]["statusCode"];
    String joinTime;
    if (code == 240) {
       FindState findState = Provider.of<FindState>(context, listen: false);
       findState.setInfo(email);
       joinTime = result["response"]["joinTime"];
       findState.setRegisterDate(joinTime.toString().substring(0,10));
       Navigator.push(context, MaterialPageRoute(builder: (context) => FindPasswordResultPage()));
    }
    else if (code == 300) {
      setState(() {
        _labelEmail = "등록되지 않은 이메일이에요.";
        _emailFW = FontWeight.bold;
      });
    }
    else {
      _labelEmail = "다시 한번 시도해주세요.";
      _emailFW = FontWeight.bold;
    }
  }

  Future<dynamic> _checkEmail(String email) async {

    var url = Uri.parse("$speckUrl/mail/find/password");
    String body = """{
      "userEmail" : "$email"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return Future(() {
      return result;
    });
  }
}
