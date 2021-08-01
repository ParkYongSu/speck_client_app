import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Login/Todo/validate_password.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/Register/register_page2.dart';
import 'package:speck_app/State/register_state.dart';
import 'package:provider/provider.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';

class RegisterPage1 extends StatefulWidget {
  @override
  State createState() => RegisterPageState1();
}

class RegisterPageState1 extends State<RegisterPage1> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _passwordController2 =
      new TextEditingController();
  final UICriteria _uiCriteria = new UICriteria();
  ValidatePassword validatePassword = new ValidatePassword();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
      title: "회원가입 1",
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
                      style: TextStyle(
                        letterSpacing: 0.8,
                        fontSize: _uiCriteria.textSize1,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )
                  ),
                ]
            ),
            backgroundColor: mainColor,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white),
              padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
              child: Column(
                children: <Widget>[

                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("$_labelEmail", style:
                    TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: _emailFW)),
                  ),
                  AspectRatio(
                    aspectRatio: 343/11,
                  ),
                  AspectRatio(
                    aspectRatio: 343/50,
                    child: TextField(
                      style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.w500),
                      cursorColor: mainColor,
                      focusNode: _emailFocus,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          isDense: true,
                          hintText: "로그인시 필요",
                          hintStyle: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.5),
                          focusedBorder: OutlineInputBorder(
                              borderSide: (_emailController.text.isEmpty)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : (!_isDuplicate && _isEmailCorrect)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : BorderSide(color: mainColor, width: 1.5)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: (_emailController.text.isEmpty)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : (!_isDuplicate && _isEmailCorrect)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : BorderSide(color: mainColor, width: 1.5)
                          ),
                          suffixIcon: (_emailController.text.isEmpty)
                              ? null
                              : (!_isDuplicate&&_isEmailCorrect)
                              ? Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.textSize6,)
                              : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,)
                      ),
                      onChanged: (String value) {
                        _emailCorrectCheck(value);
                        if (value.length == 0) {
                          setState(() {
                            _labelEmail = "이메일";
                            _emailFW = FontWeight.w700;
                          });
                        }
                      },
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 343/35,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("$_labelPW",
                        style:
                        TextStyle(letterSpacing: 0.7, fontWeight: _passwordFW, fontSize: _uiCriteria.textSize2)),
                  ),
                  AspectRatio(
                    aspectRatio: 343/11,
                  ),
                  AspectRatio(
                    aspectRatio: 343/50,
                    child: TextField(
                      style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.w500),
                      cursorColor: mainColor,
                      focusNode: _pwFocus1,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          isDense: true,
                          suffixIcon: _passwordController.text.isEmpty
                              ? null
                              : ((_isPwCorrect)
                              ? Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.textSize6)
                              : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: (_passwordController.text.isEmpty)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : (_isPwCorrect)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : BorderSide(color: mainColor, width: 1.5)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: (_passwordController.text.isEmpty)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : (_isPwCorrect)
                                  ? BorderSide(color: greyB3B3BC, width: 0.5)
                                  : BorderSide(color: mainColor, width: 1.5)
                          ),
                          // contentPadding:
                          // EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                          hintText: "비밀번호(영문, 숫자 포함 8자 이상)",
                          hintStyle: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.5)),
                      onChanged: (String value) {
                        // 텍스트필드가 비어있지 않으면
                        if (value.length != 0) {
                          if (_passwordController2.text.isEmpty &&
                              validatePassword.checkPassword(value)
                                  .getIsCorrected()) {
                            setState(() {
                              _labelPW = "비밀번호";
                              _passwordFW = FontWeight.w700;
                              _isPwCorrect = true;
                            });
                          }
                          else if (_passwordController2.text.isEmpty &&
                              !validatePassword.checkPassword(value)
                                  .getIsCorrected()) {
                            setState(() {
                              _labelPW = "비밀번호 형식을 확인해주세요.";
                              _passwordFW = FontWeight.bold;
                              _isPwCorrect = false;
                            });
                          }
                          else if (validatePassword.checkPassword(value).getIsCorrected() && value == _passwordController2.text) {
                            setState(() {
                              _labelPW = "비밀번호";
                              _passwordFW = FontWeight.w700;
                              _isPwCorrect = true;
                            });
                          }
                          else if (validatePassword.checkPassword(value).getIsCorrected() && value != _passwordController2.text) {
                            setState(() {
                              _labelPW = "비밀번호가 일치하지 않아요.";
                              _passwordFW = FontWeight.bold;
                              _isPwCorrect = true;
                            });
                          }
                          else {
                            setState(() {
                              _labelPW = "비밀번호 형식을 확인해주세요.";
                              _passwordFW = FontWeight.bold;
                              _isPwCorrect = false;
                            });
                          }
                        }
                        // 텍스트필드가 비어있으면
                        else {
                          if (_passwordController2.text.isNotEmpty) {
                            setState(() {
                              _labelPW = "비밀번호가 일치하지 않아요.";
                              _passwordFW = FontWeight.bold;
                              _isPwCorrect = false;
                            });
                          }
                          else {
                            setState(() {
                              _labelPW = "비밀번호";
                              _passwordFW = FontWeight.w700;
                            });
                          }
                        }
                      },
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 343/11,
                  ),
                  AspectRatio(
                    aspectRatio: 343/50,
                    child: TextField(
                        style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.w500),
                        cursorColor: mainColor,
                        focusNode: _pwFocus2,
                        controller: _passwordController2,
                        obscureText: true,
                        decoration: InputDecoration(
                            isDense: true,
                            // contentPadding: const EdgeInsets.symmetric(
                            //     horizontal: 10.0, vertical: 10.0),
                            hintText: "비밀번호 확인",
                            hintStyle: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.5),
                            focusedBorder: OutlineInputBorder(
                                borderSide: (_passwordController2.text.isEmpty)
                                    ? BorderSide(color: greyB3B3BC, width: 0.5)
                                    : (_passwordController.text == _passwordController2.text)
                                    ? BorderSide(color: greyB3B3BC, width: 0.5)
                                    : BorderSide(color: mainColor, width: 1.5)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: (_passwordController2.text.isEmpty)
                                    ? BorderSide(color: greyB3B3BC, width: 0.5)
                                    : (_passwordController.text == _passwordController2.text)
                                    ? BorderSide(color: greyB3B3BC, width: 0.5)
                                    : BorderSide(color: mainColor, width: 1.5)
                            ),
                            suffixIcon: _passwordController2.text.isEmpty
                                ? null
                                : (_passwordController.text ==
                                _passwordController2.text
                                ? Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.screenWidth * 0.052)
                                : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,))),
                        onChanged: (String value) {
                          if (value.length == 0) {
                            setState(() {
                              _labelPW = "비밀번호";
                              _passwordFW = FontWeight.w700;
                            });
                          }
                          else {
                            if (_isPwCorrect && value == _passwordController.text) {
                              setState(() {
                                _labelPW = "비밀번호";
                                _passwordFW = FontWeight.w700;
                              });
                            }
                            else if (_isPwCorrect && value != _passwordController.text) {
                              setState(() {
                                _labelPW = "비밀번호가 일치하지 않아요";
                                _passwordFW = FontWeight.bold;
                              });
                            }
                            else {
                              setState(() {
                                _labelPW = "비밀번호 형식을 확인해주세요.";
                                _passwordFW = FontWeight.bold;
                              });
                            }
                          }
                        }
                    ),
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.5)
                                  ),
                                  elevation: 0,
                                  child: Text("다음", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2)),
                                  color: mainColor,
                                  disabledColor: greyD8D8D8,
                                  onPressed: (_isEmailCorrect && _isPwCorrect && _passwordController.text == _passwordController2.text)
                                      ? () => _pressNext1(context)
                                      : null
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

      ),
    );
  }

  bool _isDuplicate; // 중복확인 여부
  bool _isPwCorrect; // 비밀번호 형식 올바른지 여부
  bool _isEmailCorrect;
  String _labelEmail;
  String _labelPW;
  FocusNode _emailFocus;
  FocusNode _pwFocus1;
  FocusNode _pwFocus2;
  TodoRegister todoRegister = new TodoRegister();
  FontWeight _emailFW;
  FontWeight _passwordFW;

  @override
  void initState() {
    super.initState();
    _labelEmail = "이메일";
    _labelPW = "비밀번호";
    _isDuplicate = false;
    _isPwCorrect = false;
    _isEmailCorrect = false;
    _emailFW = FontWeight.w700;
    _passwordFW = FontWeight.w700;
    _emailFocus = new FocusNode();
    _pwFocus1 = new FocusNode();
    _pwFocus2 = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _emailFocus.dispose();
    _pwFocus1.dispose();
    _pwFocus2.dispose();
  }

  // 이메일 형식, 중복확인
  void _emailCorrectCheck(String email) async {
    /// 형식먼저 확인
    // 형식이 틀렸으면
    if ((!email.contains("@")) ||
        (!email.contains(".")) ||
        (email.contains(" ")) ||
        (((email.substring(email.length - 3, email.length - 2) != ".") &&
            (email.substring(email.length - 4, email.length - 3) != ".")))) {
      setState(() {
        // 형식 틀림
        _isEmailCorrect = false;
        _labelEmail = "이메일 형식을 다시 한번 확인해 주세요.";
        _emailFW = FontWeight.bold;
      });
    }
    // 형식이 맞았으면
    else {
      print("hi");
      print(email);
      TodoRegister todoRegister = new TodoRegister();
      Future future = todoRegister.isIdDuplicated(email);
      await future.then((value) => setState(() {
        print("value $value");
        _isDuplicate = value;
        _isEmailCorrect = true;
      }), onError: (e) => print(e));
      print("isduplicate $_isDuplicate");
      // 중복이면
      if (_isDuplicate) {
        setState(() {
          _labelEmail = "이미 가입되어 있는 이메일이에요.";
          _emailFW = FontWeight.bold;
        });
      }
      // 아니면
      else {
        _labelEmail = "이메일";
        _emailFW = FontWeight.w700;
      }
    }
  }

  void _pressNext1(BuildContext context) {
    // 다음으로 넘어가도 되는 상태면
    if (!_isDuplicate  &&_isEmailCorrect && _isPwCorrect && _passwordController.text == _passwordController2.text) {
      RegisterState registerState1 =
          Provider.of<RegisterState>(context, listen: false);
      registerState1.setEmail(_emailController.text);
      registerState1.setPassword(_passwordController.text);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage2()));
    }
    else if (!_isEmailCorrect) {
      FocusScope.of(context).requestFocus(_emailFocus);
    }
    else if (!_isPwCorrect) {
      FocusScope.of(context).requestFocus(_pwFocus1);
    }
    else if (!(_passwordController.text == _passwordController2.text)) {
      FocusScope.of(context).requestFocus(_pwFocus2);
    }
  }
}
