import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Login/Find/find_password_page.dart';
import 'package:speck_app/Login/Home/home_login_page.dart';
import 'package:speck_app/State/banner_state.dart';
import 'package:speck_app/firebase/check_token.dart';
import 'package:speck_app/main.dart';
import 'package:speck_app/Main/home/main_home.dart';
import 'package:speck_app/Main/main_page.dart';
import 'package:speck_app/Register/register_page1.dart';
import 'package:speck_app/State/page_navi_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Todo/todo_login.dart';
import 'package:speck_app/main/home/page_state.dart';
import 'package:speck_app/route/route_builder.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import '../Find/find_email_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';

class EmailLoginPage extends StatefulWidget {
  @override
  State createState() {
    return EmailLoginPageState();
  }
}

class EmailLoginPageState extends State<EmailLoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final UICriteria _uiCriteria = new UICriteria();
  SharedPreferences _sp;
  BannerState _bs;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _bs = Provider.of<BannerState>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: _uiCriteria.appBarHeight,
          elevation: 0,
          centerTitle: true,
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
                      // GestureDetector(
                      //     child: Icon(Icons.chevron_left_rounded,
                      //         color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                      //     // onTap: () => Navigator.pop(context)
                      //     onTap: () =>  Navigator.of(context).push(createRoute1(HomeLoginPage())),
                      // ),
                    ],
                  ),
                ),
                Text("이메일로 로그인",
                    style: TextStyle(
                      letterSpacing: 0.8,
                      fontSize: _uiCriteria.textSize1,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
              ]
          ),
          backgroundColor: mainColor,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.verticalPadding),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 343/50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.5),
                            border:
                            (_isTryLogin)
                                ? (_result)
                                ? Border.all(color: greyB3B3BC, width: 0.5)
                                : Border.all(color: mainColor, width: 1.5)
                                : Border.all(color: greyB3B3BC, width: 0.5)
                        ),
                      ),
                      TextField(
                        cursorColor: mainColor,
                        style: TextStyle(
                            letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: mainColor),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                          isDense: true,
                          // contentPadding: const EdgeInsets.symmetric(
                          //     horizontal: 10.0, vertical: 10.0),
                          hintText: "이메일",
                          hintStyle:
                          TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC,),
                          border: InputBorder.none,
                        ),
                        focusNode: _emailFocus,
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
                      ),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 343/11,
                ),
                AspectRatio(
                  aspectRatio: 343/50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.5),
                            border:
                            (_isTryLogin)
                                ? (_result)
                                ? Border.all(color: greyB3B3BC, width: 0.5)
                                : Border.all(color: mainColor, width: 1.5)
                                : Border.all(color: greyB3B3BC, width: 0.5)
                        ),
                      ),
                      TextField(
                          cursorColor: mainColor,
                          controller: _passwordController,
                          style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: mainColor),
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                              isDense: true,
                              // contentPadding: const EdgeInsets.symmetric(
                              //     horizontal: 10.0, vertical: 10.0),
                              hintText: "비밀번호",
                              hintStyle:
                              TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC),
                              border: InputBorder.none
                          ),
                          focusNode: _passwordFocus,
                          onChanged: (String value) {
                            if (value.length > 0) {
                              setState(() {
                                _isPasswordEmpty = false;
                              });
                            } else {
                              setState(() {
                                _isPasswordEmpty = true;
                              });
                            }
                          }),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 375/36,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("$_resultMessage",
                        style: TextStyle(
                            letterSpacing: 0.6,
                            color: mainColor,
                            fontSize: _uiCriteria.textSize3,
                            fontWeight: FontWeight.bold
                        )),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 343/50,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: MaterialButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.5)
                        ),
                        disabledColor: greyD8D8D8,
                        color: mainColor,
                        child: Text("로그인", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500)),
                        onPressed: (!_isEmailEmpty && !_isPasswordEmpty)
                            ? () => _pressLogin()
                            : null,
                      )),
                ),
                AspectRatio(
                  aspectRatio: 343/11,
                  child: SizedBox(
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Text("이메일 찾기",
                            style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, color: greyB3B3BC),
                            textAlign: TextAlign.center),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FindEmailPage())),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: _uiCriteria.screenWidth * 0.025,
                      color: greyB3B3BC,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Text("비밀번호 찾기",
                            style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, color: greyB3B3BC),
                            textAlign: TextAlign.center),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FindPasswordPage())),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: _uiCriteria.screenWidth * 0.025,
                      color: greyB3B3BC,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Text("회원가입",
                            style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, color: greyB3B3BC),
                            textAlign: TextAlign.center),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage1()));
                          PageNaviState pns = Provider.of<PageNaviState>(
                              context,
                              listen: false);
                          pns.setStart("emailLogin");
                        },
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        )
    );
  }

  FocusNode _emailFocus;
  FocusNode _passwordFocus;
  bool _isEmailEmpty;
  bool _isPasswordEmpty;
  bool _isTryLogin;
  bool _result;
  String _resultMessage;
  @override
  void initState() {
    super.initState();
    _emailFocus = new FocusNode();
    _passwordFocus = new FocusNode();
    _isEmailEmpty = true;
    _isPasswordEmpty = true;
    _isTryLogin = false;
    _resultMessage = "";
    _result = false;
  }


  @override
  void dispose() {
    super.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
  }

  void _pressLogin() async {
    _sp = await SharedPreferences.getInstance();
    String email = _emailController.text;
    String pw = _passwordController.text;
    TodoLogin todoLogin = new TodoLogin(); // 전역변수
    dynamic userData;
    Future future = todoLogin.login(email, pw);
    await future.then((value) => setState(() {
      _isTryLogin = true;
      userData = value;
    }), onError: (e) => print(e));
    print("_result $_result");

    int statusCode = userData["defaultRes"]["statusCode"];
    String token = userData["token"];
    dynamic userInfo = userData["userInfo"];

    if (statusCode == 200) {
      DateTime current = DateTime.now();
      await _sp.setString("email", userInfo["email"]);
      await _sp.setString("sex", userInfo["sex"]);
      await _sp.setString("bornTime", userInfo["bornTime"]);
      await _sp.setString("nickname", userInfo["nickname"]);
      await _sp.setString("phoneNumber", userInfo["phoneNumber"]);
      await _sp.setInt("characterIndex", userInfo["characterIndex"]);
      await _sp.setString("profile", userInfo["profile"]??"N");
      await _sp.setInt("userId", userInfo["userId"]);
      await _sp.setString("token", token.substring(0, token.length));
      await _sp.setString("tokenUpdateDate", current.toString());

      _checkBanner();
      initToken(email, context);
      setState(() {
        _resultMessage = "";
        _result = true;
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainNavigation()), (route) => false);
    }
    else {
      FocusScope.of(context).unfocus();
      setState(() {
        _resultMessage = "이메일과 비밀번호를 확인해주세요.";
        _result = false;
      });
    }
  }

  Future<dynamic>_bannerData() async {
    var url = Uri.parse("$speckUrl/home");
    String body = '''{
      "userEmail" : "${_sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    return result;
  }

  void _checkBanner() async {
    Future future = _bannerData();
    dynamic data;
    await future.then((value) => data = value).onError((error, stackTrace) => print(error));
    print("배너 데이터 $data");
    if (_bs.getEventStatus() == null) {
      _bs.setEventStatus(data["value"]);
    }

    if (_bs.getGalaxyStatus() == null) {
      _bs.setGalaxyStatus(data["galaxy"]);
    }

    if (_bs.getMapStatus() == null) {
      _bs.setMapStatus(data["map"]);
    }
  }
}
