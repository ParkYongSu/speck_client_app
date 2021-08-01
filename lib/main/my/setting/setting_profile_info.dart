import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/Login/Todo/validate_nickname.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:http/http.dart' as http;

class SetProfile extends StatefulWidget {

  @override
  _SetProfileState createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  UICriteria _uiCriteria = new UICriteria();
  PickedFile _image;
  TextEditingController _nicknameController;
  ValidateNickname validateNickname = new ValidateNickname();
  String _labelNickname;
  FontWeight _nicknameFW;
  bool _isNicknameCorrect;
  bool _isNicknameDuplicated;
  bool _isNicknameNotEmpty;
  bool _isBasicSelected;
  int _characterIndex;
  SettingState _ss;
  String _profile;
  bool _isImageSelected;

  @override
  void initState() {
    super.initState();
    _labelNickname = "닉네임";
    _nicknameFW = FontWeight.w700;
    _isNicknameCorrect = false;
    _isNicknameDuplicated = false;
    _isNicknameNotEmpty = false;
    _setController();
    _setting();
    _isImageSelected = false;
  }

  void _setting() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _profile = sp.getString("profile");
    print(_profile);
    if (_profile != "N") {
      _isBasicSelected = false;
    }
    else {
      _isBasicSelected = true;
    }
  }

  void _setController() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _nicknameController = new TextEditingController(text: sp.getString("nickname"));
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _ss = Provider.of<SettingState>(context, listen: false);

    return MaterialApp(
      title: "프로필 설정",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: _appBar(context),
        body: FutureBuilder(
          future: _getInfo(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _characterIndex = snapshot.data;
              return GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                child: Container(
                  padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(children: <Widget>[
                    _profileButton(_characterIndex),
                    _title(),
                    _nicknameField(),
                    _completeButton()
                  ]),
                ),
              );
            }
            else {
              return loader(context, 0);
            }
          },
        )
      ),
    );
  }

  Future<dynamic> _getInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt("characterIndex");
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
              child: Text("프로필 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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
        margin: EdgeInsets.only(bottom:  _uiCriteria.totalHeight * 0.0148,),
        alignment: Alignment.centerLeft,
        child: Text("$_labelNickname", style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: _nicknameFW, color: mainColor))
    );
  }

  Widget _profileButton(int characterIndex) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
          border: Border.all(color: greyD8D8D8, width: 1),
        ),
        margin: EdgeInsets.only(bottom:  _uiCriteria.totalHeight * 0.0431,),
        height: _uiCriteria.screenWidth * 0.44,
        width: _uiCriteria.screenWidth * 0.44,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                (!_isBasicSelected)
                ? (_image == null)
                ? Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(_profile),
                        fit: BoxFit.fill,
                      )
                  ),
                )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            alignment: Alignment.center,
                            image: FileImage(File(_image.path),),
                            fit: BoxFit.cover)
                    ))
                :Container(
                  margin: EdgeInsets.all(constraint.maxWidth * 0.166 ),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(getCharacter(characterIndex))
                      )
                  ),
                ),
                Container(
                  width: constraint.maxWidth * 0.3212,
                  height: constraint.maxWidth * 0.3212,
                  decoration: BoxDecoration(
                      border: Border.all(color: greyD8D8D8, width: 0.5),
                      shape: BoxShape.circle
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset("assets/png/set_profile.png", width: constraint.maxWidth * 0.1730,),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      onTap: () {
        _showSelectPicker();
      },
    );
  }

  Widget _nicknameField() {
    return AspectRatio(
      aspectRatio: 343/50,
      child: TextField(

          cursorColor: mainColor,
          style: TextStyle(fontSize: _uiCriteria.textSize2, color: mainColor, letterSpacing: 0.7, fontWeight: FontWeight.w500),
          keyboardType: TextInputType.text,
          onChanged: (String value) {
            if (value.length > 0) {
              setState(() {
                _isNicknameNotEmpty = true;
              });
              if (validateNickname.checkPassword(value).getIsCorrected()) {
                setState(() {
                  _isNicknameCorrect = true;
                });
                _nicknameDupCheck(value);

              }
              else {
                setState(() {
                  _isNicknameCorrect = false;
                  _labelNickname = "닉네임 형식을 확인해주세요.";
                  _nicknameFW = FontWeight.w800;
                });
              }
            }
            else {
              setState(() {
                _isNicknameNotEmpty = false;
                _labelNickname = "닉네임";
                _nicknameFW = FontWeight.w700;
              });
            }
          },
          controller: _nicknameController,
          decoration: InputDecoration(
              isDense: true,
              suffixIcon: (_isNicknameNotEmpty)
                  ? !_isNicknameDuplicated&&_isNicknameCorrect
                  ? Icon(Icons.check_circle, color: mainColor)
                  : Icon(Icons.error_rounded, color: mainColor,)
                  : null,
              // contentPadding:
              //     EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              enabledBorder: OutlineInputBorder(
                  borderSide: !_isNicknameNotEmpty
                      ? BorderSide(color: greyB3B3BC, width: 0.5)
                      : _isNicknameCorrect && !_isNicknameDuplicated
                      ? BorderSide(color: greyB3B3BC, width: 0.5)
                      : BorderSide(color: mainColor, width: 1.5)
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: !_isNicknameNotEmpty
                      ? BorderSide(color: greyB3B3BC, width: 0.5)
                      : _isNicknameCorrect && !_isNicknameDuplicated
                      ? BorderSide(color: greyB3B3BC, width: 0.5)
                      : BorderSide(color: mainColor, width: 1.5)),
              hintStyle: TextStyle(fontSize: _uiCriteria.textSize2, color: greyB3B3BC, height: 1.5),
              hintText: "한글, 영문, 숫자 2~8자리")),
    );
  }

  Widget _completeButton() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 343/50,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: MaterialButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.5)
                  ),
                  color:  mainColor,
                  disabledColor: greyD8D8D8,
                  child:
                  Text("완료", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700)),
                  onPressed: ((_isNicknameNotEmpty && _isNicknameCorrect && !_isNicknameDuplicated) || _isImageSelected)
                      ? () => _update((_image == null)?null:File(_image.path), _nicknameController.text)
                      : null
              ),
            ),
          )
        ],
      ),
    );
  }

  void _nicknameDupCheck(String nickname) async {
    TodoRegister todoRegister = new TodoRegister();
    Future<bool> future = todoRegister.isNicknameDuplicated(nickname);
    await future.then((value) => setState(() {
      if (value) {
        setState(() {
          _labelNickname = "이미 사용중인 닉네임이에요.";
          _nicknameFW = FontWeight.w800;
          _isNicknameDuplicated = value;
        });
      }
      else {
        setState(() {
          _labelNickname = "닉네임";
          _nicknameFW = FontWeight.w700;
          _isNicknameDuplicated = value;
        });
      }

    } ), onError: (e) => print(e));

    print("중복 $_isNicknameDuplicated");
  }

  // 카메라로 직접 가져옴
  _imgFromCamera () async {
    PickedFile image = await ImagePicker().getImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
      print("image ${image.path}");
      _isBasicSelected = false;
      _isImageSelected = true;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }
  // 앨범에서 가져옴
  _imgFromAlbum() async {
    PickedFile image = await ImagePicker().getImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
      _isBasicSelected = false;
      _isImageSelected = true;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  _selectBasicImage() {
    setState(() {
      _isBasicSelected = true;
      _isImageSelected = true;
      _image = null;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  _showSelectPicker() {
    final sheet = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("사진 찍기", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize4,)),
          onPressed: () {
            _imgFromCamera();
            // Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
            child: Text("앨범에서 선택", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize4,)),
            onPressed: () {
              _imgFromAlbum();
              // Navigator.pop(context);
            }
        ),
        CupertinoActionSheetAction(
            child: Text("기본 이미지 선택", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize4, )),
            onPressed: () {
              _selectBasicImage();
            }
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("취소", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: _uiCriteria.textSize4, )),
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return sheet;
        });
  }

  void _update(File image, String nickname) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url;
    if (image != null) {
      url = Uri.parse("http://13.209.138.39:8080/update/profile");
      var request = http.MultipartRequest('POST', url);
      String data = '''{
        "email" : "${sp.getString("email")}",
        "nickname" : "$nickname" 
      }''';
      request.fields["data"] = "$data";
      request.files.add(http.MultipartFile.fromBytes("profile", image.readAsBytesSync(), filename: ".jpg"));
      http.Response response = await http.Response.fromStream(await request.send());
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      print(result);
      int code = result["code"];
      if (code == 100) {
       await sp.setString("nickname", nickname);
       await  sp.setString("profile", result["profile"]);
        _ss.setProfile(nickname);
       errorToast("변경되었습니다.");
       Navigator.pop(context);
      }
      else {
        errorToast("다시 한번 시도해주세요.");

      }
    }
    else {
      String profile = (_isBasicSelected)?"N":"$_profile";
      url = Uri.parse("http://13.209.138.39:8080/update/profile/none");
      String body = '''{
        "email" : "${sp.getString("email")}",
        "nickname" : "$nickname",
        "profile" : "$profile"
      }''';
      Map<String, String> header = {
        "Content-Type" : "application/json"
      };

      var response = await http.post(url, headers: header, body: body);
      var code = int.parse(response.body);

      if (code == 100) {
        await sp.setString("nickname", nickname);
        await sp.setString("profile", profile);
        _ss.setProfile(nickname);
        errorToast("변경되었습니다.");
        Navigator.pop(context);
      }
      else {
        errorToast("다시 한번 시도해주세요.");
      }
    }
  }
}
