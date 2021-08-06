import 'dart:convert';
import 'package:speck_app/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';

class SetCharacter extends StatefulWidget {
  final int index;

  const SetCharacter({Key key, this.index}) : super(key: key);

  @override
  SetCharacterState createState() => SetCharacterState();
}

class SetCharacterState extends State<SetCharacter> {
  UICriteria _uiCriteria = new UICriteria();
  int _selectedIndex;
  List<String> _imageList;
  bool _isSelected;
  SettingState _ss;

  @override
  void initState() {
    super.initState();
    _imageList = [
      "assets/png/bbumi.png",
      "assets/png/ggomi.png",
      "assets/png/pang.png",
      "assets/png/ssugi.png",
    ];
    _isSelected = false;
    _selectedIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _ss = Provider.of<SettingState>(context, listen: false);

    return MaterialApp(
      title: "캐릭터 설정",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: _appBar(context),
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, top: _uiCriteria.verticalPadding, bottom: _uiCriteria.totalHeight * 0.039),
          decoration: BoxDecoration(
              color: Colors.white
          ),
          child: Column(
            children: <Widget>[
              _title(context),
              _characterList(context),
              _nextButton(context)
            ],
          ),
        ),
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
              child: Text("캐릭터 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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

  Widget _title(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.0332),
      child: AspectRatio(
        aspectRatio: 343/46,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("캐릭터 스타일 선택", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7),),
              Text("원하는 캐릭터를 선택해주세요", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize1, fontWeight: FontWeight.bold, letterSpacing: 0.8),)
            ],
          ),
        ),
      ),
    );
  }

  String _getCharacterName(int index) {
    switch (index) {
      case 0:
        return "뿌미";
      case 1:
        return "꼬미";
      case 2:
        return "팡이";
      case 3:
        return "쑤기";
    }
    return "";
  }

  String _getCharaterPrefer(int index) {
    switch (index) {
      case 0:
        return "스터디카페를 좋아해요";
      case 1:
        return "독서실을 좋아해요";
      case 2:
        return "카페를 좋아해요";
      case 3:
        return "도서관을 좋아해요";
    }
  }

  Widget _character(BuildContext context, int index) {
    String name = _getCharacterName(index);
    String pref = _getCharaterPrefer(index);
    print("$_selectedIndex $index");
    return Expanded(
      child: GestureDetector(
        onTap: () => _tapAction(index),
        child: AspectRatio(
            aspectRatio: 159.5/185.5,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
                return Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(constraint.maxWidth * 0.0877),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), spreadRadius: 0, blurRadius: 6, offset: Offset(0,3))],
                          borderRadius: BorderRadius.circular(3.5)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: (_selectedIndex == index)? mainColor:greyD8D8D8, size: _uiCriteria.textSize4,),
                            ],
                          ),
                          SizedBox(height: constraint.maxHeight * 0.0485,),
                          Container(
                            width: constraint.maxWidth * 0.4852,
                            height: constraint.maxWidth * 0.4852,
                            child: Image.asset(_imageList[index]),
                          ),
                          SizedBox(height: constraint.maxHeight * 0.0781,),
                          Text(name, style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize1, fontWeight: FontWeight.bold, letterSpacing: 0.8),),
                          SizedBox(height: constraint.maxHeight * 0.0108,),
                          Text(pref, style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                        ],
                      ),
                    ),
                    (_selectedIndex == index)
                        ? Container(
                      decoration: BoxDecoration(
                          color: greyD8D8D8.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3.5)
                      ),
                    )
                        : Container()
                  ],
                );
              },
            )
        ),
      ),
    );
  }

  void _tapAction(int index) {
    setState(() {
      if (index == _selectedIndex) {
        _isSelected = false;
        _selectedIndex = -1; // 아무값이나 대입
      }
      else {
        _selectedIndex = index;
        _isSelected = true;
      }
    });
    print(_selectedIndex);
  }

  Widget _characterList(BuildContext context) {
    List<Widget> list = List.generate(4, (index) => _character(context, index));
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            list[0],
            // _character(context, 0),
            SizedBox(width: _uiCriteria.screenWidth * 0.064,),
            list[1]
            // _character(context, 1),
          ],
        ),
        SizedBox(height: _uiCriteria.verticalPadding,),
        Row(
          children: <Widget>[
            list[2],
            // _character(context, 2),
            SizedBox(width: _uiCriteria.screenWidth * 0.064,),
            list[3]
            // _character(context, 3),
          ],
        )
      ],
    );
  }

  Widget _nextButton(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                    onPressed:
                    !_isSelected
                        ? null
                        : () => _onPressed()
                )),
          ),
        ],
      ),
    );
  }

  _onPressed() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://$speckUrl/update/character");
    String body = '''{
      "email" : "${sp.getString("email")}",
      "character" : $_selectedIndex
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, body: body, headers: header);
    var code = int.parse(utf8.decode(response.bodyBytes));

    print(code);
    if (code == 100) {
      await sp.setInt("characterIndex", _selectedIndex);
      _ss.setCharacter(_getCharacterName(_selectedIndex));
      errorToast("변경되었습니다.");
      Navigator.pop(context);
    }
    else {
      errorToast("다시 한번 시도해주세요.");
    }
  }
}
