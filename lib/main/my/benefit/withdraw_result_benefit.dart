import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Main/main_page.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';

class BenefitWithdrawResult extends StatelessWidget {
  final String amount;

  BenefitWithdrawResult({Key key, this.amount}) : super(key: key);

  UICriteria _uiCriteria = new UICriteria();
  String _mainAccountBank;
  String _mainAccountNumber;
  String _mainAccountOwner;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return MaterialApp(
      title: "출금 결과 페이지",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: _appBar(context),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _getAccountInfo(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _setAccount(snapshot.data);
              return Container(
                padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, bottom: _uiCriteria.totalHeight * 0.039),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _icon(context),
                    _result(context),
                    _userInfo(context),
                    _notice(context),
                    _completeButton(context)
                  ],
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

  dynamic _getAccountInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://$speckUrl/account");
    String body = '''{
      "email" : "${sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("result");
    return result;
  }

  void _setAccount(dynamic data) async {
    _mainAccountBank = data["mainAccountBank"];
    _mainAccountNumber = data["mainAccountNumber"];
    _mainAccountOwner = data["mainAccountOwner"];
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
              child: Text("상금 출금하기", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),

        ],
      ),
    );
  }

  Widget _icon(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.1699),
      child: Icon(Icons.check_circle, size: _uiCriteria.screenWidth * 0.1493,
      ),
    );
  }

  Widget _result(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.0283),
      child: Column(
        children: <Widget>[
          Text("총 $amount원의 상금이", style: TextStyle(fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w700, color: mainColor, letterSpacing: 0.9),),
          Text("출금 완료 되었어요.", style: TextStyle(fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w700, color: mainColor, letterSpacing: 0.9),)
        ],
      ),
    );
  }

  Widget _userInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.02955),
      child: AspectRatio(
        aspectRatio: 343/50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0349),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.5),
                  border: Border.all(color: greyB3B3BC, width: 0.5)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("$amount원", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
                  Row(
                    children: <Widget>[
                      Text("$_mainAccountBank ", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5),),
                      Container(width: 1, height: _uiCriteria.textSize7, color: greyD8D8D8,),
                      Text(" $_mainAccountNumber ", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5),),
                      Container(width: 1, height: _uiCriteria.textSize7, color: greyD8D8D8,),
                      Text(" $_mainAccountOwner", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5),),
                    ],
                  )
                  // Consumer<AccountState>(
                  //   builder: (BuildContext context, AccountState as, Widget child) {
                  //     return Text("${as.getMainAccount()}",  style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5));
                  //   },
                  // )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _notice(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.0283),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("- 출금은 평일(공휴일 제외) 오후 6시부터 오후 7시 사이에 이루어집니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
          SizedBox(height: _uiCriteria.totalHeight * 0.0073),
          Text("- 출금은 당일 오후 6시 이전까지 접수된 출금 신청 내역만 처리해드립니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
          SizedBox(height: _uiCriteria.totalHeight * 0.0073),
          Text("- 평일 오후 6시 이후의 출금 신청은 다음 평일날에 접수됨을 유의 부탁드립니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
          SizedBox(height: _uiCriteria.totalHeight * 0.0073),
          Text("- 입금자명 표기는 '스펙상금출금'으로 표기됩니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),)
        ],
      ),
    );
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
              onPressed: () => _onPressed(context),
              color: mainColor,
              child: Text("완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
            ),
          )
        ],
      ),
    );
  }

  void _onPressed(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainNavigation()), (route) => false);
  }

}
