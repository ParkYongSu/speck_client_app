import 'dart:convert';

import 'package:speck_app/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Main/my/speckcash/result_withdraw_cash.dart';
import 'package:speck_app/main/my/account/my_account_info.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';

class CashWithdrawalPage extends StatefulWidget {
  final String cash;

  const CashWithdrawalPage({Key key,@required this.cash}) : super(key: key);

  @override
  _CashWithdrawalPageState createState() => _CashWithdrawalPageState();
}

class _CashWithdrawalPageState extends State<CashWithdrawalPage> {
  UICriteria _uiCriteria = new UICriteria();
  final TextEditingController _moneyController = new TextEditingController();
  bool _cashCorrect;
  String _amount;

  @override
  void initState() {
    super.initState();
    _cashCorrect = false;
    _amount = "0";
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return MaterialApp(
      title: "캐시 출금 페이지",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _appBar(context),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, _uiCriteria.verticalPadding, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _title(context),
                _moneyField(context),
                _notice(context),
                _nextButton(context)
              ],
            ),
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
              child: Text("캐시 출금하기", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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
    return Text("출금 금액", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),);
  }

  Widget _moneyField(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0147),
      child: AspectRatio(
        aspectRatio: 343/50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Stack(
              alignment: Alignment.centerRight,
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
                  controller: _moneyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: "원하는 금액을 입력",
                    hintStyle: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.7, color: greyB3B3BC, fontSize: _uiCriteria.textSize2),
                    contentPadding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0349)
                  ),
                  onChanged: (String value) {
                    _onChanged(value);
                    // _checkCorrect(value);
                  },
                ),
                (_cashCorrect)
                ?Container(
                    margin: EdgeInsets.only(right: constraint.maxWidth * 0.0349),
                    width: _uiCriteria.textSize6,
                    height: _uiCriteria.textSize6,
                    alignment: Alignment.center,
                    child: Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.textSize6,))
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("- 출금은 평일(공휴일 제외) 오후 6시부터 오후 7시 사이에 이루어집니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
        SizedBox(height: _uiCriteria.totalHeight * 0.0073),
        Text("- 출금은 당일 오후 6시 이전까지 접수된 출금 신청 내역만 처리해드립니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
        SizedBox(height: _uiCriteria.totalHeight * 0.0073),
        Text("- 평일 오후 6시 이후의 출금 신청은 다음 평일날에 접수됨을 유의 부탁드립니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
        SizedBox(height: _uiCriteria.totalHeight * 0.0073),
        Text("- 입금자명 표기는 '스펙캐시출금'으로 표기됩니다.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),)
      ],
    );
  }

  Widget _nextButton(BuildContext context) {
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
              onPressed:
              (_cashCorrect)
              ?() => _shoeWithdrawDialog(context)
              : null  ,
              color: mainColor,
              child: Text("다음", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
            ),
          )
        ],
      ),
    );
  }

  void _onChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        try {
          int amount = int.parse(value);
          if (amount == 0) {
            _moneyController.clear();
          }
          else {
            _cashCorrect = true;
          }
        }
        catch (e) {
          print(e);
        }
      }
      else {
        _cashCorrect = false;
      }
    });
  }

  void _withdraw() async {
    Navigator.of(context, rootNavigator: true).pop();
    if (int.parse(widget.cash) >= int.parse(_moneyController.text)) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String value = _moneyController.text;
      int withdrawal = int.parse(value);
      _amount = value.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

      var url = Uri.parse("http://$speckUrl/send");
      String body = '''{
      "userEmail" : "${sp.getString("email")}",
      "withdrawal" : $withdrawal,
      "method" : 0
    }''';
      Map<String, String> header = {
        "Content-Type" : "application/json"
      };

      _showLoader();
      var response = await http.post(url, body: body, headers: header);
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      print("캐시 결과 $result");
      var code = result["statusCode"];

      if (code == 230) {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.of(context, rootNavigator: true).pop();
        }).whenComplete(() => Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(builder: (context) => CashWithdrawResult(amount: _amount,)), (route) => false));
      }
      else if (code == 432) {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.of(context, rootNavigator: true).pop();
        }).whenComplete(() => _showSetAccountDialog());
      }
      else {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.of(context, rootNavigator: true).pop();
        }).whenComplete(() => errorToast("다시 한번 시도해주세요."));
      }
    }
    else {
      errorToast("캐시가 부족합니다.");
    }
  }

  void _showSetAccountDialog() {
    showDialog(
      context: context,
      builder: _setAccountDialog
    );
  }

  Widget _setAccountDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      content: Container(
        width: _uiCriteria.screenWidth,
        child: AspectRatio(
          aspectRatio: 260/122,
          child: Column(
            children: [
              Expanded(
                  flex: 82,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(flex: 235,),
                          Text("등록된 계좌가 없어요", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.screenWidth * 0.042, fontWeight: FontWeight.w700),),
                          Spacer(flex: 50),
                          Text("계좌를 등록하시겠어요?", style: TextStyle(letterSpacing: 0.5, color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),),
                          Spacer(flex: 245,)
                        ],
                      ))),
              Expanded(
                flex: 39,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                alignment: Alignment.center,
                                child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
                            )
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                alignment: Alignment.center,
                                child: Text("계좌등록", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                            onTap:() {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountInfo()));
                            },
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
                        width: uiCriteria.screenWidth,
                        height: uiCriteria.totalHeight,
                        child: Container(
                          width: uiCriteria.screenWidth * 0.0666,
                          height: uiCriteria.screenWidth * 0.0666,
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

  void _shoeWithdrawDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _withdrawDialog(context);
        });
  }

  Widget _withdrawDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      content: Container(
        width: _uiCriteria.screenWidth,
        child: AspectRatio(
          aspectRatio: 260/105,
          child: Column(
            children: [
              Expanded(
                  flex: 619,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      alignment: Alignment.center,
                      child: Text("${_moneyController.text.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원을 출금하시겠어요?", style: TextStyle(letterSpacing: 0.7,color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),))),
              Expanded(
                flex: 371,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                alignment: Alignment.center,
                                child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
                            )
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _withdraw();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: greyD8D8D8, width: 0.5))),
                                alignment: Alignment.center,
                                child: Text("출금", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
