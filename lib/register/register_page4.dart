import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/Login/Todo/todo_register.dart';
import 'package:speck_app/Login/Todo/validate_nickname.dart';
import 'package:speck_app/State/register_state.dart';
import 'package:provider/provider.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';

class RegisterPage4 extends StatefulWidget {
  @override
  State createState() {
    return RegisterPageState4();
  }
}

class RegisterPageState4 extends State<RegisterPage4> {
  final TextEditingController _nicknameController = new TextEditingController();
  ValidateNickname validateNickname = new ValidateNickname();
  final UICriteria _uiCriteria = new UICriteria();
  PickedFile _image;
  RegisterState _registerState;
  TodoRegister _todoRegister = new TodoRegister();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _registerState = Provider.of<RegisterState>(context, listen: false);

    return MaterialApp(
      title: "회원가입 4",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 0,
            centerTitle: true,
            toolbarHeight: _uiCriteria.appBarHeight,
            backgroundColor: mainColor,
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
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Container(
              padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(children: <Widget>[
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    height: _uiCriteria.screenWidth * 0.44,
                    width: _uiCriteria.screenWidth * 0.44,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: greyD8D8D8, width: 1),
                    ),
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraint) {
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            (_isBasicSelected)
                            ? Container(
                              margin: EdgeInsets.all(constraint.maxWidth * 0.166 ),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage(getCharacter(_registerState.getCharacterIndex()))
                                  )
                              ),
                            )
                            :(_image == null)
                            ? Container(
                              margin: EdgeInsets.all(constraint.maxWidth * 0.166 ),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage(getCharacter(_registerState.getCharacterIndex()))
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
                                   fit: BoxFit.cover
                                )
                              ),
                            ),
                            // CircleAvatar(
                            //     radius: double.infinity,
                            //     child: _image == null
                            //         ?Image.asset("assets/png/register_profile.png", height: double.infinity,)
                            //         :Image.file(File(_image.path), fit: BoxFit.contain,)
                            // ),
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
                ),
                SizedBox(height: _uiCriteria.totalHeight * 0.0431,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("$_labelNickname", style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: _nicknameFW, color: mainColor))
                ),
                SizedBox(height: _uiCriteria.totalHeight * 0.0148,),
                AspectRatio(
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
                            ? Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.textSize6,)
                              : Icon(Icons.error, color: mainColor, size: _uiCriteria.textSize6,)
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
                ),
                Expanded(
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
                              onPressed: (_isNicknameNotEmpty && _isNicknameCorrect && !_isNicknameDuplicated)
                                  ? () => _register()
                                  : null
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ]),
            ),
          )),
    );
  }

  bool _isNicknameCorrect;
  bool _isNicknameDuplicated;
  bool _isNicknameNotEmpty;
  bool _isBasicSelected;
  String _labelNickname;
  FontWeight _nicknameFW;

  @override
  void initState() {
    super.initState();
    _isNicknameCorrect = false;
    _isNicknameDuplicated = false;
    _isNicknameNotEmpty = false;
    _labelNickname = "닉네임";
    _nicknameFW = FontWeight.w700;
    _isBasicSelected = false;
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

  void _register() async {
    WidgetsFlutterBinding.ensureInitialized();
    String email = _registerState.getEmail();
    String pw = _registerState.getPassword();
    String phoneNumber = _registerState.getPhoneNumber();
    String nickname = _nicknameController.text;
    print("닉네임 $nickname");
    _registerState.setNickname(nickname);
    String sex = _registerState.getGender();
    int characterIndex = _registerState.getCharacterIndex();
    String service = _registerState.getService();
    String personalInformationCollection = _registerState.getPersonalInformationCollection();
    String receiveEventInformation = _registerState.getReceiveEventInformation();

    File image;
    if (_image == null) {
      image = null;
    }
    else {
      image = new File(_image.path);
    }
    print("image $image");
    // N, M,
    String bornTime2 = _registerState.getBirthday1();

    _request1(email, pw, phoneNumber, nickname, sex, bornTime2, characterIndex, service, personalInformationCollection, receiveEventInformation,image);

  }

  void _request1(String email, String pw, String phoneNumber, String nickname,
      String sex, String bornTime, int characterIndex, String service, String personalInformationCollection,
      String receiveEventInformation, File image) async{
    var result;
    Future<String> future = _todoRegister.register1(email, pw, phoneNumber, nickname, sex, bornTime);
    await future.then((value) => result = value, onError: (e) => print(e));
    print(result);
    if (result == "100") {
      print("1단계 통과");
      String bornTime1 = _registerState.getBirthday2();
      _request2(email, pw, phoneNumber, nickname, sex, bornTime1, characterIndex, service, personalInformationCollection, receiveEventInformation,image);
    } else {
      print("1단계 실패");
      print("가입실패");
    }
  }

  void _request2(String email, String pw, String phoneNumber, String nickname,
      String sex, String bornTime, int characterIndex, String service, String personalInformationCollection,
      String receiveEventInformation, File image,) async {
    var result;
    Future future = (image == null)
        ?_todoRegister.requestUSerDataNoneProfile(email, pw, phoneNumber, nickname, sex, bornTime, characterIndex, service, personalInformationCollection, receiveEventInformation)
        :_todoRegister.requestUserDataProfile(email, pw, phoneNumber, nickname, sex, bornTime, characterIndex, service, personalInformationCollection, receiveEventInformation, image);
    _showLoader();
    await future.then((value) => result = value);
    if (result == 100) {
      print("2단계 통과");
      print("가입성공");
      // 현재 시간
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop();
      }).whenComplete(() {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmailLoginPage()), (route) => false);
        Fluttertoast.showToast(msg: "가입되었습니다.", gravity: ToastGravity.CENTER, fontSize: _uiCriteria.textSize2);
      }
      );
    }
    else {
      print("2단계 실패");
    }
  }

  void _showLoader() {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return _loader();
        });
  }

  Widget _loader() {
    AlertDialog dialog = new AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
      ),
      content: AspectRatio(
          aspectRatio: 260/135,
          child: Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.transparent
                        ),
                        width: _uiCriteria.screenWidth,
                        height: _uiCriteria.totalHeight,
                        child: Container(
                          width: _uiCriteria.screenWidth * 0.0666,
                          height: _uiCriteria.screenWidth * 0.0666,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(mainColor)
                          ),
                        ),
                      ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                      ),
                      alignment: Alignment.center,
                      child: Text("잠시만 기다려주세요", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: _uiCriteria.textSize2, letterSpacing: 0.6),))),
            ],
          )
      ),
    );

    return dialog;
  }

// 카메라로 직접 가져옴
  _imgFromCamera () async {
    try {
      PickedFile image = await ImagePicker().getImage(
          source: ImageSource.camera, imageQuality: 50);
      setState(() {
        _image = image;
        _isBasicSelected = false;
      });
    }
    catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }
  // 앨범에서 가져옴
  _imgFromAlbum() async {
    try {
      PickedFile image = await ImagePicker().getImage(
          source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        _image = image;
        print("imagePath ${_image.path}");
        _isBasicSelected = false;
      });
    }
    catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  _selectBasicImage() {
    setState(() {
      _isBasicSelected = true;
      _image = null;
    });
    Navigator.pop(context);
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
        onPressed: () => Navigator.pop(context),
      ),
    );
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return sheet;
        });
  }
}
