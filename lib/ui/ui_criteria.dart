import 'dart:io';

import 'package:flutter/material.dart';

class UICriteria {
  double screenWidth; // 화면 너비
  double screenHeight; // 상태바, 네비바 제 높이
  double statusBarHeight; // 상태바 높이
  double naviHeight; // 네비바 높이
  double totalHeight; // 화면 높이
  double textSize16; // 제목1 텍스트 등 16
  double textSize2; // 제목2 텍스트 등 14
  double textSize3; // 세부정보 텍스트 사이즈 12
  double textSize4; // 18
  double textSize5; // 10
  double textSize6; // 20
  double textSize7;
  double textSize15;
  double textSize24;
  double textSize17;
  double textSize11;
  double textSize21;

  double horizontalPadding; // 가로 방향 패딩
  double verticalPadding; // 세로 방향 패
  double appBarHeight; // 앱바 높이
  double calendarMarkerSize;

  void init(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    this.totalHeight = height;
    this.statusBarHeight = MediaQuery.of(context).padding.top;
    this.naviHeight = MediaQuery.of(context).padding.bottom;
    this.screenWidth = width;
    this.screenHeight = height - this.statusBarHeight - this.naviHeight;

    if (Platform.isAndroid) {
      this.textSize16 = height * 0.0197;
      this.textSize2 = height * 0.0172;
      this.textSize3 =  height * 0.0147;
      this.textSize4 =  height * 0.0222;
      this.textSize5 =  height * 0.0123;
      this.textSize6 = height * 0.0246;
      this.textSize7 = height * 0.0098;
      this.textSize15 = height * 0.0185;
      this.textSize24 = height * 0.02956;
      this.textSize17 = height * 0.0209;
      this.textSize11 = height * 0.0135;
      this.textSize21 = height * 0.0259;
      this.calendarMarkerSize = height * 0.0061;
    }
    else if (Platform.isIOS){
      this.textSize16 = width * 0.04266;
      this.textSize2 = width * 0.03733;
      this.textSize3 = width * 0.032;
      this.textSize4 = width * 0.048;
      this.textSize5 = width * 0.0266;
      this.textSize6 = width * 0.05333;
      this.textSize7 = width * 0.0213;
      this.textSize15 = width * 0.04;
      this.textSize24 = width * 0.064;
      this.textSize17 = width * 0.0453;
      this.textSize11 = width * 0.0293;
      this.textSize21 = width * 0.056;
      this.calendarMarkerSize = width * 0.0133;
    }

    this.horizontalPadding = width * 0.043;
    this.verticalPadding = height * 0.0283;
    this.appBarHeight = height * 0.067;
    // this.letterSpacing08 = width * 0.0021;
  }
}