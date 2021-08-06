import 'dart:convert';
import 'package:speck_app/util/util.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/main/my/setting/setting_all_info.dart';
import 'package:speck_app/route/route_builder.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';
class SetSex extends StatefulWidget {
  @override
  _SetSexState createState() => _SetSexState();
}

class _SetSexState extends State<SetSex> {
  UICriteria _uiCriteria = new UICriteria();
  int _selectedIndex = -1;
  SettingState _ss;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _ss = Provider.of<SettingState>(context, listen: false);

    return MaterialApp(
      title: "성별 설정",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(context),
        body: _setSex(),
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
              child: Text("성별 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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

  Widget _setSex() {
    return Container(
      padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, top: _uiCriteria.verticalPadding, bottom: _uiCriteria.totalHeight * 0.039),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _title(),
          _mw(),
          _completeButton()
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
      margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.0147),
      child: Text("성별", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
    );
  }

  Widget _mw() {
    return AspectRatio(
      aspectRatio: 343/50,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _section(0),
              SizedBox(width: constraint.maxWidth * 0.032),
              _section(1),
            ],
          );
        },
      ),
    );
  }

  Widget _section(int index) {
    String mw;
    switch (index) {
      case 0:
        mw = "남자";
        break;
      case 1:
        mw = "여자";
        break;
    }

    return Expanded(
      child: GestureDetector(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.5),
            color: (_selectedIndex != -1)?(_selectedIndex == index)?mainColor:greyD8D8D8:greyD8D8D8
          ),
          child: Text(mw, style: TextStyle(color: Colors.white, letterSpacing: 0.7, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),),
        ),
        onTap: () => _onTap(index),
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      if (_selectedIndex == -1) {
        _selectedIndex = index;
        print(_selectedIndex);
      }
      else {
        if (_selectedIndex == index) {
          _selectedIndex = -1;
          print(_selectedIndex);
        }
        else {
          _selectedIndex = index;
          print(_selectedIndex);
        }
      }
    });
  }

  Widget _completeButton() {
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
              onPressed: _setGender,
              color: mainColor,
              child: Text("완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
            ),
          )
        ],
      ),
    );
  }

  void _setGender() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    String gender = (_selectedIndex == -1)?"N":(_selectedIndex == 0)?"M":"W";
    Uri url = Uri.parse("http://$speckUrl/update/gender");
    String body = '''{
      "email" :  "$email",
      "gender" : "$gender"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var code = int.parse(utf8.decode(response.bodyBytes));
    if (code == 100) {
      await sp.setString("sex", gender);
      _ss.setGender(gender);
      errorToast("변경되었습니다.");
      Navigator.pop(context);
    }
    else {
      errorToast("다시 한번 시도해주세요.");
    }
  }
}
