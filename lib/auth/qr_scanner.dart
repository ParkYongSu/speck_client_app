import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/auth_status.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/auth/todo_auth.dart';
import 'package:speck_app/main.dart';
import 'package:speck_app/main/my/ticket/ticket_ui.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';
import 'package:speck_app/util/util.dart';

class QrScanner extends StatefulWidget {
  @override
  State createState() {
    return QrScannerState();
  }
}

class QrScannerState extends State<QrScanner> {
  QRViewController _qrViewController;
  final GlobalKey _qrKey = new GlobalKey();
  TodoAuth todoAuth = new TodoAuth();
  UICriteria _uiCriteria = new UICriteria();
  String _placeName;
  int _attCount;
  int _totalCount;
  int _attRate;
  int _totalDeposit;
  int _myDeposit;
  int _totalDust;
  int _accumPrize;
  int _estimatePrize;
  String _attendTime;
  String _galaxyName;
  int _timeNum;
  int _mannerTime;
  CardTime _cardTime;
  @override
  Widget build(BuildContext context) {
    _cardTime = Provider.of<CardTime>(context, listen: false);
    _uiCriteria.init(context);
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          titleSpacing: 0,
          toolbarHeight: _uiCriteria.appBarHeight,
          elevation: 0,
          title: Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
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
          ),
        ),
        body: _createQrView()
    );

  }

  Widget _createQrView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Color(0XFFFFED5A),
              borderRadius: 10,
              borderWidth: 10,
            ),
          ),
          _qrText()
        ],
      )
    );
  }

  Widget _qrText() {
    TextStyle textStyle = new TextStyle(shadows: [Shadow(color: Colors.white.withOpacity(0.31), blurRadius: 3, offset: Offset(0,3))]
      , color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700,);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Spacer(flex: 3),
        Text("QR코드를 스캔해", style: textStyle,),
        SizedBox(height: _uiCriteria.totalHeight * 0.0049,),
        Text("출석을 인증해주세요", style: textStyle,),
        Spacer(flex: 1,)
      ],
    );
  }


  @override
  void dispose() {
    super.dispose();
    _qrViewController?.dispose();
    if (_cardTime.seconds != null) {
      _cardTime.startTimer();
    }
  }

  void _showLoader() {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return loaderDialog();
        });
  }

  // qr 스캐너가 생성될 때 호출되는 메서드
  void _onQRViewCreated(QRViewController qrViewController) async {
    String qr;
    setState(() {
      this._qrViewController = qrViewController;
    });
    qrViewController.scannedDataStream.listen((scanDate) async {
      if (qr == null) {
        qr = scanDate.code;
        dynamic result;
        Future future = _auth(qr);
        await future.then((value) => result = value);
        int statusCode = result["defaultRes"]["statusCode"];
        dynamic ticket = result["ticket"];
        _showLoader();
        switch (statusCode) {
          case 220:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _setTicketData(ticket);
              _showTicket(context, _placeName, _attCount, _totalCount, _attRate, _totalDeposit, _myDeposit,
                  _totalDust, _accumPrize, _estimatePrize, _attendTime);
            });
            break;
          case 320:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "출석 인증 가능 시간이 아니에요.");
            });
            break;
          case 321:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "오늘 예약한 탐험단이 없어요.");
            });
            break;
          case 322:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "출석이 완료된 탐험단이에요.");
            });
            break;
          case 411:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "QR을 다시 한번 촬영해 주세요.");
            });
            break;
          case 412:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "QR을 다시 한번 촬영해 주세요.");
            });
            break;
          case 420:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "QR을 다시 한번 촬영해 주세요.");
            });
            break;
          case 421:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "QR을 다시 한번 촬영해 주세요.");
            });
            break;
          case 422:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "QR을 다시 한번 촬영해 주세요.");
            });
            break;
          case 423:
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            }).then((value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              _showResult(context, "QR을 다시 한번 촬영해 주세요.");
            });
            break;
        }
      }
    },
    onDone: () {
      _qrViewController.dispose();
    }
    );
  }

  void _setTicketData(dynamic ticket) {
    _placeName = ticket["placeName"];
    _attCount = ticket["attendCount"];
    _totalCount = ticket["totalCount"];
    _attRate = ticket["attRate"];
    _totalDeposit = ticket["totalDeposit"];
    _myDeposit = ticket["myDeposit"];
    _totalDust = ticket["totalDust"];
    _accumPrize = ticket["accumPrize"];
    _estimatePrize = ticket["estimatePrize"];
    _attendTime = ticket["attendTime"];
    _galaxyName = ticket["galaxyName"];
    _timeNum = ticket["timeNum"];
    _mannerTime = ticket["mannerTime"];
  }

  void _showTicket(BuildContext context, String placeName, int attCount, int totalCount, int attRate,
      int totalDeposit, int myDeposit, int totalDust, int accumPrize, int estimatePrize, String attendTime) {
    AlertDialog dialog = new AlertDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
      content: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ticket(context, placeName, attCount, totalCount, attRate, totalDeposit, myDeposit, totalDust, accumPrize, estimatePrize, attendTime, _timeNum, _galaxyName, _mannerTime))
    );

    showAnimatedDialog(
      animationType: DialogTransitionType.slideFromBottom,
      barrierColor: Colors.black.withOpacity(0.2),
      barrierDismissible: true,
      duration: Duration(seconds: 1),
      context: context,
      builder: (BuildContext context) {
        return dialog;
      }
    );
  }

  void _showResult(BuildContext context, String message) {
    AlertDialog dialog = new AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.9)
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.1653),
      content: AspectRatio(
        aspectRatio: 251/164,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
              children: <Widget>[
                Spacer(),
                Icon(Icons.error_rounded, color: mainColor, size: constraint.maxWidth * 0.3027,),
                Spacer(),
                Text(message, style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
                Spacer(),
              ],
            );
          },
        ),
      ),
    );

    showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      builder: (BuildContext context) {
        return dialog;
    });

  }

  Future<dynamic> _auth(String code) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    AuthStatus authStatus = Provider.of<AuthStatus>(context, listen: false);
    int bookInfo = sp.getInt("bookInfo");
    int status = authStatus.getStatus();
    String userEmail = sp.getString("email");
    String placeCode = code.substring(code.length - 4, code.length);
    String hashCode = code.substring(0, code.length - 4);
    print("bookInfo $bookInfo");
    var url = Uri.parse("$speckUrl/certify/auth");
    String body = '''{
       "status" : $status,
       "placeCode" : "$placeCode",
       "hashCode" : "$hashCode",
       "userEmail" : "$userEmail",
       "bookInfo" : $bookInfo
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("scan result $result");
    return Future(() {
      return result;
    });
  }


}
