import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Todo/validate_password.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:http/http.dart' as http;

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  String _currentPasswordTitle = "현재 비밀번호";
  String _newPasswordTitle = "새 비밀번호";
  final TextEditingController _currentPasswordController = new TextEditingController();
  final TextEditingController _newPasswordController = new TextEditingController();
  final TextEditingController _newPasswordCheckController = new TextEditingController();
  final ValidatePassword validatePassword = new ValidatePassword();
  bool _isPasswordCorrect;
  bool _isPasswordCorrespond;

  @override
  void initState() {
    super.initState();
    _isPasswordCorrect = false;
    _isPasswordCorrespond = false;
  }

  @override
  Widget build(BuildContext context) {
    return _updatePasswordPage();
  }

  Widget _updatePasswordPage() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, "비밀번호 변경"),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
          decoration: BoxDecoration(
            color: Colors.white
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: uiCriteria.verticalPadding, bottom: uiCriteria.totalHeight * 0.0148),
                child: _title(_currentPasswordTitle)),
              _currentPasswordField(),
              Padding(
                padding: EdgeInsets.only(top: uiCriteria.totalHeight * 0.0443, bottom: uiCriteria.totalHeight * 0.0148),
                child: _title(_newPasswordTitle),
              ),
              _newPasswordField(),
              Padding(
                padding: EdgeInsets.only(top: uiCriteria.totalHeight * 0.0148),
                child: _newPasswordCheckField(),
              ),
              _completeButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(String title) {
    return Text(title, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),);
  }

  Widget _currentPasswordField() {
    return AspectRatio(
        aspectRatio: 343/50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.035),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: greyB3B3BC, width: 0.5),
                  borderRadius: BorderRadius.circular(3.5)
              ),
              child: TextField(
                controller: _currentPasswordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                cursorColor: mainColor,
                style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2),
                decoration: InputDecoration(
                    hintText: "현재 비밀번호 입력",
                    hintStyle: TextStyle(color: greyB3B3BC, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7),
                    border: InputBorder.none
                ),
                onChanged: (String value) {
                },
              ),
            );
          },
        )
    );
  }

  Widget _newPasswordField() {
    return AspectRatio(
        aspectRatio: 343/50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.035),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: (_newPasswordController.text.isEmpty)
                      ?Border.all(color: greyB3B3BC, width: 0.5)
                      :(_isPasswordCorrect)
                      ?Border.all(color: greyB3B3BC, width: 0.5)
                      :Border.all(color: mainColor, width: 1.5),
                  borderRadius: BorderRadius.circular(3.5)
              ),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _newPasswordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    cursorColor: mainColor,
                    style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2),
                    decoration: InputDecoration(
                        hintText: "새 비밀번호(영문, 숫자 포함 8자 이상)",
                        hintStyle: TextStyle(color: greyB3B3BC, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7),
                        border: InputBorder.none
                    ),
                    onChanged: _checkPasswordForm,
                  ),
                  (_newPasswordController.text.isEmpty)
                  ?Container()
                  :(_isPasswordCorrect)
                  ? Icon(Icons.check_circle, color: mainColor, size: uiCriteria.textSize6,)
                  : Icon(Icons.error, color: mainColor, size: uiCriteria.textSize6,)
                ],
              ),
            );
          },
        )
    );
  }

  Widget _newPasswordCheckField() {
    return AspectRatio(
        aspectRatio: 343/50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.035),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: (_newPasswordCheckController.text.isEmpty)
                  ?Border.all(color: greyB3B3BC, width: 0.5)
                  :(_newPasswordController.text == _newPasswordCheckController.text)
                  ?Border.all(color: greyB3B3BC, width: 0.5)
                  :Border.all(color: mainColor, width: 1.5),
                  borderRadius: BorderRadius.circular(3.5)
              ),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _newPasswordCheckController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    cursorColor: mainColor,
                    style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2),
                    decoration: InputDecoration(
                        hintText: "비밀번호 확인",
                        hintStyle: TextStyle(color: greyB3B3BC, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7),
                        border: InputBorder.none
                    ),
                    onChanged: _checkPassword,
                  ),
                _newPasswordCheckController.text.isEmpty
                    ? Container()
                    : (_newPasswordController.text ==
                    _newPasswordCheckController.text
                    ? Icon(Icons.check_circle, color: mainColor, size: uiCriteria.screenWidth * 0.052)
                    : Icon(Icons.error, color: mainColor, size: uiCriteria.textSize6,))
                ],
              ),
            );
          },
        )
    );
  }

  Widget _completeButton() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: uiCriteria.totalHeight * 0.039),
            child: AspectRatio(
              aspectRatio: 343/50,
              child: MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
                color: mainColor,
                disabledColor: greyD8D8D8,
                elevation: 0,
                child: Text("완료", style: TextStyle(fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.7),),
                onPressed: (_isPasswordCorrect && (_newPasswordController.text == _newPasswordCheckController.text))
                ? _pressComplete
                : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkPasswordForm(String value) {
    if (value.length != 0) {
      if (_newPasswordCheckController.text.isEmpty &&
          validatePassword.checkPassword(value)
              .getIsCorrected()) {
        _newPasswordTitle = "비밀번호";
        _isPasswordCorrect = true;
      }
      else if (_newPasswordCheckController.text.isEmpty &&
          !validatePassword.checkPassword(value)
              .getIsCorrected()) {
        _newPasswordTitle = "비밀번호 형식을 확인해주세요.";
        _isPasswordCorrect = false;
      }
      else if (validatePassword.checkPassword(value).getIsCorrected() && value == _newPasswordCheckController.text) {
        _newPasswordTitle = "비밀번호";
        _isPasswordCorrect = true;
      }
      else if (validatePassword.checkPassword(value).getIsCorrected() && value != _newPasswordCheckController.text) {
        _newPasswordTitle = "비밀번호가 일치하지 않아요.";
        _isPasswordCorrect = true;
      }
      else {
        _newPasswordTitle = "비밀번호 형식을 확인해주세요.";
        _isPasswordCorrect = false;
      }
    }
    // 텍스트필드가 비어있으면
    else {
      if (_newPasswordCheckController.text.isNotEmpty) {
        _newPasswordTitle = "비밀번호가 일치하지 않아요.";
        _isPasswordCorrect = false;
      }
      else {
        _newPasswordTitle = "비밀번호";
      }
    }
    setState(() {});
  }

  void _checkPassword(String value) {
    if (value.length == 0) {
      _newPasswordTitle = "비밀번호";
    }
    else {
      if (_isPasswordCorrect && value == _newPasswordController.text) {
        _newPasswordTitle = "비밀번호";
      }
      else if (_isPasswordCorrect && value != _newPasswordController.text) {
        _newPasswordTitle = "비밀번호가 일치하지 않아요";
      }
      else {
        _newPasswordTitle = "비밀번호 형식을 확인해주세요.";
      }
    }
    setState(() {});
  }

  /// 새 비밀번호가 모두 옳을 때에만 동작 -> 이 메서드가 동작한다는 것은 비밀번호가 옳다는 것
  void _pressComplete() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    print(sp.getString("token"));
    var url = Uri.parse("$speckUrl/user/set/password");
    String body = """{
      "currentPw" : "${_currentPasswordController.text}",
      "newPw" : "${_newPasswordController.text}"
    }""";
    Map<String,String> header = {
      "Content-Type" : "application/json",
      "Authorization" : "${sp.getString("token")}"
    };

    // 현재 비밀번호와 같다면
    if (_currentPasswordController.text == _newPasswordController.text) {
      errorToast("현재 비밀번호와 동일합니다.");
    }
    else {
      var response = await http.post(url, headers: header, body: body);
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      print(result);
      int statusCode = result["statusCode"];
      if (statusCode == 240) {
        Navigator.pop(context);
        errorToast("비밀번호가 변경되었습니다.");
      }
      else if (statusCode == 443) {
        errorToast("비밀번호가 일치하지 않습니다.");
      }
      else {
        errorToast("다시 한번 시도해주세요.");
      }
    }
  }
}
