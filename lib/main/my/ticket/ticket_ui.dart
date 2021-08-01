import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/main/my/my_background.dart';
import 'package:speck_app/main/my/ticket/ticket_background.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';

Widget ticket(BuildContext context, String placeName, int attCount, int totalCount, int attRate,
    int totalDeposit, int myDeposit, int totalDust, int accumPrize, int estimatePrize, String attendTime, int timeNum, String galaxyName, int mannerTime) {
  return AspectRatio(
    aspectRatio: 343/578,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
        return Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(left: constraint.maxWidth * 0.0175, right: constraint.maxWidth * 0.0175, top: constraint.maxWidth * 0.0175),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), spreadRadius: 0, blurRadius: 12, offset: Offset(0, 3))]
          ),
          child: Stack (
            alignment: Alignment.topRight,
            children: [
              Container(
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                child: AspectRatio(
                    aspectRatio: 343/274,
                    child:
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraint) {
                            return CustomPaint(
                              painter: TicketBackground(),
                              size: Size(constraint.maxWidth, constraint.maxHeight),
                            );
                          },
                        ),
                        Image.asset("assets/png/ticket_stars.png", fit: BoxFit.fill,)
                      ],
                    )
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.black)
                  //   ),
                  // ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: constraint.maxHeight * 0.2093),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11.9),
                ),
                child: Container(
                  width: double.infinity,
                  height: constraint.maxHeight * 0.7802,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ticketTitle(context, constraint, galaxyName, timeNum),
                      ticketContent(context, constraint, placeName, attCount, totalCount, attRate,
                          totalDeposit, myDeposit, totalDust, accumPrize, estimatePrize, mannerTime),
                      ticketPass(context, constraint)
                    ],
                  ),
                ),
              ),
              attendTimePlanet(constraint, attendTime)
            ],
          ),
        );
      },
    ),
  );
}

Widget ticketTitle(BuildContext context, BoxConstraints constraint, String galaxyName, int timeNum) {
  return Container(
    margin: EdgeInsets.only(bottom: constraint.maxHeight * 0.0847, left: constraint.maxWidth * 0.0524),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("[공식] $galaxyName", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize2),),
        SizedBox(height: constraint.maxHeight * 0.0069,),
        Text("${getAuthTime(timeNum)} 탐험단", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize2),),
      ],
    ),
  );
}

Widget ticketContent(BuildContext context, BoxConstraints constraint, String placeName, int attCount, int totalCount, int attRate,
    int totalDeposit, int myDeposit, int totalDust, int accumPrize, int estimatePrize, int mt) {
  return Container(
    padding: EdgeInsets.only(left: constraint.maxWidth * 0.0524,),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                place(context, constraint, placeName),
                SizedBox(height: constraint.maxHeight * 0.038,),
                attendance(context, constraint, attCount, totalCount, attRate),
                SizedBox(height: constraint.maxHeight * 0.038,),
                myDepositInfo(context, constraint, totalDeposit, myDeposit)
              ],
            ),
            SizedBox(width: constraint.maxWidth * 0.06413,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("*"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    mannerTime(context, constraint, mt), /// todo. 매너시간 추가
                    SizedBox(height: constraint.maxHeight * 0.038,),
                    myDust(context, constraint, totalDust),
                    SizedBox(height: constraint.maxHeight * 0.038,),
                    myBenefit(context, constraint, accumPrize, estimatePrize)
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: constraint.maxHeight * 0.038,),
        mannerTimeNotice(context, constraint),
        SizedBox(height: constraint.maxHeight * 0.038,),
      ],
    ),
  );
}

Widget ticketPass(BuildContext context, BoxConstraints constraint) {
  return Expanded(
    child: Column(
      children: <Widget>[
        dashLine(constraint),
        Spacer(),
        barcode(constraint),
        Spacer(),
      ],
    ),
  );
}

Widget place(BuildContext context, BoxConstraints constraint, String placeName) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("장소", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
      SizedBox(height: constraint.maxHeight * 0.0069,),
      Text("$placeName", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
    ],
  );
}

Widget attendance(BuildContext context, BoxConstraints constraint, int attendCount, int totalCount, int attRate) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("출석 횟수", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
      SizedBox(height: constraint.maxHeight * 0.0069,),
      Row(
        children: [
          Text("$attendCount회 ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
          Text("/$totalCount회($attRate%)", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize5, letterSpacing: 0.5),),
        ],
      ),
    ],
  );
}

Widget myDepositInfo(BuildContext context, BoxConstraints constraint, int totalDeposit, int myDeposit) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("나의 보증금", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
      SizedBox(height: constraint.maxHeight * 0.0069,),
      Row(
        children: [
          Text("${myDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3),),
          Text("/${totalDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize5),),
        ],
      ),
    ],
  );
}

Widget mannerTime(BuildContext context, BoxConstraints constraint, int mannerTime) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("매너 시간", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
      SizedBox(height: constraint.maxHeight * 0.0069,),
      Text((mannerTime == 0)?"없음":(mannerTime == -1)?"없음(카페 한정)":"$mannerTime시간", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
    ],
  );
}

Widget myDust(BuildContext context, BoxConstraints constraint, int totalDust, ) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("나의 더스트", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
      SizedBox(height: constraint.maxHeight * 0.0069,),
      Row(
        children: [
          Text("${totalDust}D ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
          Text("+10D", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize5, letterSpacing: 0.5),),
        ],
      ),
    ],
  );
}

Widget myBenefit(BuildContext context, BoxConstraints constraint, int accumPrize, int estimatePrize) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("나의 상금", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3, letterSpacing: 0.6),),
      SizedBox(height: constraint.maxHeight * 0.0069,),
      Row(
        children: [
          Text("${accumPrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3),),
          Text("+(예상)0~${estimatePrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize5),),
        ],
      ),
    ],
  );
}

Widget mannerTimeNotice(BuildContext context, BoxConstraints constraint) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("* 매너 시간이 지나면 음료를 재주문하거나 만석 시 자리를 양보해 주세요.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5,fontSize: uiCriteria.textSize5),),
        SizedBox(height: constraint.maxHeight * 0.0069,),
        Row(
          children: [
            Text("*", style: TextStyle(color: Colors.transparent, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: uiCriteria.textSize5),),
            Text(" 우리 같이 올바른 카공족 문화를 만들어보아요 :)", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: uiCriteria.textSize5),),
          ],
        ),
      ],
    ),
  );
}

Widget dashLine(BoxConstraints constraint) {
  return Row(
    children: List.generate(11, (index) {
        return Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Container(
              color: greyD8D8D8,
              width: constraint.maxWidth * 0.0349,
              height: 1,
            ),
          ),
        );
      }
    ),
  );
}

Widget barcode(BoxConstraints constraint) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0408),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.asset("assets/png/barcode.png"),
        Row(
          children: <Widget>[
            Image.asset("assets/png/logo_ticket.png"),
            SizedBox(width: constraint.maxWidth * 0.0163,),
            RotatedBox(
              child: Text("더스트 채굴 허가증", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.38, fontSize: uiCriteria.textSize3),),
              quarterTurns: 3)
          ],
        )
      ],
    ),
  );
}

Widget attendTimePlanet(BoxConstraints constraint, String attendTime) {
  DateTime dt = DateTime.parse(attendTime);
  String at = "${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}";
  return Container(
    margin: EdgeInsets.only(top: constraint.maxHeight * 0.18),
    child: Transform.rotate(
      angle: -0.35  ,
      child: Container(
        width: constraint.maxWidth * 0.3282,
        height: constraint.maxWidth * 0.3282,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))],
            image: DecorationImage(
                image: AssetImage("assets/png/ticket_planet.png")
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("출석 시간", style: TextStyle(color: mainColor, letterSpacing: 0.45, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize7),),
            SizedBox(height: constraint.maxHeight * 0.0069,),
            Text("$at", style: TextStyle(color: mainColor, letterSpacing: 0.65, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3),),
          ],
        ),
      ),
    ),
  );
}
