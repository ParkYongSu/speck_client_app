import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/Time/auth_timer.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import "package:http/http.dart" as http;
import 'package:speck_app/widget/public_widget.dart';
import 'package:speck_app/util/util.dart';

class SetPhoneNumber extends StatefulWidget {
  @override
  _SetPhoneNumberState createState() => _SetPhoneNumberState();
}

class _SetPhoneNumberState extends State<SetPhoneNumber> {
  UICriteria _uiCriteria = new UICriteria();
  final TextEditingController _pNumController = new TextEditingController();
  final TextEditingController _authNumController = new TextEditingController();
  bool _pNumNotEmpty;
  bool _authNumNotEmpty;
  bool _isAuthenticated;
  bool _isRequested;
  bool _isOver;
  bool _isTryGetAuth;
  bool _isTryAuthenticate;
  String _isTimeOut;
  FocusNode _authNumFocus;
  FocusNode _pNumFocus;
  AuthTimer _authTimer;
  int _total;
  int _min;
  int _sec;
  String _labelPNum;
  FontWeight _pNumFW;
  String _dtReceiveAuth;
  int _authNum;
  int _authStatus;
  SettingState _ss;

  @override
  void dispose() {
    super.dispose();
    _authNumFocus.dispose();
    _pNumFocus.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isRequested = false;
    _isAuthenticated = false;
    _pNumNotEmpty = false;
    _authNumNotEmpty = false;
    _authNumFocus = new FocusNode();
    _pNumFocus = new FocusNode();
    _isTryGetAuth = false;
    _isTryAuthenticate = false;
    _labelPNum = "전화번호";
    _pNumFW = FontWeight.w700;
    _isTimeOut = "";

  }

  @override
  Widget build(BuildContext context) {
    _authTimer = Provider.of<AuthTimer>(context, listen: true);
    _total = _authTimer.getSeconds();
    _min = _total ~/ 60;
    _sec = _total - (_min * 60);
    _isOver = _isRequested
        ? _authTimer.getIsRunning()
        ? false
        : true
        : false;
    _uiCriteria.init(context);
    _ss = Provider.of<SettingState>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

      appBar: _appBar(context),
      body: _setPhoneNumber(),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
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
              child: Text("연락처 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize16),)),
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
    );
  }

  Widget _setPhoneNumber() {
    return GestureDetector(
      onTap: () =>  FocusScope.of(context).requestFocus(new FocusNode()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, top: _uiCriteria.verticalPadding, bottom: _uiCriteria.totalHeight * 0.039),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _title(),
            _pNumField(),
            (_isRequested)
            ? _authNumField()
            : Container(),
            _completeButton(context)
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
        margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.0147),
        child: Text((_isOver)?"인증시간이 초과되었어요.":"$_labelPNum", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),));
  }

  Widget _pNumField() {
    return AspectRatio(
      aspectRatio: 343/50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 247/50,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
                return Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _isAuthenticated?greyF5F5F6:Colors.transparent,
                          borderRadius: BorderRadius.circular(3.5),
                          border:
                          (_isAuthenticated)
                              ? null
                              :_isTryGetAuth
                              ? (_isRequested)
                              ? (_isOver)
                              ? Border.all(color: mainColor, width: 1.5)
                              : Border.all(color: greyB3B3BC, width: 0.5)
                              : Border.all(color: mainColor, width: 1.5)
                              : Border.all(color: greyB3B3BC, width: 0.5)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0485),
                      child: TextField(
                        enabled: (_isAuthenticated)?false:true,
                        style: TextStyle(
                            letterSpacing: 0.7,
                            fontSize: _uiCriteria.textSize2, color: (_isAuthenticated)?greyB3B3BC:mainColor, fontWeight: FontWeight.w500),
                        controller: _pNumController,
                        focusNode: _pNumFocus,
                        maxLength: 11,
                        keyboardType: TextInputType.number,
                        cursorColor: mainColor,
                        decoration: InputDecoration(
                            counterText: "",
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "-없이 숫자만 입력",
                            hintStyle: TextStyle(color: greyB3B3BC, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7)
                        ),
                        onChanged: (String value) {
                          _pNumChanged(value);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: constraint.maxWidth * 0.0485),
                      child: !_isTryGetAuth
                          ? Container()
                          : (_isRequested)
                          ? (_isAuthenticated)
                          ? Container()
                          : Container(
                          // width: MediaQuery.of(context).size.width * 0.25,
                          alignment: Alignment.centerRight,
                          child: Text(
                              "${_min.toString().padLeft(2, "0")} : ${_sec.toString().padLeft(2, "0")}",
                              style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.screenWidth * 0.033, color: mainColor, )))
                          : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,),
                    ),
                  ],
                );
              }
            ),
          ),
          AspectRatio(
            aspectRatio: 84/50,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.5)
              ),
              elevation: 0,
              disabledColor: _isAuthenticated?greyF5F5F6:greyD8D8D8,
              onPressed: (_pNumNotEmpty)
                  ? (_isAuthenticated)
                  ? null
                  : () {
                setState(() {
                  _isTryAuthenticate = false;
                  _isAuthenticated = false;
                });
                _authTimer.startTimer();
                _request();
              }
                  : null,
              child: _isRequested
                  ? AutoSizeText("재요청", maxLines: 1, style: TextStyle(letterSpacing: 0.7, color: _isAuthenticated?greyB3B3BC:Colors.white, fontSize: _uiCriteria.textSize2,fontWeight: FontWeight.w700,))
                  : AutoSizeText("인증요청", maxLines: 1, minFontSize: 10,style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2,color: Colors.white,fontWeight: FontWeight.w700,)),
              color:mainColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _authNumField() {
    return Column(
      children: [
        SizedBox(height: _uiCriteria.totalHeight * 0.0147),
        AspectRatio(
          aspectRatio: 343/50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AspectRatio(
                aspectRatio: 247/50,
                child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraint) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.5),
                            color: (_isOver)?greyF5F5F6:_isAuthenticated?greyF5F5F6:Colors.transparent,
                            border:
                            (_isOver)
                            ? null
                            : _isTryAuthenticate
                                ? _isAuthenticated
                                ? null
                                : Border.all(color: mainColor, width: 1.5)
                                : Border.all(color: greyB3B3BC, width: 0.5)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0485),
                        child:  TextField(
                          style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: _isAuthenticated? greyB3B3BC : mainColor, fontWeight: FontWeight.w500),
                          controller: _authNumController,
                          keyboardType: TextInputType.number,
                          focusNode: _authNumFocus,
                          maxLength: 4,
                          enabled: (_isOver)?false:(_isAuthenticated)?false:true,
                          cursorColor: mainColor,
                          decoration: InputDecoration(
                              counterText: "",
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "인증번호",
                              hintStyle: TextStyle(color: greyB3B3BC, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7)
                          ),
                          onChanged: (String value) {
                            _authNumChanged(value);
                          },
                        ),
                      );
                    }
                ),
              ),
              AspectRatio(
                aspectRatio: 84/50,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.5)
                  ),
                  elevation: 0,
                  onPressed: (_isAuthenticated)
                      ? null
                      : (_authNumNotEmpty && !_isOver)
                      ?() => _authentication()
                      : null,
                  child: AutoSizeText(_isAuthenticated? "인증완료":"인증확인", maxLines: 1
                      , style: TextStyle(color: _isAuthenticated?greyB3B3BC:Colors.white, fontSize: _uiCriteria.textSize2,fontWeight: FontWeight.w700,)),
                  disabledColor: _isAuthenticated?greyF5F5F6:greyD8D8D8,
                  color:mainColor,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _pNumChanged(String value) {
    if (value.length == 0) {
      setState(() {
        _pNumNotEmpty = false;
      });
    }
    else {
      setState(() {
        _pNumNotEmpty = true;

      });
    }
  }

  void _authNumChanged(String value) {
    if (value.length == 0) {
      setState(() {
        _authNumNotEmpty = false;
      });
    }
    else {
      _authNumNotEmpty = true;
    }
  }

  Widget _completeButton(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 343/50,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.5)
              ),
              disabledColor: greyD8D8D8,
              elevation: 0,
              onPressed: (_isAuthenticated)? () => _complete() : null,
              color: mainColor,
              child: Text("완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
            ),
          )
        ],
      ),
    );
  }

  void _authentication() async {
    AuthTimer authTimer = Provider.of<AuthTimer>(context, listen: false);
    setState(() {
      _isTryAuthenticate = true;
    });
    if (_authNumController.text == _authNum.toString()) {
      setState(() {
        _isAuthenticated = true;
        _labelPNum = "전화번호";
        _pNumFW = FontWeight.w700;
      });
      authTimer.stopTimer();
      FocusScope.of(context).unfocus();
    } else {
      setState(() {
        _isAuthenticated = false;
        _labelPNum = "인증번호를 다시 한번 확인해주세요.";
        _pNumFW = FontWeight.bold;
      });
    }
  }

  void _request() async {
    TodoRegister todoRegister = new TodoRegister();
    String phoneNumber = _pNumController.text;
    int statusCode;
    dynamic result;
    Future getAuthNum = todoRegister.getAuthNumber(phoneNumber);
    await getAuthNum.then((value) {
      result = value;
    });

    print(result);
    statusCode = result["status"]["statusCode"];

    if (statusCode == 202) {
      _labelPNum = "전화번호";
      _isRequested = true;
      _isTryGetAuth = true;
      _authNum = result["code"];
      FocusScope.of(context).requestFocus(_authNumFocus);
      setState((){});
    }
    else if (statusCode == 300) {
      _labelPNum = "이미 등록된 전화번호예요.";
      _pNumFW = FontWeight.bold;
      _isTryGetAuth = true;
      _isRequested = false;
      setState(() {});
    }
    else if (statusCode == 305) {
      _labelPNum = "전화번호를 확인해주세요.";
      _pNumFW = FontWeight.bold;
      _isTryGetAuth = true;
      _isRequested = false;
      setState(() {});
    }
    else {
      _labelPNum = "다시 한번 시도해주세요.";
      _pNumFW = FontWeight.bold;
      _isTryGetAuth = true;
      _isRequested = false;
      setState(() {});
    }
  }

  void _complete() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/update/phonenumber");
    String body = '''{
      "email" : "${sp.getString("email")}",
      "phoneNumber" : "${_pNumController.text}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url,body: body, headers: header);
    var code = int.parse(utf8.decode(response.bodyBytes));
    print(response.body);
    if (code == 100) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString("phoneNumber", _pNumController.text);
      _ss.setPhoneNumber(_pNumController.text);
      errorToast("변경되었습니다.");
      Navigator.pop(context);
    }
    else {
      errorToast("다시 한번 시도해주세요.");
    }

  }


}
