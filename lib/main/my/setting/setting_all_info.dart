import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';

import 'setting_birthday_info.dart';
import 'setting_character_info.dart';
import 'setting_phone_info.dart';
import 'setting_profile_info.dart';
import 'setting_sex_info.dart';

class ProfileInfo extends StatefulWidget {
  @override
  State createState() {
    return ProfileInfoState();
  }
}

class ProfileInfoState extends State<ProfileInfo> {
  final UICriteria _uiCriteria = new UICriteria();
  List<String> _userInfo;
  SettingState _ss;
  String _character;
  String _gender;
  String _bornTime;
  String _phoneNumber;
  String _nickname;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _ss = Provider.of<SettingState>(context, listen: true);

    return  Scaffold(
        appBar: _appBar(context),
        backgroundColor: greyF0F0F1,
        body: FutureBuilder(
          future: _getUserData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _userInfo = snapshot.data;
              // _userInfo = ["용수", "꼬미", "010-3213-3510", "남자", "1996.04.13"];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _title("나의 정보"),
                  _myInfoList(),
                  _title("선택 정보"),
                  _selectedInfoList()
                ],
              );
            }
            else {
              return loader(context, 0);
            }
          },
        )
    );
  }

  Future<List<String>> _getUserData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _ss.setCharacter(_getCharacter(sp.getInt("characterIndex")));
    _ss.setBornTime((sp.getString("bornTime") == "N")?"미입력":sp.getString("bornTime"));
    _ss.setGender((sp.getString("sex") == "N")?"미입력":(sp.getString("sex") == "M")?"남자":"여자");
    _ss.setPhoneNumber(sp.getString("phoneNumber"));
    _ss.setProfile(sp.getString("nickname"));
    _character = _ss.getCharacter();
    _gender = _ss.getGender();
    _bornTime = _ss.getBornTime();
    _phoneNumber = _ss.getPhoneNumber();
    _nickname = _ss.getProfile();

    List<String> userInfo = [_nickname, _character, _phoneNumber, _gender, _bornTime];
    return Future(() {
      return userInfo;
    });
  }

  String _getCharacter(int index) {
    switch (index) {
      case 0:
        return "뿌미";
        break;
      case 1:
        return "꼬미";
        break;
      case 2:
        return "팡이";
        break;
      case 3:
        return "쑤기";
        break;
    }
    return "";
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
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
              child: Text("프로필 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize16),)),
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

  Widget _title(String title) {
    return Container(
      padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, top: _uiCriteria.verticalPadding, bottom: _uiCriteria.totalHeight * 0.0135),
      child: Text(title, style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),),
    );
  }

  Widget _element(String title, int index) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
              Row(
                children: <Widget>[
                  Text(_userInfo[index], style: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                  Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                ],
              )
            ],
          ),
        ),
        onTap: () => _onPressed(index)
      ),
    );
  }

  void _onPressed(int index) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<Widget> _pageList = [SetProfile(), SetCharacter(index: sp.getInt("characterIndex"),), SetPhoneNumber(), SetSex(), SetBirthday()];
    Navigator.push(context, MaterialPageRoute(builder: (context) => _pageList[index]));
  }

  Widget _myInfoList() {
    return AspectRatio(
      aspectRatio: 375/111,
      child: Column(
        children: <Widget>[
          _element("프로필", 0),
          _element("캐릭터", 1),
          _element("연락처", 2),
        ],
      ),
    );
  }

  Widget _selectedInfoList() {

    return AspectRatio(
      aspectRatio: 375/74,
      child: Column(
        children: <Widget>[
          _element("성별", 3),
          _element("생년월일", 4),
        ],
      ),
    );
  }
}
