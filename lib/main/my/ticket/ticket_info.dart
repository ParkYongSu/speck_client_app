import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/main/my/ticket/ticket_ui.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
class TicketInfo extends StatefulWidget {
  final String placeName;
  final int attCount;
  final int totalCount;
  final int attRate;
  final int totalDeposit;
  final int myDeposit;
  final int totalDust;
  final int accumPrize;
  final int estimatePrize;
  final String attendTime;
  final int timeNum;
  final String galaxyName;
  final int mannerTime;
  const TicketInfo({Key key, this.placeName, this.attCount, this.totalCount, this.attRate, this.totalDeposit,
    this.myDeposit, this.totalDust, this.accumPrize, this.estimatePrize, this.attendTime, this.timeNum, this.galaxyName, this.mannerTime}) : super(key: key);


  @override
  State createState() {
    return TicketInfoState();
  }
}

class TicketInfoState extends State<TicketInfo> {
  final UICriteria _uiCriteria = new UICriteria();
  Uint8List _image;
  final ScreenshotController _screenShotController = new ScreenshotController();


  @override
  Widget build(BuildContext context) {
    return _ticketPage(context);
  }

  Widget _ticketPage(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
      title: "티켓 정보",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: greyF0F0F1,
        appBar: appBar(context, "나의 티켓"),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding, top: _uiCriteria.totalHeight * 0.0344),
                      child: Screenshot(
                          controller: _screenShotController,
                          child: ticket(context, widget.placeName, widget.attCount, widget.totalCount, widget.attRate, widget.totalDeposit,
                              widget.myDeposit, widget.totalDust, widget.accumPrize, widget.estimatePrize, widget.attendTime, widget.timeNum, widget.galaxyName, widget.mannerTime)
                      )
                  ),
                  _hill()
                ],
              ),
            ),
            _storeButton(context)
          ],
        ),
      ),
    );
  }

  Widget _hill() {
    return AspectRatio(
      aspectRatio: 375/92,
    );
  }

  Widget _storeButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
      margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.039),
      child: AspectRatio(
        aspectRatio: 343/50,
        child:  MaterialButton(
          onPressed: () {
            _save();
          },
          elevation: 0,
          color: mainColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.5)
          ),
          child: Text("갤러리에 저장하기", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),),
        ),
      ),
    );
  }

  void _save() async {
    if (Platform.isAndroid) {
      _androidSave();
    }
    else if (Platform.isIOS) {
      _iosSave();
    }
  }

  void _iosSave() async {
    try {
      await _screenShotController.capture(
          pixelRatio: 1.5
      ).then((Uint8List image) async {
        setState(() {
          _image = image;
        });
        var status = await Permission.photos.status;
        print("status ${await Permission.photos.status}");
        if (status.isGranted) {
          print("결과 ${ await ImageGallerySaver.saveImage(_image, quality: 100)}");
          _toast("저장되었습니다.");
        }
        else {
          print("권한 설정안함");
          await Permission.photos.request();
        }
      }).catchError((e) {print(e);});
    }
    catch (e) {
      print(e);
      _toast("실패하였습니다.");
    }
  }

  void _androidSave() async {
    try {
      await _screenShotController.capture(
          pixelRatio: 1.5
      ).then((Uint8List image) async {
        setState(() {
          _image = image;
        });
        var status = await Permission.storage.status;
        print("status ${await Permission.storage.status}");
        if (status.isGranted) {
          print("결과 ${ await ImageGallerySaver.saveImage(_image, quality: 100)}");
          _toast("저장되었습니다.");
        }
        else {
          print("권한 설정안함");
          await Permission.storage.request();
        }
      }).catchError((e) {print(e);});
    }
    catch (e) {
      print(e);
      _toast("실패하였습니다.");
    }
  }

  void _toast(String title) {
    Fluttertoast.showToast(
        gravity: ToastGravity.CENTER,
        backgroundColor: mainColor,
        msg: title,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: _uiCriteria.textSize3,
    );
  }
}

