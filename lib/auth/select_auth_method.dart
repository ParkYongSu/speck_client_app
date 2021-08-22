import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/auth/gps_auth.dart';
import 'package:speck_app/auth/qr_scanner.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';

class AuthMethod extends StatefulWidget {
  @override
  _AuthMethodState createState() => _AuthMethodState();
}

class _AuthMethodState extends State<AuthMethod> {
  CardTime _cardTime;

  @override
  void dispose() {
    super.dispose();
    if (_cardTime.seconds != null) {
      _cardTime.startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    _cardTime = Provider.of<CardTime>(context, listen: false);
    return _authMethod(context);
  }

  Widget _authMethod(BuildContext context) {
    return Scaffold(
        backgroundColor: mainColor,
        appBar: appBar(context, "출석 인증"),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Spacer(flex: 1408,),
                _title(),
                Spacer(flex: 350,),
                _method(context),
                Spacer(flex: 2797,),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: uiCriteria.screenWidth,
                  child: Image.asset("assets/png/select_method_draw.png", fit: BoxFit.fitWidth,)),
            )
          ],
        )
    );
  }

  /// 타이틀
  Widget _title() {
    return Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.17), blurRadius: 26, spreadRadius: 0, offset: Offset(-4,0))]
        ),
        child: Text("원하는 인증 방식을 선택해주세요", style: TextStyle(fontSize: uiCriteria.textSize6, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.05),));
  }

  /// 선택항목
  Widget _method(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
      child: Row(
        children: <Widget>[
          _methodButton(context, "assets/png/qr_method.png","QR코드 스캔", "클릭해서 카메라로 스캔", "스펙존에서만 가능해요", "공간 방문으로 집밖 인증!", QrScanner()),
          SizedBox(width: uiCriteria.screenWidth * 0.064,),
          _methodButton(context, "assets/png/gps_method.png","100m 이동", "클릭해서 측정 시작", "전 지역에서 가능해요", "GPS 측정으로 집밖 인증!", GpsAuth()),
        ],
      ),
    );
  }

  /// QR 스캔
  Widget _methodButton(BuildContext context,String image, String title1, String title2, String info1, String info2, Widget page) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 159.5/247.2,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
              child: AspectRatio(
                aspectRatio: 159.5/185.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.9),
                  ),
                  child: Column(
                    children: <Widget>[
                      Spacer(flex: 240,),
                      Image.asset(image),
                      Spacer(flex: 169,),
                      Text(title1, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.bold, letterSpacing: 0.8),),
                      Spacer(flex: 40,),
                      Text(title2, style: TextStyle(color: greyAAAAAA, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                      Spacer(flex: 110,)
                    ],
                  ),
                ),
              ),
            ),
            Spacer(flex: 194,),
            Text(info1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize2, letterSpacing: 0.2),),
            Spacer(flex: 83,),
            Text(info2, style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize2, letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }
}


