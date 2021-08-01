import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/Register/register_page3.dart';
import 'package:speck_app/Register/register_page4.dart';
import 'package:speck_app/State/register_state.dart';
import 'package:speck_app/Time/auth_timer.dart';
import 'package:provider/provider.dart';
import "package:customtogglebuttons/customtogglebuttons.dart";
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:url_launcher/url_launcher.dart';


class RegisterPage2 extends StatefulWidget {
  @override
  State createState() => RegisterPageState2();
}

class RegisterPageState2 extends State<RegisterPage2> {
  final TextEditingController _pNumController = new TextEditingController();
  final TextEditingController _authNumController = new TextEditingController();
  final TextEditingController _birthDayController = new TextEditingController();
  bool _isOver;
  final UICriteria _uiCriteria = new UICriteria();

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
        : false;

    List<Widget> widgets = [
      Container(
        margin: EdgeInsets.only(top: _uiCriteria.verticalPadding),
        alignment: Alignment.centerLeft,
        child: Text((_isOver)?"인증시간이 초과되었어요.":"$_labelPNum",
            style: TextStyle(
                letterSpacing: 0.7,
                fontSize: _uiCriteria.textSize2,
                fontWeight: _pNumFW,
                color: mainColor))),
      AspectRatio(aspectRatio: 343/11),
      AspectRatio(
        aspectRatio: 343/50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 294,
              child: Container(
                decoration: BoxDecoration(
                    color: _isAuthenticated?greyF5F5F6:Colors.transparent,
                    borderRadius: BorderRadius.circular(3.5)
                ),
                child: TextField(
                    enabled: (_isAuthenticated)?false:true,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    style: TextStyle(
                        letterSpacing: 0.7,
                        fontSize: _uiCriteria.textSize2, color: (_isAuthenticated)?greyB3B3BC:mainColor, fontWeight: FontWeight.w500),
                    // enabled: (_isAuthenticated)?false:true,
                    maxLength: 11,
                    onChanged: (String value) {
                      if (value.length == 0) {
                        setState(() {
                          _pNumIsNotEmpty = false;
                        });
                      }
                      else {
                        setState(() {
                          _pNumIsNotEmpty = true;
                        });
                      }
                    },
                    keyboardType: TextInputType.phone,
                    focusNode: _pNumFocus,
                    controller: _pNumController,
                    cursorColor: mainColor,
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: "",
                      suffixIcon: !_isTryGetAuth
                          ? null
                          : (_isRequested)
                          ? (_isAuthenticated)
                          ? null
                          : Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(_uiCriteria.textSize2),
                          child: Text(
                              "${_min.toString().padLeft(2, "0")} : ${_sec.toString().padLeft(2, "0")}",
                              style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.screenWidth * 0.033, color: mainColor, )))
                          : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,),

                      hintText: "- 없이 숫자만 입력",
                      hintStyle: TextStyle(letterSpacing: 0.7, color: greyB3B3BC, fontSize: _uiCriteria.textSize2, height: 1.5),
                      // disabledBorder: OutlineInputBorder(
                      //     borderSide: BorderSide(color: greyB3B3BC, width: 0.5)
                      // ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: _isTryGetAuth
                              ? (_isRequested)
                              ? (_isOver)
                              ? BorderSide(color: mainColor, width: 1.5)
                              : BorderSide(color: greyB3B3BC, width: 0.5)
                              : BorderSide(color: mainColor, width: 1.5)
                              : BorderSide(color: greyB3B3BC, width: 0.5)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: _isTryGetAuth
                              ? (_isRequested)
                              ? (_isOver)
                              ? BorderSide(color: mainColor, width: 1.5)
                              : BorderSide(color: greyB3B3BC, width: 0.5)
                              : BorderSide(color: mainColor, width: 1.5)
                              : BorderSide(color: greyB3B3BC, width: 0.5)),
                    )),
              ),
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
                      color: mainColor,
                      disabledColor: _isAuthenticated?greyF5F5F6:greyD8D8D8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                      child: _isRequested
                          ? AutoSizeText("재요청", maxLines: 1, style: TextStyle(letterSpacing: 0.7, color: _isAuthenticated?greyB3B3BC:Colors.white, fontSize: _uiCriteria.textSize2,fontWeight: FontWeight.w700,))
                          : AutoSizeText("인증요청", maxLines: 1, minFontSize: 10,style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2,color: Colors.white,fontWeight: FontWeight.w700,)),
                          // : Text("인증요청", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      // onPressed: (!_pNumIsNotEmpty)
                      //     ? null
                      //     : (_isAuthenticated)
                      //   ? null
                      //   : () {
                      //   setState(() {
                      //     _isTryAuthenticate = false;
                      //     _isAuthenticated = false;
                      //   });
                      //   _authTimer.startTimer();
                      //   _requestAuth();
                      // }
                        onPressed: (_pNumIsNotEmpty)
                        ? (_isAuthenticated)
                        ? null
                        : () {
                          setState(() {
                            _isTryAuthenticate = false;
                            _isAuthenticated = false;
                          });
                          _authTimer.startTimer();
                          _requestAuth();
                        }
                        : null,
                  ),
                )
            )
          ],
        ),
      ),
      (_isRequested)?
      _authNumField(context)
          :Container(),
      AspectRatio(aspectRatio: 343/35),
      Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Text("생년월일(선택)",
                      style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700))
              ),
              AspectRatio(aspectRatio: 343/12),
              AspectRatio(
                aspectRatio: 343/50,
                child: TextField(
                  style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.w500),
                  cursorColor: mainColor,
                  maxLength: 10,
                  onChanged: (String value) {
                    print(value.length);

                    print(_birthDayController.selection);
                    TextSelection textSelection = _birthDayController.selection;
                    if (value.length == 4 || value.length == 7) {
                      _birthDayController.text += ".";
                      _birthDayController.selection = textSelection.copyWith(
                          baseOffset: textSelection.start + 1,
                          extentOffset: textSelection.end + 1
                      );
                    }
                    else if (value.length == 5 || value.length == 8) {
                      _birthDayController.text =
                          _birthDayController.text.substring(0, _birthDayController.text.length - 1);
                      print(_birthDayController.text.length);
                      _birthDayController.selection = textSelection.copyWith(
                          baseOffset: _birthDayController.text.length,
                          extentOffset: _birthDayController.text.length
                      );
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: _birthDayController,
                  decoration: InputDecoration(
                      isDense: true,
                      counterText: "",
                      // contentPadding: EdgeInsets.symmetric(
                      //     horizontal: 10.0, vertical: 10.0),
                      hintText: "예) 2000.01.01",
                      hintStyle: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.5),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: greyB3B3BC, width: 0.5)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: greyB3B3BC, width: 0.5))),
                ),
              )
            ]
        ),
      ),
      AspectRatio(aspectRatio: 343/35),
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Text("성별(선택)",
                    style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700))),
            AspectRatio(aspectRatio: 343/12),
            Container(
                width: MediaQuery.of(context).size.width,
                child: CustomToggleButtons(
                  borderRadius: 3.5,
                  isSelected: _isSelected,
                  direction: Axis.horizontal,
                  constraints: BoxConstraints(
                      minWidth: _uiCriteria.screenWidth * 0.44, minHeight: _uiCriteria.screenWidth * 0.44 * (50/165)),
                  unselectedFillColor: greyD8D8D8,
                  fillColor: mainColor,
                  spacing: _uiCriteria.screenWidth * 0.022,
                  children: <Widget>[
                    Text("남자", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),),
                    Text("여자", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700)
                    )],
                  onPressed: (index) {
                    if (index == 0) {
                      if (!_isSelected[0]) {
                        _isSelected[0] = !_isSelected[0];
                        _isSelected[1] = !_isSelected[0];
                        setState(() {
                          _sex = "M";
                          print(_sex);
                        });
                      } else {
                        _isSelected[0] = !_isSelected[0];
                        _isSelected[1] = _isSelected[0];
                        setState(() {
                          _sex = null;
                        });
                        print(_sex);
                      }
                    }
                    else {
                      if (!_isSelected[1]) {
                        _isSelected[1] = !_isSelected[1];
                        _isSelected[0] = !_isSelected[1];
                        setState(() {
                          _sex = "F";
                        });
                        print(_sex);
                      } else {
                        _isSelected[1] = !_isSelected[1];
                        _isSelected[0] = _isSelected[1];
                        setState(() {
                          _sex = null;
                        });
                        print(_sex);
                      }
                    }
                  },
                )
            ),
          ],
        ),
      ),
      AspectRatio(aspectRatio: 343/35),
      Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text("약관동의",
                style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700)),
          ),
          AspectRatio(aspectRatio: 343/11),
          AspectRatio(
            aspectRatio: 343/166,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.045),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.5),
                    border: Border.all(color: greyB3B3BC)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 251,
                          child: GestureDetector(
                            onTap: _allAgreeCheck,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: greyD8D8D8,))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.check_circle_rounded, color: (_allAgree)?mainColor:greyD8D8D8, size: _uiCriteria.textSize1,),
                                    SizedBox(width: _uiCriteria.screenWidth * 0.027),
                                    Text("약관에 모두 동의",
                                        style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                  ],
                                )
                            ),
                          )),
                      Expanded(
                          flex: 671,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: _uiCriteria.screenWidth * 0.045),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                      GestureDetector(
                                        onTap: _serviceCheck,
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.check_circle, color: (_allAgree)?mainColor:(_serviceAgree)?mainColor:greyD8D8D8, size: _uiCriteria.textSize1,),
                                            SizedBox(width: _uiCriteria.screenWidth * 0.027),
                                            Text("이용약관 동의",
                                                style: TextStyle(letterSpacing: 0.6, color: mainColor,fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3
                                                )),
                                            Text(" (필수)", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3,fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                       Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            InkWell(
                                                child: Text("보기",
                                                    style: TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: _uiCriteria.textSize5,
                                                        color: greyB3B3BC)),
                                                onTap: () => _connectNotion("https://www.notion.so/d173ec91ada74971b53d071f41208457")),
                                          ],
                                        ))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: _personalCheck,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.check_circle, color: (_allAgree)?mainColor:(_personalInformationCollectionAgree)?mainColor:greyD8D8D8, size: _uiCriteria.textSize1,),
                                          SizedBox(width: _uiCriteria.screenWidth * 0.027),
                                          Text("개인정보 수집 및 이용동의",
                                              style: TextStyle(
                                                letterSpacing: 0.6,
                                                fontWeight: FontWeight.w500,
                                                color: mainColor,
                                                fontSize: _uiCriteria.textSize3,
                                              )),
                                          Text(" (필수)", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            InkWell(
                                                child: Text("보기",
                                                    style: TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: _uiCriteria.textSize5,
                                                        color: greyB3B3BC)),
                                                onTap: () => _connectNotion("https://www.notion.so/e995ecdc270442668013e096c22d6a23")),
                                          ],
                                        ))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: _receiveEventCheck,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.check_circle, color: (_allAgree)?mainColor:(_receiveEventInformationAgree)?mainColor:greyD8D8D8, size: _uiCriteria.textSize1,),
                                          SizedBox(width: _uiCriteria.screenWidth * 0.027),
                                          Text("이벤트 정보 수신 동의",
                                              style: TextStyle(
                                                letterSpacing: 0.6,
                                                color: mainColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: _uiCriteria.textSize3,
                                              )),
                                          Text(" (선택)", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            InkWell(
                                                child: Text("보기",
                                                    style: TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: _uiCriteria.textSize5,
                                                        color: greyB3B3BC)),
                                                onTap: () => _connectNotion("https://www.notion.so/e995ecdc270442668013e096c22d6a23")),
                                          ],
                                        ))
                                  ],
                                ),

                              ]
                            ),
                          )),
                    ])),
          ),
          AspectRatio(aspectRatio: 343/40)
        ]
      )
    ];

    return MaterialApp(
      title: "회원가입 2",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
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
                      GestureDetector(
                          child: Icon(Icons.chevron_left_rounded,
                              color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                          onTap: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Text("회원가입",
                    style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize1, color: Colors.white, fontWeight: FontWeight.w700,)),
              ]
          ),
          backgroundColor: mainColor,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            width: _uiCriteria.screenWidth,
            height: _uiCriteria.totalHeight,
            padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, 0, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
            decoration: BoxDecoration(
                color: Colors.white),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.06),
                  child: SingleChildScrollView(
                    child: Column(
                        children: widgets
                    ),

                  ),
                ),
                AspectRatio(
                    aspectRatio: 343/50,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.5)
                          ),
                          elevation: 0,
                          child:
                          Text("다음", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700)),
                          color: mainColor,
                          disabledColor: greyD8D8D8,
                          onPressed: (_isAuthenticated && _serviceAgree && _personalInformationCollectionAgree)
                              ? () => _pressNext2()
                              : null,
                        )
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _allAgreeCheck() {
    if (!_allAgree) {
      setState(() {
        _allAgree = true;
        _serviceAgree = true;
        _personalInformationCollectionAgree = true;
        _receiveEventInformationAgree = true;
        _service = "Y";
        _personal = "Y";
        _event = "Y";
      });
    }
    else {
      setState(() {
        _allAgree = false;
        _serviceAgree = false;
        _personalInformationCollectionAgree = false;
        _receiveEventInformationAgree = false;
        _service = "N";
        _personal = "N";
        _event = "N";
      });
    }
  }

  void _serviceCheck() {
    if (!_serviceAgree) {
      setState(() {
        _serviceAgree = true;
        _service = "Y";
      });
    }
    else {
      setState(() {
        _serviceAgree = false;
        _allAgree = false;
        _service = "N";
      });
    }
  }

  void _personalCheck() {
    if (!_personalInformationCollectionAgree) {
      setState(() {
        _personalInformationCollectionAgree = true;
        _personal = "Y";
      });
    }
    else {
      setState(() {
        _personalInformationCollectionAgree = false;
        _allAgree = false;
        _personal = "N";
      });
    }
  }

  void _receiveEventCheck() {
    if (!_receiveEventInformationAgree) {
      setState(() {
        _receiveEventInformationAgree = true;
        _event = "Y";
      });
    }
    else {
      setState(() {
        _receiveEventInformationAgree = false;
        _allAgree = false;
        _event = "N";
      });
    }
  }

  List<bool> _isSelected;
  bool _isAuthenticated;
  bool _isAgreed;
  bool _isRequested;
  bool _pNumIsNotEmpty;
  bool _authNumIsNotEmpty;
  bool _isTryGetAuth;
  bool _isTryAuthenticate;
  int _authNum;
  int _authStatus;
  String _sex;
  List<bool> _isChecked;
  FocusNode _authNumFocus;
  FocusNode _pNumFocus;
  String _dtReceiveAuth;
  String _isTimeOut;
  String _labelPNum;
  FontWeight _pNumFW;
  bool _allAgree;
  bool _serviceAgree;
  bool _personalInformationCollectionAgree;
  bool _receiveEventInformationAgree;
  String _service;
  String _personal;
  String _event;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = false;
    _isAgreed = false;
    _isRequested = false;
    _pNumIsNotEmpty = false;
    _authNumIsNotEmpty = false;
    _isTryGetAuth = false;
    _isTryAuthenticate = false;
    _sex = null;
    _isSelected = [false, false];
    _isChecked = [false, false, false, false, false];
    _authNumFocus = new FocusNode();
    _pNumFocus = new FocusNode();
    _isTimeOut = "";
    _labelPNum = "전화번호";
    _pNumFW = FontWeight.w700;
    _allAgree = false;
    _serviceAgree = false;
    _personalInformationCollectionAgree = false;
    _receiveEventInformationAgree = false;
    _service = "N";
    _personal = "N";
    _event = "N";
  }

  @override
  void dispose() {
    super.dispose();
    _authNumFocus.dispose();
    _pNumFocus.dispose();
  }

  void _authentication() async {
    AuthTimer authTimer = Provider.of<AuthTimer>(context, listen: false);
    TodoRegister todoRegister = new TodoRegister();
    print("현재 시간: ${DateTime.now()}");
    print(_dtReceiveAuth);
    Future<String> future = todoRegister.isTimeout(_dtReceiveAuth);
    await future.then((value) => _isTimeOut = value, onError: (e) => print(e));
    print("시간초과? $_isTimeOut");
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

  Widget _authNumField(BuildContext context) {
    return Column(
      children: <Widget>[
        AspectRatio(aspectRatio: 343/11),
        AspectRatio(
          aspectRatio: 343/50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 294,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isAuthenticated?greyF5F5F6:Colors.transparent,
                    borderRadius: BorderRadius.circular(3.5)
                  ),
                  child: TextField(
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: _isAuthenticated? greyB3B3BC : mainColor, fontWeight: FontWeight.w500),
                      enabled: (_isAuthenticated)?false:true,
                      onChanged: (String value) {
                        if (value.length == 0) {
                          setState(() {
                            _authNumIsNotEmpty = false;
                          });
                        }
                        else {
                          _authNumIsNotEmpty = true;
                        }
                      },
                      cursorColor: mainColor,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      focusNode: _authNumFocus,
                      controller: _authNumController,
                      decoration: InputDecoration(
                        // fillColor: _isAuthenticated?Colors.transparent:greyF5F5F6,
                        counterText: "",
                        isDense: true,
                        // contentPadding: EdgeInsets.symmetric(
                        //     horizontal: 10.0, vertical: 10.0),
                        hintText: "인증번호",
                        hintStyle: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.2),
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: _isTryAuthenticate
                                ? _isAuthenticated
                                ? BorderSide(color: greyB3B3BC, width: 0.5)
                                : BorderSide(color: mainColor, width: 1.5)
                                : BorderSide(color: greyB3B3BC, width: 0.5)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            _isTryAuthenticate
                                ? _isAuthenticated
                                ? BorderSide(color: greyB3B3BC, width: 0.5)
                                : BorderSide(color: mainColor, width: 1.5)
                                : BorderSide(color: greyB3B3BC, width: 0.5)
                        ),
                      )),
                ),
              ),
              AspectRatio(aspectRatio: 12/50),
              Expanded(
                flex: 100,
                child: Container(
                    height: double.infinity,
                    child: MaterialButton(
                      disabledColor: _isAuthenticated?greyF5F5F6:greyD8D8D8,
                      elevation: 0,
                      color: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                      child: AutoSizeText(_isAuthenticated? "인증완료":"인증확인", maxLines: 1, minFontSize: 10,style: TextStyle(color: _isAuthenticated?greyB3B3BC:Colors.white, fontSize: _uiCriteria.textSize2,fontWeight: FontWeight.w700,)),
                  // Text(_isAuthenticated? "인증완료":"인증확인", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2)),
                      onPressed: (_isAuthenticated)
                          ? null
                          : (_authNumIsNotEmpty && !_isOver)
                          ?() => _authentication()
                          : null,
                    )),
              )
            ],
          ),
        )
      ]
    );
  }

  void _requestAuth() async {
    TodoRegister todoRegister = new TodoRegister();
    String phoneNumber = _pNumController.text;
    Future<dynamic> future = todoRegister.getAuthNumber(phoneNumber);
    await future.then((value) {
      _authStatus = value["status"];
      _authNum = value["code"];
    }, onError: (e) => print(e));

    // 인증번호 요청 시도
    setState(() {
      _isTryGetAuth = true;
    });

    if (_authStatus.toString() == "500") {
      setState(() {
        _labelPNum = "이미 등록된 전화번호예요.";
        _pNumFW = FontWeight.bold;
        _isRequested = false;
      });
    } else if (_authStatus.toString() == "202"){
      _dtReceiveAuth = DateTime.now().toString();
      setState(() {
        _labelPNum = "전화번호";
        _isRequested = true;
      });
      FocusScope.of(context).requestFocus(_authNumFocus);
    }
  }

  void _pressNext2() {
    // 휴대폰 인증, 필수 사항 동의했으면 다음페이지로
    print(_birthDayController.text.length);
    RegisterState registerState =
    Provider.of<RegisterState>(context, listen: false);
    String pNum = _pNumController.text;
    String birthday1 = (_birthDayController.text.isEmpty)
        ? "N"
        : (_birthDayController.text.length == 10)
        ? _birthDayController.text
        .substring(2, 4)  + _birthDayController.text.substring(5, 7)  +_birthDayController.text.substring(8, 10)
        : "N";
    String birthday2 = (_birthDayController.text.isEmpty)
        ? "N"
        : (_birthDayController.text.length == 10)
        ? _birthDayController.text
        .substring(0, 4) + "-" + _birthDayController.text.substring(5, 7) + "-" +_birthDayController.text.substring(8, 10)
        : "N";
    String sex = _sex ?? "N";
    registerState.setPhoneNumber(pNum);
    registerState.setBirthday1(birthday1);
    registerState.setBirthday2(birthday2);
    registerState.setGender(sex);
    registerState.setService(_service);
    registerState.setPersonalInformationCollection(_personal);
    registerState.setReceiveEventInformation(_event);
    print("service $_service");
    print("personal $_personal");
    print("event $_event");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage3()));

    // 휴대폰 인증 안했으면
    // if (!_isRequested) {
    //   FocusScope.of(context).requestFocus(_pNumFocus);
    // } else {
    //   FocusScope.of(context).requestFocus(_authNumFocus);
    // }
  }
  void _connectNotion(String url) async{
    await launch(url);
  }
}
