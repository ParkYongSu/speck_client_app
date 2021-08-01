import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/State/find_state.dart';
import 'package:speck_app/Time/auth_timer.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'find_email_result.dart';
import "package:intl/intl.dart";

class FindEmailPage extends StatefulWidget {
  @override
  State createState() => FindEmailPageState();
}

class FindEmailPageState extends State<FindEmailPage> {
  final TextEditingController _pNumController = new TextEditingController();
  final TextEditingController _authNumController = new TextEditingController();
  final UICriteria _uiCriteria = new UICriteria();

  List<Widget> widgets = <Widget>[];
  bool _isOver;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    AuthTimer _authTimer = Provider.of<AuthTimer>(context, listen: true);
    int _total = _authTimer.getSeconds();
    int _min = _total ~/ 60;
    int _sec = _total - (_min * 60);
    _isOver = _isRequested
        ? _authTimer.getIsRunning()
        ? false
        : true
        :false;
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "이메일 찾기 페이지",
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: mainColor,
          toolbarHeight: _uiCriteria.appBarHeight,
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
              Text("이메일 찾기",
                  style: TextStyle(
                    letterSpacing: 0.8,
                    fontSize: _uiCriteria.textSize1,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
            ]
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
            ),
            padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
            child: Column(children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  child: (_isOver)?Text("인증시간이 초과되었어요.", style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.bold, color:mainColor)):Text("$_labelPNum",
                     style: TextStyle(
                          letterSpacing: 0.7,
                          fontSize: _uiCriteria.textSize2,
                          fontWeight: _pNumFW,
                          color: mainColor))),
              AspectRatio(
                  aspectRatio: 343/11,
              ),
              AspectRatio(
                  aspectRatio: 343/50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 294,
                        child: Container(
                          decoration: BoxDecoration(
                              color: _isAuthCorrect?greyF5F5F6:Colors.transparent,
                              borderRadius: BorderRadius.circular(3.5)
                          ),
                          child: TextField(
                            enabled: (_isAuthCorrect)?false:true,
                            maxLength: 11,
                            cursorColor: mainColor,
                            style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: (_isAuthCorrect)?greyB3B3BC:mainColor),
                            onChanged: (String value) {
                              if (value.length > 0) {
                                setState((){
                                  _pNumIsNotEmpty = true;
                                });
                              }
                              else {
                                setState(() {
                                  _pNumIsNotEmpty = false;
                                });
                              }
                            },
                            // maxLines: 2,
                            controller: _pNumController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                isDense: true,
                                counterText: "",
                                suffixIcon: (_isRequested)
                                    ? (_isRegistered)
                                    ? (_isAuthCorrect)
                                    ? null
                                    : Container(
                                    width: _uiCriteria.screenWidth * 0.25,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.all(_uiCriteria.textSize2),
                                    child: Text(
                                        "${_min.toString().padLeft(2, "0")} : ${_sec.toString().padLeft(2, "0")}",
                                        style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.screenWidth * 0.033, color: mainColor, ))

                                )
                                    : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,)
                                    : null,
                                // contentPadding: EdgeInsets.symmetric(
                                //     horizontal: 10.0, vertical: 10.0),
                                hintText: "- 없이 숫자만 입력",
                                hintStyle: TextStyle(letterSpacing: 0.7, color: greyB3B3BC, fontSize: _uiCriteria.textSize2, height: 1.5),
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: (_isRequested)
                                        ? (_isRegistered)
                                        ? (_isOver)
                                        ? BorderSide(color: mainColor, width: 1.5)
                                        : BorderSide(color: greyB3B3BC, width: 0.5)
                                        : BorderSide(color: mainColor, width: 1.5)
                                        : BorderSide(color: greyB3B3BC, width: 0.5)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: (_isRequested)
                                        ? (_isRegistered)
                                        ? (_isOver)
                                        ? BorderSide(color: mainColor, width: 1.5)
                                        : BorderSide(color: greyB3B3BC, width: 0.5)
                                        : BorderSide(color: mainColor, width: 1.5)
                                        : BorderSide(color: greyB3B3BC, width: 0.5))),

                          ),
                        )
                        ),
                      AspectRatio(
                          aspectRatio: 12/50,
                      ),
                      Expanded(
                        flex: 100,
                        child: Container(
                            height: double.infinity,
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.5)
                              ),
                              disabledColor: _isAuthCorrect?greyF5F5F6:greyD8D8D8,
                              elevation: 0,
                              color: mainColor,
                              child:  _isRegistered
                                  ? AutoSizeText("재요청", maxLines: 1, minFontSize: 10,style: TextStyle(letterSpacing: 0.7, color: _isAuthCorrect?greyB3B3BC:Colors.white, fontSize: _uiCriteria.textSize2,fontWeight: FontWeight.w700,))
                                  : AutoSizeText("인증요청", maxLines: 1, minFontSize: 10,style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2,fontWeight: FontWeight.w700,)),
                              onPressed: (_pNumIsNotEmpty)
                                  ? (_isAuthCorrect)
                                  ? null
                                  : () {
                                setState(() {
                                  _isTryAuth = false;
                                  _isAuthCorrect = false;
                                });
                                _authTimer.startTimer();
                                _receiveAuthIfUser();
                              }
                                  : null,
                              // onPressed: (_pNumIsNotEmpty)
                              //     ?(_isAuthCorrect)
                              //     ? null
                              //     :() {
                              //   _authTimer.startTimer();
                              //   _receiveAuthIfUser();
                              // }
                              //     : null,
                            )

                        ),
                      )
                    ],
                  ),
              ),
              AspectRatio(
                aspectRatio: 343/11,
              ),
              (_isRegistered)
              ? AspectRatio(
                aspectRatio: 343/50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 294,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isAuthCorrect?greyF5F5F6:Colors.transparent
                          ),
                          child: TextField(
                                    style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: _isAuthCorrect? greyB3B3BC : mainColor,) ,
                                    enabled: (_isAuthCorrect)? false:true,
                                    cursorColor: mainColor,
                                    maxLength: 4,
                                    onChanged: (String value) {
                                      if (value.length > 0) {
                                        setState(() {
                                          _authNumIsNotEmpty = true;
                                        });
                                      }
                                      else {
                                        setState(() {
                                          _authNumIsNotEmpty = false;
                                        });
                                      }
                                    },
                                    controller: _authNumController,
                                    focusNode: _authNumFocus,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      counterText: "",
                                      // contentPadding: EdgeInsets.symmetric(
                                      //     horizontal: 10.0, vertical: 10.0),
                                      hintText: "인증번호",
                                      hintStyle: TextStyle(letterSpacing: 0.7, color: greyB3B3BC, fontSize: _uiCriteria.textSize2, height: 1.2),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: _isTryAuth
                                              ? (_isAuthCorrect && !_isOver)
                                              ? BorderSide(color: greyB3B3BC, width: 0.5)
                                              : BorderSide(color: mainColor, width: 1.5)
                                              : BorderSide(color: greyB3B3BC, width: 0.5)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: _isTryAuth
                                              ? (_isAuthCorrect && !_isOver)
                                              ? BorderSide(color: greyB3B3BC, width: 0.5)
                                              : BorderSide(color: mainColor, width: 1.5)
                                              : BorderSide(color: greyB3B3BC, width: 0.5)
                                      ),
                                    ),
                                  ),
                        )
                    ),
                    AspectRatio(
                      aspectRatio: 12/50,
                    ),
                    Expanded(
                      flex: 100,
                      child: Container(
                          height: double.infinity,
                          child: MaterialButton(
                            elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.5)
                              ),
                              onPressed: (_authNumIsNotEmpty)
                                  ? (_isAuthCorrect)
                                  ? null
                                  : () => _authentication()
                                  : null,
                              disabledColor: _isAuthCorrect?greyF5F5F6 : greyD8D8D8,
                              color: mainColor,
                              child: AutoSizeText((_isAuthCorrect)?"인증완료":"확인", maxLines: 1, minFontSize: 10,style: TextStyle(letterSpacing: 0.7, color: (_isAuthCorrect)? greyB3B3BC : Colors.white, fontSize: _uiCriteria.textSize2))
                          )
                      ),
                    )
                  ],
                ),
              )
                  : Container(),
              Expanded(
                  child:
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                        AspectRatio(
                          aspectRatio: 343/50,
                          child: Container(
                            width: _uiCriteria.screenWidth,
                            child: MaterialButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.5)
                              ),
                              disabledColor: greyD8D8D8,
                              color: mainColor,
                              onPressed: _isAuthCorrect? () => _receiveEmail():null,
                              child: Text("확인", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        )
              ]))
            ]),
          ),
        ),
      ),
    );
  }

  bool _isRegistered;
  bool _isRequested;
  bool _isAuthCorrect;
  bool _isTryAuth;
  bool _pNumIsNotEmpty;
  bool _authNumIsNotEmpty;
  int _authNum;
  String _dtReceiveAuth;
  String _labelPNum;
  FocusNode _authNumFocus;
  FontWeight _pNumFW;
  
  @override
  void initState() {
    super.initState();
    _isRegistered = false;
    _isRequested = false;
    _isAuthCorrect = false;
    _isTryAuth = false;
    _pNumIsNotEmpty = false;
    _authNumIsNotEmpty = false;
    _dtReceiveAuth = "";
    _authNumFocus = new FocusNode();
    _labelPNum = "전화번호";
    _pNumFW = FontWeight.w700;
  }


  @override
  void dispose() {
    super.dispose();
    _authNumFocus.dispose();
    print("dispose dispose");
  }

  /// 이미 가입된 회원이면 인증번호, 아니면 -1 리턴
 Future<dynamic> _requestAuth() async {
    String phoneNumber = _pNumController.text;
    print('phoneNumber = $phoneNumber');
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/sms/upt/receive.do");
    String body = "pNum=$phoneNumber";
    Map<String, String> header = {
      "Content-Type" : "application/x-www-form-urlencoded"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = json.decode(response.body);
    print("result $result");
    print(result.runtimeType);
    return Future(() {
      return result;
    });
  }

  void _receiveAuthIfUser() async {
    Future future = _requestAuth();
    dynamic result;
    await future.then((value) => setState(() => result = value),
        onError: (e) => print(e));
    _authNum = result["code"];
    // 가입 되어있으면
    if (_authNum.toString() != "-100") {
      setState(() {
        _dtReceiveAuth = DateTime.now().add(Duration(hours: 9)).toString();
      });
      print(_dtReceiveAuth);
      setState(() {
        _labelPNum = "전화번호";
        _isRequested = true;
        _isRegistered = true;
        _pNumFW = FontWeight.w700;
        try {
          FocusScope.of(context).requestFocus(_authNumFocus);
        }
        catch (e) {
          print(e);
        }
      });
    }
    // 가입되어 있지 않으면
    else {
      print("bye");
      setState(() {
        _isRequested = true;
        _isRegistered = false;
        _labelPNum = "등록되지 않은 전화번호예요.";
        _pNumFW = FontWeight.bold;
      });
    }
  }

  void _authentication() async {
    setState(() {
      _isTryAuth = true;
    });
    String result;
    TodoRegister todoRegister = new TodoRegister(); // 전역 변수로
    Future future = todoRegister.isTimeout(_dtReceiveAuth);
    await future.then((value) => result = value, onError: (e) => print(e));
    print("result $result");
    setState(() {
      _isOver = (result == "true")?false:true;
    });
    print(1212);
    print(_isOver);
    print(_authNumController.text.isNotEmpty);
    print(_pNumController.text.isNotEmpty);
    if (!_isOver && _authNumController.text.isNotEmpty && _pNumController.text.isNotEmpty) {
      // 인증번호가 맞으면
      if (_authNumController.text == _authNum.toString()) {
        setState(() {
          _isAuthCorrect = true;
          _labelPNum = "전화번호";
          _pNumFW = FontWeight.w700;
        });
        AuthTimer _authTimer = Provider.of<AuthTimer>(context, listen: false);
        _authTimer.stopTimer();
      } else {
        print("hi");
        setState(() {
          _isAuthCorrect = false;
          _labelPNum = "인증번호를 다시 한번 확인해주세요.";
          _pNumFW = FontWeight.bold;
        });
        FocusScope.of(context).requestFocus(_authNumFocus);
      }
    }
    else {
      print("bye");
      setState(() {
        _isAuthCorrect = false;
        _labelPNum = "인증번호를 다시 한번 확인해주세요.";
        _pNumFW = FontWeight.bold;
      });
      FocusScope.of(context).requestFocus(_authNumFocus);
    }

  }
  void _receiveEmail() async {
    var url = Uri.parse("http://icnogari96.cafe24.com:8080/members/find/email");
    String body = "pNum=${_pNumController.text}";
    Map<String, String> header = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    var response = await http.post(url, headers: header, body: body);
    var result = response.body;
    print("result $result");
    try {
      var json = jsonDecode(result);
      print("json $json");
      FindState state = Provider.of<FindState>(context, listen: false);
      state.setInfo(json["email"]);
      var regDate = DateTime.fromMillisecondsSinceEpoch(json["regDate"]);
      state.setRegisterDate(regDate.toString().substring(0,10));
      Navigator.push(context, MaterialPageRoute(builder: (context) => FindEmailResultPage()));
    }
    catch (e) {
      errorToast("해당 정보로 가입된 이메일이 없습니다.");
    }
  }
}
