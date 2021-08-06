import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/main/my/setting/setting_all_info.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';
import 'package:speck_app/util/util.dart';

import 'my_settings.dart';

class SetBirthday extends StatefulWidget {
  @override
  SetBirthdayState createState() => SetBirthdayState();
}

class SetBirthdayState extends State<SetBirthday> {
  UICriteria _uiCriteria = new UICriteria();
  final TextEditingController _birthdayController = new TextEditingController();
  SettingState _ss;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _ss = Provider.of<SettingState>(context, listen: false);

    return MaterialApp(
      title: "생년월일 설정 페이지",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appBar(context),
        backgroundColor: Colors.white,
        body: _setBirthday(),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
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
              child: Text("생년월일 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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

  Widget _title() {
    return Container(
      padding: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.0147),
      child: Text("생년월일", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
    );
  }

  Widget _birthdayField() {
    return Container(
      child: AspectRatio(
        aspectRatio: 343/50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: greyB3B3BC, width: 0.5),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                ),
                TextField(
                  style: TextStyle(color: mainColor, letterSpacing: 0.7, fontWeight: FontWeight.w500),
                  cursorColor: mainColor,
                  controller: _birthdayController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                      counterText: "",
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "생년월일 입력",
                      hintStyle: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7, color: greyB3B3BC),
                      contentPadding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0349)
                  ),
                  onChanged: (String value) {
                    _onChanged(value);
                    // _checkCorrect(value);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onChanged(String value) {
    TextSelection textSelection = _birthdayController.selection;
    if (value.length == 4 || value.length == 7) {
      _birthdayController.text += ".";
      _birthdayController.selection = textSelection.copyWith(
          baseOffset: textSelection.start + 1,
          extentOffset: textSelection.end + 1
      );
    }
    else if (value.length == 5 || value.length == 8) {
      _birthdayController.text =
          _birthdayController.text.substring(0, _birthdayController.text.length - 1);
      print(_birthdayController.text.length);
      _birthdayController.selection = textSelection.copyWith(
          baseOffset: _birthdayController.text.length,
          extentOffset: _birthdayController.text.length
      );
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
              onPressed: _request,
              color: mainColor,
              child: Text("다음", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
            ),
          )
        ],
      ),
    );
  }

  Widget _setBirthday() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, top: _uiCriteria.verticalPadding, bottom: _uiCriteria.totalHeight * 0.039),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _title(),
            _birthdayField(),
            _completeButton(context)
          ],
        ),
      ),
    );
  }
  
  void _request() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://$speckUrl/update/borntime");
    String bornTime = (_birthdayController.text.isNotEmpty)?_birthdayController.text:"N";
    String body = '''{
      "email" : "${sp.getString("email")}",
      "bornTime" : "$bornTime"
    }''';
    print(body);
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    var code = int.parse(utf8.decode(response.bodyBytes));

    if (code == 100) {
      print(sp.getKeys());
      await sp.setString("bornTime", bornTime);
      _ss.setBornTime(_birthdayController.text);
      errorToast("변경되었습니다.");
      Navigator.pop(context);
    }
    else {
      errorToast("다시 한번 시도해주세요.");
    }

  }
  
}
