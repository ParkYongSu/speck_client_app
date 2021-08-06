import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/account_state.dart';
import 'package:speck_app/main/my/setting/my_settings.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';

class AccountSettingPage extends StatefulWidget {
  final int index;

  const AccountSettingPage(
      {Key key,
    @required this.index})
      : super(key: key);

  @override
  _AccountSettingPageState createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  UICriteria _uiCriteria = new UICriteria();
  final TextEditingController _accountOwnerController = new TextEditingController();
  final TextEditingController _bankController = new TextEditingController();
  final TextEditingController _accountNumberController = new TextEditingController();
  AccountState _as;
  // AccountState _accountState;

  bool _accountOwnerIsNotEmpty;
  bool _accountNumberIdNotEmpty;
  bool _bankIsNotEmpty;

  @override
  void initState() {
    super.initState();
    _accountOwnerIsNotEmpty = false;
    _accountNumberIdNotEmpty = false;
    _bankIsNotEmpty = false;
  }



  @override
  Widget build(BuildContext context) {
    _as = Provider.of<AccountState>(context, listen: false);
    _uiCriteria.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
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
                child: Text("계좌 설정", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _title(context),
              _content(context, "예금주", "예금주명 입력", _accountOwnerController),
              SizedBox(height: _uiCriteria.totalHeight * 0.0135,),
              _content(context, "은행선택", "은행 입력", _bankController),
              SizedBox(height: _uiCriteria.totalHeight * 0.0135,),
              _content(context, "계좌번호", "-없이 숫자만 입력", _accountNumberController),
              _completeButton(context)
            ],
          ),
        ),
      ),
    );
  }


  Widget _title(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, 0, _uiCriteria.totalHeight * 0.0135),
        child: Text("계좌 등록", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize2 , fontWeight: FontWeight.w700, color: mainColor),));
  }

  Widget _content(BuildContext context, String title, String hintText, TextEditingController controller) {
    return AspectRatio(
      aspectRatio: 375/50,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 84/50,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor, width: 0.5),
                  borderRadius: BorderRadius.circular(3.5)
                ),
                child: Text(title, style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, color: mainColor, letterSpacing: 0.7),),
              ),
            ),
            AspectRatio(
              aspectRatio: 247/50,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.5),
                            border: Border.all(color: greyB3B3BC, width: 0.5)
                        ),
                      ),
                      TextFormField(
                        controller: controller,
                        style: TextStyle(fontWeight: FontWeight.w500, color: mainColor, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),
                        cursorColor: mainColor,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                          hintText: hintText,
                          hintStyle: TextStyle(color: greyB3B3BC, letterSpacing: 0.7, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, ),
                          border: InputBorder.none,
                        ),
                        onChanged: (String value) {
                          _onChanged(value, controller);
                        },
                      ),
                    ],
                  );
                },
              )
            )
          ],
        ),
      ),
    );
  }

  void _onChanged(String value, TextEditingController controller) {
    switch (value.length) {
      case 0:
        if (controller == _accountOwnerController) {
          setState(() {
            _accountOwnerIsNotEmpty = false;
          });
        }
        else if (controller == _accountNumberController) {
          setState(() {
            _accountNumberIdNotEmpty = false;
          });
        }
        else {
          setState(() {
            _bankIsNotEmpty = false;
          });
        }
        break;

      default:
        if (controller == _accountOwnerController) {
          setState(() {
            _accountOwnerIsNotEmpty = true;
          });
        }
        else if (controller == _accountNumberController) {
          setState(() {
            _accountNumberIdNotEmpty = true;
          });
        }
        else {
          setState(() {
            _bankIsNotEmpty = true;
          });
        }
        break;
    }

  }

  Widget _completeButton(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(bottom:  _uiCriteria.totalHeight * 0.039),
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
            child: AspectRatio(
              aspectRatio: 343/50,
              child: MaterialButton(
                onPressed: (_accountNumberIdNotEmpty && _accountOwnerIsNotEmpty && _bankIsNotEmpty)?() => _setAccount(widget.index):null,
                color: mainColor,
                disabledColor: greyD8D8D8,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.5)
                ),
                child: Text("완료", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPressed(int index) async {
    // (index == 0)?_setMainAccount():_setSubAccount();
  }

  void _setAccount(int index) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse((index == 0)?"http://$speckUrl/account/set/main":"http://$speckUrl/account/set/sub");
    String body = (index == 0)
    ? '''{
      "email" : "${sp.getString("email")}",
      "mainAccountOwner" : "${_accountOwnerController.text}",
      "mainAccountNumber" : "${_accountNumberController.text}",
      "mainAccountBank" : "${_bankController.text}"
    }'''
    : '''{
      "email" : "${sp.getString("email")}",
      "subAccountOwner" : "${_accountOwnerController.text}",
      "subAccountNumber" : "${_accountNumberController.text}",
      "subAccountBank" : "${_bankController.text}"
    }''';
    print(body);
    Map<String,String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var result = int.parse(utf8.decode(response.bodyBytes));
    print(result);
    if (result == 100) {
      (index == 0)
          ?_as.setMainAccount("${_bankController.text} ${_accountNumberController.text} ${_accountOwnerController.text}")
          :_as.setSubAccount("${_bankController.text} ${_accountNumberController.text} ${_accountOwnerController.text}");
      (index == 0)
          ?_as.setEnterMain("수정하기")
          :_as.setEnterSub("수정하기");
      print(_as.getMainAccount());
      Navigator.pop(context);
    }
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container();
        }
      );
    }
  }
}
