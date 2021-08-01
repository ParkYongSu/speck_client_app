import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Main/my/speckcash/cash_withdrawal_page.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';

class CashInfo extends StatelessWidget {
  final String cashAmount;

  CashInfo({Key key, this.cashAmount}) : super(key: key);
  final UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return MaterialApp(
      title: "스펙 캐시",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
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
                  child: Text("나의 스펙 캐시", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0443),
          child: _cashInfo(context)
        ),
      ),
    );
  }

  Widget _cashInfo(BuildContext context) {
    return AspectRatio(
      aspectRatio: 343/158,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.9)
        ),
        child: Column(
          children: <Widget>[
            _cashAmount(context),
            _withdrawalButton(context)
          ],
        ),
      ),
    );
  }

  Widget _cashAmount(BuildContext context) {
    return Expanded(
      flex: 118,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(6.9), topRight: Radius.circular(6.9))
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.07),
            child: Container(
              padding: EdgeInsets.symmetric(vertical:  constraint.maxHeight * 0.0661),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white, width: 1))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset("assets/png/dust_won.png",color: Colors.white, height: constraint.maxHeight * 0.1983, fit: BoxFit.fill,),
                      Text(" 스펙 캐시", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize6, letterSpacing: 1.0),)
                    ]
                  ),
                  Text("${cashAmount.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize6, letterSpacing: 1.0))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _withdrawalButton(BuildContext context) {
    return Expanded(
      flex: 40,
      child: GestureDetector(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.9), bottomRight: Radius.circular(6.9))
          ),
          child: Text("지금 바로 출금하기", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
        ),
        onTap: () => _navigateWithdrawalPage(context),
      ),
    );
  }

  void _navigateWithdrawalPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CashWithdrawalPage(cash: cashAmount)));
  }
}
