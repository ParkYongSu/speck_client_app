import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/account_state.dart';
import 'package:speck_app/main/my/account/my_account_set_page.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';

class AccountInfo extends StatefulWidget {
  @override
  _SetAccountState createState() => _SetAccountState();
}

class _SetAccountState extends State<AccountInfo> {
  UICriteria _uiCriteria = new UICriteria();
  String _mainAccountOwner;
  String _mainAccountNumber;
  String _mainAccountBank;
  String _subAccountOwner;
  String _subAccountNumber;
  String _subAccountBank;
  String _mainAccount;
  String _subAccount;
  String _enterMain;
  String _enterSub;
  AccountState _as;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _as = Provider.of<AccountState>(context, listen: false);

    return Scaffold(
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
        backgroundColor: greyF0F0F1,
        body: FutureBuilder(
          future: _getAccount(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _setData(snapshot.data);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _title(context),
                  _totalAccount(context)
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

  void _setData(dynamic response) {
    if (response["mainAccountOwner"] == null || response["mainAccountNumber"] == null || response["mainAccountBank"] == null) {
      _as.setMainAccount2("주계좌 없음");
      _as.setEnterMain2("추가하기");
    }
    else {
      _as.setMainAccount2(response["mainAccountBank"] + " " + response["mainAccountNumber"] + " " + response["mainAccountOwner"]);
      _as.setEnterMain2("수정하기");
    }

    if (response["subAccountOwner"] == null || response["subAccountNumber"] == null || response["subAccountBank"] == null) {
      _as.setSubAccount2("부계좌 없음");
      _as.setEnterSub2("추가하기");
    }
    else {
      _as.setSubAccount2(response["subAccountBank"] + " " + response["subAccountNumber"] + " " + response["subAccountOwner"]);
      _as.setEnterSub2("수정하기");
    }
  }

  Future<dynamic> _getAccount() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://13.209.138.39:8080/account");
    String body = '''{
      "email" : "${sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return result;
  }

  Widget _title(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, 0, _uiCriteria.totalHeight * 0.0135),
        child: Text("나의 계좌", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: mainColor),));
  }

  Widget _totalAccount(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/74,
      child: Consumer<AccountState>(
        builder: (BuildContext context, AccountState as, Widget child) {
          return  Column(
            children: <Widget>[
              _accountButton(context, as.getMainAccount(), _as.getEnterMain(), 0),
              _accountButton(context, _as.getSubAccount(), _as.getEnterSub(), 1),
            ],
          );
    },
       )
    );
  }

  Widget _accountButton(BuildContext context, String account, String text, int index) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(account, style: TextStyle(letterSpacing: 0.6, color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3),),
              Row(
                children: <Widget>[
                  Text("$text ", style: TextStyle(letterSpacing: 0.6, color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3),),
                  Icon(Icons.arrow_forward_ios_rounded, color: greyB3B3BC, size: _uiCriteria.textSize5,)
                ],
              )
            ],
          ),
        ),
        onTap: () => _navigateSetPage(context, index),
      ),
    );
  }

  void _navigateSetPage(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingPage(index: index,)));
  }
}
