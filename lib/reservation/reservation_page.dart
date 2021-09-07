import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/reservation/calendar_members.dart';
import 'package:speck_app/reservation/reservation_complete.dart';
import 'package:speck_app/reservation/check_event.dart';
import 'package:speck_app/reservation/reservation_util.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:table_calendar/table_calendar.dart';

class Reservation extends StatefulWidget {
  final String galaxyName; // 학교이름
  final String imagePath; // 프로필
  final int galaxyNum; // 학교아이디
  final int timeNum;
  final int official;

  Reservation(
      {Key key,
      @required this.galaxyName,
      @required this.imagePath,
      @required this.galaxyNum,
      @required this.timeNum,
      @required this.official})
      : super(key: key);

  @override
  State createState() {
    return _ReservationState();
  }
}

class _ReservationState extends State<Reservation> {
  final UICriteria _uiCriteria = new UICriteria();
  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: _uiCriteria.appBarHeight,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        backwardsCompatibility: false,
        automaticallyImplyLeading: false,
        // brightness: Brightness.dark,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
        title: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.008),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                        child: Icon(Icons.chevron_left_rounded,
                            color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                        onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Text("예약하기",
                  style: TextStyle(
                    letterSpacing: 0.8,
                    fontSize: _uiCriteria.textSize16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )
              ),
            ]
        ),
        backgroundColor: mainColor,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: _reservationData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _setReservationData(snapshot.data);
              return _reservationPage();
            }
            else {
              return loader(context, 0);
            }
          }
      ),
    );
  }

  Widget _reservationPage() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  AspectRatio(
                      aspectRatio: 375/11.8,
                      child: Container(
                        decoration: BoxDecoration(
                            color: greyF0F0F1
                        ),
                      )
                  ),
                  AspectRatio(
                    aspectRatio: 375/40,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                      child: Text(
                        "갤럭시 정보",
                        style: TextStyle(
                            letterSpacing: 0.7,
                            color: mainColor,
                            fontSize: _uiCriteria.textSize2,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  AspectRatio(
                      aspectRatio: 375/120.8,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraint) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: greyD8D8D8, width: 0.5))
                            ),
                            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.1986),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: constraint.maxHeight * 0.6043,
                                  height: constraint.maxHeight * 0.6043,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.9),
                                      border: Border.all(color: greyD8D8D8, width: 0.5),
                                      image: DecorationImage(
                                          fit: BoxFit.fitHeight,
                                          image: NetworkImage(widget.imagePath)
                                      )
                                  ),
                                ),
                                SizedBox(width: constraint.maxWidth * 0.0426,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      (widget.official == 1)
                                          ? "[공식] ${widget.galaxyName}($_time)"
                                          : "${widget.galaxyName}($_time)",
                                      style: TextStyle(
                                          letterSpacing: 0.24,
                                          color: mainColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: _uiCriteria.textSize3),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/png/dust_profile.png",
                                                        height: _uiCriteria.textSize3,
                                                      ),
                                                      Text(
                                                        "  누적 출석인원",
                                                        style:
                                                        TextStyle(
                                                            letterSpacing: 0.2, color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: constraint.maxHeight * 0.037),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                          "assets/png/dust_won.png",
                                                          height: _uiCriteria.textSize3
                                                      ),
                                                      Text("  누적 보증금",
                                                          style: TextStyle(letterSpacing: 0.2, color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(width: constraint.maxWidth * 0.0293,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${_accumAtt.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명",
                                                    style: TextStyle(
                                                        letterSpacing: 0.2,
                                                        color: mainColor,
                                                        fontSize: _uiCriteria.textSize5,
                                                        fontWeight: FontWeight.w700),
                                                  ),
                                                  SizedBox(height: constraint.maxHeight * 0.037),
                                                  Text(
                                                    "${_accumDeposit.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                                                    style: TextStyle(
                                                        letterSpacing: 0.2,
                                                        color: mainColor,
                                                        fontWeight:
                                                        FontWeight.w700,
                                                        fontSize: _uiCriteria.textSize5),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: constraint.maxWidth * 0.0293,),
                                            ],
                                          ),
                                          SizedBox(height: constraint.maxHeight * 0.037),
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/png/dust_won.png",
                                                height: _uiCriteria.textSize3, color: Colors.transparent,
                                              ),
                                              Text(
                                                "  평균적으로 하루에 ${_avgDeposit.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원을 걸었어요",
                                                style: TextStyle(
                                                    letterSpacing: 0.2,
                                                    color: greyAAAAAA,
                                                    fontSize: _uiCriteria.textSize5,
                                                    fontWeight:
                                                    FontWeight.w500),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      )
                  ),
                  AspectRatio(
                      aspectRatio: 375/52,
                      child: Container(
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: greyD8D8D8 ,width: 0.5))
                        ),
                        child: AspectRatio(
                          aspectRatio: 375/42,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: greyF5F5F6),
                            child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.textSize2),
                                  children: <TextSpan>[
                                    TextSpan(text: "인증 가능한 시간은 "),
                                    TextSpan(
                                        text: _canAuthTime,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    TextSpan(text: " 입니다.")
                                  ]),
                            ),
                          ),
                        ),
                      )
                  ),
                  AspectRatio(
                      aspectRatio: 375/11.8,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0XFFF0F0F1)
                        ),
                      )
                  ),
                  AspectRatio(
                    aspectRatio: 375/40,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                      child: Text("날짜 선택", style: TextStyle(letterSpacing: 0.7,color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  AspectRatio(
                      aspectRatio: 375/83.8,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraint) {
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: greyD8D8D8, width: 0.5))),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("시작 날짜",
                                                style: TextStyle(
                                                    letterSpacing: 0.5,
                                                    fontSize: _uiCriteria.textSize5,
                                                    color: greyD8D8D8,
                                                    fontWeight: FontWeight.w500
                                                )),
                                            Text("종료 날짜",
                                                style: TextStyle(
                                                    letterSpacing: 0.5,
                                                    fontSize: _uiCriteria.textSize5,
                                                    color: greyD8D8D8,
                                                    fontWeight: FontWeight.w500
                                                ))
                                          ]),
                                      SizedBox(height: constraint.maxHeight * 0.0718,),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              "$_startDate",
                                              style: TextStyle(
                                                  letterSpacing: 0.8,
                                                  fontSize: _uiCriteria.textSize16,
                                                  color: (_isStartSelected)?mainColor:greyAAAAAA,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              "$_endDate",
                                              style: TextStyle(
                                                  letterSpacing: 0.8,
                                                  fontSize: _uiCriteria.textSize16,
                                                  color: (_isEndSelected)?mainColor:greyAAAAAA,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ])
                                    ]),
                              ),
                              Container(
                                  margin: EdgeInsets.only(bottom: constraint.maxHeight * 0.3914),
                                  child: Image.asset("assets/png/arrow_right.png", width: constraint.maxWidth * 0.0768,)),
                            ],
                          );
                        },
                      )
                  ),
                  AspectRatio(
                    aspectRatio: 375/11.8,
                    child: Container(
                        decoration: BoxDecoration(
                            color: greyF0F0F1
                        )
                    ),
                  ),
                  AspectRatio(
                      aspectRatio: 375/72,
                      child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraint) {
                            return Container(
                              alignment: Alignment.center,
                              child: FlutterToggleTab(
                                width: constraint.maxWidth * 0.1,
                                height: constraint.maxHeight * 0.3472,
                                selectedBackgroundColors: [mainColor],
                                unSelectedBackgroundColors: [greyD8D8D8],
                                borderRadius: 96,
                                isScroll: false,
                                initialIndex: _selectedIndex,
                                labels: ["기간 선택", "개별 선택"],
                                unSelectedTextStyle: TextStyle(letterSpacing: 0.6,color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),
                                selectedLabelIndex: (int index) {
                                  setState(() {
                                    if (!(_selectedIndex == index))  { // 현재 선택모드와 다른 것을 선택했을
                                      _cnt = 0;
                                      _isStartSelected = false;
                                      _isEndSelected = false;
                                      _startDate = "미선택";
                                      _endDate = "미선택";
                                      _selectedIndex = index;
                                      _isDateSelected = false;
                                      if (index == 0) { // 범위 선택
                                        _rangeSelectionMode = RangeSelectionMode.toggledOn;
                                        _selectedDays.clear();
                                      }
                                      else { // 개별 선택시
                                        _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                        _rangeStartDay = null; // Important to clean those
                                        _rangeEndDay = null;
                                        _isRangeSelected = false;
                                        _setCheckDayFalse();
                                      }
                                    }
                                  });
                                },
                                selectedTextStyle: TextStyle(letterSpacing: 0.6,color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                      )
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical:  _uiCriteria.totalHeight * 0.0295),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      child: _getReservationCalendar(context, _reservationList)
                  ),
                  (_rangeSelectionMode == RangeSelectionMode.toggledOn)
                      ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 375/11.8,
                        child: Container(
                            decoration: BoxDecoration(
                                color: greyF0F0F1
                            )
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 375/40,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: greyD8D8D8, width: 0.5))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "요일 선택",
                                style: TextStyle(
                                    letterSpacing: 0.7,
                                    color: mainColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: _uiCriteria.textSize2),
                              ),
                              RichText(
                                text: TextSpan(
                                    style: TextStyle(letterSpacing: 0.7,color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),
                                    children: <TextSpan>[
                                      TextSpan(text: "총 "),
                                      TextSpan(text: "$_cnt", style: TextStyle(color: Color(0XFFE7535C))),
                                      TextSpan(text: "일"),
                                    ]
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 375/103.8,
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraint) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.2312),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: greyD8D8D8, width: 0.5))),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if(_isRangeSelected) {
                                                if (!((_diff <= 7) && (_rangeStartDay.weekday == 1 || (_rangeEndDay.weekday == 1))) && _weekdays.contains(1)) {
                                                  _monChecked = !_monChecked;
                                                  if (_monChecked) {
                                                    _weekendChecked = false;
                                                    _sumDay += 1;
                                                  }
                                                  else {
                                                    _sumDay -= 1;
                                                  }
                                                  _calCNT(_rangeDays, _monChecked, [1]);
                                                }
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.transparent)
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: _monChecked
                                                      ? mainColor
                                                      : greyD8D8D8,
                                                  size: _uiCriteria.textSize4,
                                                ),
                                                Text("  월요일",
                                                    style: TextStyle(
                                                        letterSpacing: 0.6,
                                                        color: greyD8D8D8,
                                                        fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500))
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if(_isRangeSelected) {
                                                  if (!((_diff <= 7) && (_rangeStartDay.weekday == 2 || (_rangeEndDay.weekday == 2))) && _weekdays.contains(2)) {
                                                    _tueChecked = !_tueChecked;
                                                    if (_tueChecked) {
                                                      _weekendChecked = false;
                                                      _sumDay += 2;
                                                    }
                                                    else {
                                                      _sumDay -= 2;
                                                    }
                                                    _calCNT(_rangeDays, _tueChecked, [2]);
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: _tueChecked
                                                          ? mainColor
                                                          : greyD8D8D8,
                                                      size: _uiCriteria.textSize4,
                                                    ),
                                                    Text("  화요일",
                                                        style: TextStyle(letterSpacing: 0.6,color: greyD8D8D8, fontSize: _uiCriteria.textSize3))
                                                  ]
                                              ),
                                            ))
                                        ,
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if(_isRangeSelected) {
                                                  if (!((_diff <= 7) && (_rangeStartDay.weekday == 3 || (_rangeEndDay.weekday == 3))) && _weekdays.contains(3)) {
                                                    _wedChecked = !_wedChecked;
                                                    if (_wedChecked) {
                                                      _weekendChecked = false;
                                                      _sumDay += 4;
                                                    }
                                                    else {
                                                      _sumDay -= 4;
                                                    }
                                                    _calCNT(_rangeDays, _wedChecked, [3]);
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _wedChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  수요일",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))
                                                ],
                                              ),
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if(_isRangeSelected) {
                                                  if (!((_diff <= 7) && (_rangeStartDay.weekday == 4 || (_rangeEndDay.weekday == 4))) && _weekdays.contains(4)) {
                                                    _thuChecked = !_thuChecked;
                                                    if (_thuChecked) {
                                                      _weekendChecked = false;
                                                      _sumDay += 8;
                                                    }
                                                    else {
                                                      _sumDay -= 8;
                                                    }
                                                    _calCNT(_rangeDays, _thuChecked, [4]);
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _thuChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  목요일",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))
                                                ],
                                              ),
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if(_isRangeSelected) {
                                                  if (!((_diff <= 7) && (_rangeStartDay.weekday == 5 || (_rangeEndDay.weekday == 5))) && _weekdays.contains(5)) {
                                                    _friChecked = !_friChecked;
                                                    if (_friChecked) {
                                                      _weekendChecked = false;
                                                      _sumDay += 16;
                                                    }
                                                    else {
                                                      _sumDay -= 16;
                                                    }
                                                    _calCNT(_rangeDays, _friChecked, [5]);
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _friChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  금요일",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))

                                                ],
                                              ),
                                            )),

                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if(_isRangeSelected) {
                                                  if (!((_diff <= 7) && (_rangeStartDay.weekday == 6 || (_rangeEndDay.weekday == 6))) && _weekdays.contains(6)) {
                                                    _satChecked = !_satChecked;
                                                    if (_satChecked) {
                                                      _weekdayChecked = false;
                                                      _sumDay += 32;
                                                    }
                                                    else {
                                                      _sumDay -= 32;
                                                    }
                                                    _calCNT(_rangeDays, _satChecked, [6]);
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _satChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  토요일",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))
                                                ],
                                              ),
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if(_isRangeSelected) {
                                                  if (!((_diff <= 7) && (_rangeStartDay.weekday == 7 || (_rangeEndDay.weekday == 7))) && _weekdays.contains(7)) {
                                                    _sunChecked = !_sunChecked;
                                                    if (_sunChecked) {
                                                      _weekdayChecked = false;
                                                      _sumDay += 64;
                                                    }
                                                    else {
                                                      _sumDay -= 64;
                                                    }
                                                    _calCNT(_rangeDays, _sunChecked, [7]);
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _sunChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  일요일",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))
                                                ],
                                              ),
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_isRangeSelected &&
                                                    !( _rangeStartDay.weekday == 6 || _rangeEndDay.weekday == 6
                                                        ||  _rangeStartDay.weekday == 7 || _rangeEndDay.weekday == 7) &&
                                                    (_weekdays.contains(6) || _weekdays.contains(7))) {
                                                  _weekdayChecked = !_weekdayChecked;
                                                  if (_weekdayChecked) {
                                                    _satChecked = false;
                                                    _sunChecked = false;
                                                  }
                                                  else {
                                                    _satChecked = true;
                                                    _sunChecked = true;
                                                  }
                                                  _calCNT(_rangeDays, !_weekdayChecked, [6, 7]);
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _weekdayChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  평일만",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))
                                                ],
                                              ),
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_isRangeSelected && !(_rangeStartDay.weekday == 1 || _rangeEndDay.weekday == 1 ||
                                                    _rangeStartDay.weekday == 2 || _rangeEndDay.weekday == 2 ||
                                                    _rangeStartDay.weekday == 3 || _rangeEndDay.weekday == 3 ||
                                                    _rangeStartDay.weekday == 4 || _rangeEndDay.weekday == 4 ||
                                                    _rangeStartDay.weekday == 5 || _rangeEndDay.weekday == 5) &&
                                                    (_weekdays.contains(1) || _weekdays.contains(2) || _weekdays.contains(3) || _weekdays.contains(4) || _weekdays.contains(5))) {
                                                  _weekendChecked = !_weekendChecked;
                                                  if (_weekendChecked) {
                                                    _monChecked = false;
                                                    _tueChecked = false;
                                                    _wedChecked = false;
                                                    _thuChecked = false;
                                                    _friChecked = false;
                                                  }
                                                  else {
                                                    _monChecked = true;
                                                    _tueChecked = true;
                                                    _wedChecked = true;
                                                    _thuChecked = true;
                                                    _friChecked = true;
                                                  }
                                                  _calCNT(_rangeDays, !_weekendChecked, [1, 2, 3, 4, 5]);
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: _weekendChecked
                                                        ? mainColor
                                                        : greyD8D8D8,
                                                    size: _uiCriteria.textSize4,
                                                  ),
                                                  Text("  주말만",
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          color: greyD8D8D8,
                                                          fontSize: _uiCriteria.textSize3))
                                                ],
                                              ),
                                            )),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.transparent)
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.transparent,
                                                size: _uiCriteria.textSize4,
                                              ),
                                              Text("  공휴일",
                                                  style: TextStyle(
                                                      letterSpacing: 0.6,
                                                      color: Colors.transparent,
                                                      fontSize: _uiCriteria.textSize3))
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                      : Container(),
                  AspectRatio(
                    aspectRatio: 375/11.8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: greyF0F0F1
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/40,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: greyD8D8D8, width: 0.5))),
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("보증금",
                                style: TextStyle(
                                    letterSpacing: 0.7,
                                    color: mainColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: _uiCriteria.textSize2)),
                            GestureDetector(
                                child: Row(
                                  children: [
                                    Text("상금제도 ",
                                        style: TextStyle(
                                            letterSpacing: 0.6,
                                            color: greyAAAAAA,
                                            fontWeight: FontWeight.w700,
                                            fontSize: _uiCriteria.textSize2)),
                                    Image.asset("assets/png/question_mark.png", height: _uiCriteria.textSize16,)
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _moneySystemClicked = !_moneySystemClicked;
                                  });
                                }
                            ),
                          ],
                        )),
                  ),
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 375/87.8,
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraint) {
                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("나의 하루를 불타게 해주는",
                                      style: TextStyle(
                                          letterSpacing: 0.7,
                                          color: mainColor,
                                          fontSize: _uiCriteria.textSize2,
                                          fontWeight: FontWeight.w700)),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: constraint.maxWidth * 0.384,
                                          height: constraint.maxHeight * 0.4555,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10.0)),
                                          child: TextField(
                                            onChanged: (String value) {
                                              _onChanged(value);
                                            },
                                            controller: _paymentController,
                                            textDirection: TextDirection.rtl,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: "20,000 ~ 1,000",
                                              hintStyle: TextStyle(
                                                  letterSpacing: 0.7,
                                                  color: greyB3B3BC,
                                                  fontSize: _uiCriteria.textSize2,
                                                  height: 1.15
                                              ),
                                              hintTextDirection:
                                              TextDirection.rtl,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: greyB3B3BC,
                                                      width: 0.5)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: greyB3B3BC,
                                                      width: 0.5)),
                                            ),
                                            cursorColor: mainColor,
                                          ),
                                        ),
                                        Text("  원",
                                            style: TextStyle(
                                                letterSpacing: 0.7,
                                                color: mainColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: _uiCriteria.textSize2))
                                      ])
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      (_moneySystemClicked)
                          ? Padding(
                            padding: EdgeInsets.only(right: _uiCriteria.horizontalPadding),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SpeechBubble(
                              borderRadius: 3.5,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text("미출석자들의 보증금에서 스펙 수수료(50%)를 제외한",style: TextStyle(letterSpacing: 0.5, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700, color: Colors.white),),
                                        SizedBox(height: _uiCriteria.totalHeight * 0.006,),
                                        Text("나머지 금액을 출석자들에게 보증금 비율에 맞게 분배",style: TextStyle(letterSpacing: 0.5,fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700, color: Colors.white),),
                                        SizedBox(height: _uiCriteria.totalHeight * 0.006,),
                                        Text("(하루 보증금이 클수록, 받는 상금도 커져요)",style: TextStyle(letterSpacing: 0.5,fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700, color: Colors.white),),
                                      ]
                                  ),
                                ],
                              ),
                        color: greyD8D8D8,
                        // nipHeight: constraint.maxHeight * 0.0911,
                        nipLocation: NipLocation.TOP_RIGHT,
                      ),
                            ),
                          )
                          : Container(),
                    ],
                  ),
                  AspectRatio(
                    aspectRatio: 375/269,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraint) {
                        return Container(
                            decoration: BoxDecoration(
                                color: greyF5F5F6,
                                border: Border(
                                    bottom: BorderSide(
                                        color: greyD8D8D8.withOpacity(0.5), width: 0.5))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Spacer(flex: 23,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.096),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/png/dust_won_fill.png",
                                          height: _uiCriteria.textSize16,
                                        ),
                                        Text(
                                          "상금 계산은 하루를 기준으로 이루어져요!",
                                          style: TextStyle(
                                              letterSpacing: 0.7,
                                              color: mainColor,
                                              fontSize: _uiCriteria.textSize2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Image.asset(
                                          "assets/png/dust_won_fill.png",
                                          height: _uiCriteria.textSize16,
                                        ),
                                      ]),
                                ),
                                Spacer(flex: 36,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Spacer(flex: 576,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Image.asset("assets/png/arrow_up_draw.png", width: constraint.maxWidth * 0.0661, height: constraint.maxHeight * 0.1379, fit: BoxFit.fill,),
                                        SizedBox(width: constraint.maxWidth * 0.0061,),
                                        Image.asset("assets/png/arrow_up_draw.png", width: constraint.maxWidth * 0.0461, height: constraint.maxHeight * 0.0966, fit: BoxFit.fill,),
                                      ],
                                    ),
                                    Spacer(flex: 269,),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0405, vertical: constraint.maxHeight * 0.0542),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(40)
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset("assets/png/dust_won_fill.png", width: constraint.maxWidth * 0.0938, height: constraint.maxWidth * 0.0938, fit: BoxFit.fill,),
                                          SizedBox(width: constraint.maxWidth * 0.0293),
                                          Image.asset("assets/png/circuit_draw.png", width: constraint.maxWidth * 0.0698, height: constraint.maxWidth * 0.0698, fit: BoxFit.fill,),
                                          SizedBox(width: constraint.maxWidth * 0.0293),
                                          Image.asset("assets/png/dust_money.png", width: constraint.maxWidth * 0.0938, height: constraint.maxWidth * 0.0938, fit: BoxFit.fill,)
                                        ],
                                      ),
                                    ),
                                    Spacer(flex: 269,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Image.asset("assets/png/arrow_up_draw.png", color: Color(0XFFFCCF97), width: constraint.maxWidth * 0.0461, height: constraint.maxHeight * 0.0966, fit: BoxFit.fill),
                                        SizedBox(width: constraint.maxWidth * 0.0061,),
                                        Image.asset("assets/png/arrow_up_draw.png", color: Color(0XFFFCCF97), width: constraint.maxWidth * 0.0661, height: constraint.maxHeight * 0.1379, fit: BoxFit.fill,),
                                      ],
                                    ),
                                    Spacer(flex: 576,),
                                  ],
                                ),
                                Spacer(flex: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("상금을 보증금 비율에 맞게 분배하기 때문에,",
                                      style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5,),),
                                    Text(" 보증금이 클수록 상금도 커져요!",
                                      style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5,
                                        decoration: TextDecoration.lineThrough, decorationColor: Color(0XFFfcf3b2).withOpacity(0.3),
                                        decorationStyle: TextDecorationStyle.solid, decorationThickness: _uiCriteria.textSize6
                                      ),),

                                  ],
                                ),
                                Spacer(flex: 23,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text("출석 성공",style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3)),
                                          SizedBox(width: constraint.maxWidth * 0.032,),
                                          Text("보증금 페이백 + 상금",style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3))
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text("출석 성공" ,style: TextStyle(color: Colors.transparent, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),),
                                          SizedBox(width: constraint.maxWidth * 0.032,),
                                          Text("보증금은 일정 마지막 날 한 번에 지급되고, 상금은 매일 지급돼요.",
                                            style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5),),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Spacer(flex: 11,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("출석 실패",style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3)),
                                      SizedBox(width: constraint.maxWidth * 0.032,),
                                      Text("출석을 실패한 날의 보증금은 상금으로 들어가요.",style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3))
                                    ],
                                  ),
                                ),
                                Spacer(flex: 23,),
                              ],
                            ));
                      },
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/11.8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/11.8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: greyF0F0F1
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/40,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),

                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: greyD8D8D8, width: 0.5))),
                      child: Text("결제 정보",
                          style: TextStyle(
                              letterSpacing: 0.7,
                              fontSize: _uiCriteria.textSize2,
                              fontWeight: FontWeight.w700,
                              color: mainColor)),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/139.8,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraint) {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                          ),
                          child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 858,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.1631),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text("예약 기간",
                                                    style: TextStyle(
                                                        letterSpacing: 0.6,
                                                        color: greyAAAAAA,
                                                        fontSize: _uiCriteria.textSize3,
                                                        fontWeight: FontWeight.w500)),
                                                (_isDateSelected)
                                                    ? RichText(
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                          letterSpacing: 0.6,
                                                          fontSize: _uiCriteria.textSize3,
                                                          color: mainColor,
                                                          fontWeight: FontWeight.w700),
                                                      children: <TextSpan>[
                                                        TextSpan(text: "$_reservationDate"),
                                                        TextSpan(
                                                            text: " 총 $_cnt일",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w700))
                                                      ]),
                                                )
                                                    : Text("기간 미선택", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3))
                                              ]
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text("하루 보증금",
                                                  style: TextStyle(
                                                      letterSpacing: 0.6,
                                                      color: greyAAAAAA,
                                                      fontSize: _uiCriteria.textSize3,
                                                      fontWeight: FontWeight.w500)),
                                              (_correctMoney)
                                                  ? Text(
                                                  "${_oneDayAmount.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                                                  style: TextStyle(
                                                      letterSpacing: 0.6,
                                                      color: mainColor,
                                                      fontSize: _uiCriteria.textSize3,
                                                      fontWeight: FontWeight.w700))
                                                  : Text("금액 미입력", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),)
                                            ],
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 520,
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    child: AspectRatio(
                                      aspectRatio: 375/42,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                                        decoration: BoxDecoration(
                                            color: greyF0F0F1
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("총 결제금액",
                                                style: TextStyle(
                                                    letterSpacing: 0.8,
                                                    color: mainColor,
                                                    fontSize: _uiCriteria.textSize16,
                                                    fontWeight: FontWeight.w700)),
                                            (_isDateSelected && _correctMoney)
                                                ?Text("${_totalPayment.replaceAllMapped(
                                                new RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                    (Match m) =>
                                                '${m[1]},')}원",
                                                style: TextStyle(
                                                    letterSpacing: 0.8,
                                                    color: mainColor,
                                                    fontSize: _uiCriteria.textSize16,
                                                    fontWeight: FontWeight.w700))
                                                : Text("0원",
                                                style: TextStyle(
                                                    letterSpacing: 0.8,
                                                    color: mainColor,
                                                    fontSize: _uiCriteria.textSize16,
                                                    fontWeight: FontWeight.w700))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]
                          ),
                        );
                      },
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/11.8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: greyF0F0F1
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/40,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: greyD8D8D8, width: 0.5))),
                        child: Text("결제 수단",
                            style: TextStyle(
                                letterSpacing: 0.7,
                                color: mainColor,
                                fontWeight: FontWeight.w700,
                                fontSize: _uiCriteria.textSize2))),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.verticalPadding),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _sendAccount = false;
                                      _speckCashPay = true;
                                      _paymentId = 2;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: (_speckCashPay)
                                            ? mainColor
                                            : greyD8D8D8,
                                        size: _uiCriteria.textSize4,
                                      ),
                                      Text("  스펙 캐시",
                                          style: TextStyle(
                                              letterSpacing: 0.6,color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                (_speckCashPay)
                                ? RichText(
                                  text: TextSpan(
                                    style: TextStyle(letterSpacing: -0.35,color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500,),
                                    children: <TextSpan>[
                                      TextSpan(text: "잔여금액  "),
                                      TextSpan(text: "${_speckCash.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}", style: TextStyle(fontWeight: FontWeight.w700)),
                                      TextSpan(text: "원")
                                    ]
                                  ),
                                )
                                : Container()
                              ],
                            ),
                            SizedBox(height: _uiCriteria.totalHeight * 0.0147,),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sendAccount = true;
                                  _speckCashPay = false;
                                  _paymentId = 3;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: (_sendAccount)
                                            ? mainColor
                                            : greyD8D8D8,
                                        size: _uiCriteria.textSize4,
                                      ),
                                      Text("  계좌이체",
                                          style: TextStyle(
                                              letterSpacing: 0.6,color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                  (_sendAccount)?
                                  Text("하나 748-911346-03807 노지훈(파이다고고스)", style: TextStyle(color: mainColor,
                                      fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),)
                                  :Container()
                                ],
                              ),
                            ),
                            (_sendAccount)
                                ? Column(
                              children: <Widget>[
                                SizedBox(height: _uiCriteria.totalHeight * 0.0147,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 84,
                                      child: AspectRatio(
                                        aspectRatio: 84/50,
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3.5),
                                              border: Border.all(color: mainColor)
                                          ),
                                          child: Text("입금자명", style: TextStyle(color: mainColor, letterSpacing: -0.36, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: _uiCriteria.screenWidth * 0.032,),
                                    Expanded(
                                      flex: 247,
                                      child: AspectRatio(
                                        aspectRatio: 247/50,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3.5),
                                              border: Border.all(color: greyB3B3BC)
                                          ),
                                          child: TextField(
                                            onChanged: _accountOwnerChanged,
                                            cursorColor: mainColor,
                                            controller: _accountOwnerController,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "입금자명 입력",
                                                hintStyle: TextStyle(color: greyB3B3BC, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7)
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: _uiCriteria.totalHeight * 0.0147,),
                                Text("- 입력하신 입금자명과 예금주명이 일치하여야 예약처리 되는 점 유의 부탁드립니다.",style: TextStyle(color: greyAAAAAA, fontWeight:FontWeight.w500, fontSize: _uiCriteria.textSize5),),
                              ],
                            )
                                : Container()
                          ])
                  ),
                  AspectRatio(aspectRatio: 375/92)
                ],
              ),
            ),
          ),
          AspectRatio(
              aspectRatio: 375/92,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return Container(
                    padding: EdgeInsets.only(right: _uiCriteria.horizontalPadding, left: _uiCriteria.horizontalPadding, top: constraint.maxHeight * 0.13333),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, spreadRadius: 0, offset: Offset(0, -8))]
                    ),
                    alignment: Alignment.topCenter,
                    child: AspectRatio(
                      aspectRatio: 343/50,
                      child: Container(
                        child:  MaterialButton(
                          elevation: 0,
                          color: mainColor,
                          disabledColor: greyD8D8D8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.5),
                          ),
                          onPressed: (_correctMoney && (_isStartSelected && _isEndSelected)
                              && ((_paymentId == 3 && _accountOwnerNotEmpty) || _paymentId == 2))
                              ?() => _reservation()
                              : null,
                          child: _buttonText(),
                        ),
                      ),
                    ),
                  );
                },
              )
          )
        ],
      ),
    );
  }
  
  Future<dynamic> _reservationData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userEmail = sp.getString("email");
    Uri url = Uri.parse("$speckUrl/prebooking");
    String body = '''{
      "galaxyNum" : ${widget.galaxyNum},
      "userEmail" : "$userEmail"
    }''';
    print(body);
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    print(response.body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

    print(result);
    return Future(() {
      return result;
    });
  }

  void _setReservationData(dynamic data) {
    _speckCash = data["myCash"].toString();
    _accumAtt = data["accumAtt"].toString();
    _accumDeposit = data["accumDeposit"].toString();
    _avgDeposit = data["avgDeposit"].toString();
    _reservationList = data["reserveResult"] + data["preReserveResult"];
  }

  void _accountOwnerChanged(String value) {
    if (value.length > 0) {
      setState(() {
        _accountOwnerNotEmpty = true;
      });
    }
    else {
      setState(() {
        _accountOwnerNotEmpty = false;
      });
    }
  }

  Widget _buttonText() {
    if (!_isStartSelected) {
      return Text("시작 날짜를 선택해 주세요.",
          style: TextStyle(
              letterSpacing: 0.7,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: _uiCriteria.textSize2));
    }
    else if (!_isEndSelected) {
      return Text("종료 날짜를 선택해 주세요.",
          style: TextStyle(
              letterSpacing: 0.7,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: _uiCriteria.textSize2));
    }
    else if (!_correctMoney) {
      return Text("보증금을 천원 단위로 입력해주세요.",
          style: TextStyle(
              letterSpacing: 0.7,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: _uiCriteria.textSize2));
    }
    else if (_paymentId == null) {
      return Text("결제수단을 선택해주세요.",
          style: TextStyle(
              letterSpacing: 0.7,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: _uiCriteria.textSize2));
    }
    else if (_paymentId == 3 && !_accountOwnerNotEmpty) {
      return Text("입금자명을 입력해 주세요.",
          style: TextStyle(
              letterSpacing: 0.7,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: _uiCriteria.textSize2));
    }
    return Text("${_totalPayment.replaceAllMapped(
        new RegExp(
            r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) =>
        '${m[1]},')}원 결제하기",
        style: TextStyle(
            letterSpacing: 0.7,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: _uiCriteria.textSize2));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay.isAfter(DateTime.now())
        && !_generateReservationDateTime().contains(DateTime(selectedDay.year, selectedDay.month, selectedDay.day))) {
      setState(() {
        _focusedDay = focusedDay;
        if (!isSameDay(DateTime.now(), selectedDay)) {
          if (_selectedDays.contains(selectedDay)) {
            _selectedDays.remove(selectedDay);
          }
          else {
            _selectedDays.add(selectedDay);
          }
          List<DateTime> selectedDays = _selectedDays.toList(); // 정렬할 리스트
          selectedDays.sort();
          DateTime start;
          DateTime end;
          if (_selectedDays.isNotEmpty) {
            start = selectedDays.first;
            end = selectedDays.last;
            _selectedStartDay = start;
            _selectedEndDay = end;
          }

          _cnt = _selectedDays.length;
          _totalPayment = (int.parse(((_paymentController.text.isEmpty)?"0":_paymentController.text)) * _cnt)
              .toString();

          if (_cnt == 0) {
            _startDate = "미선택";
            _endDate = "미선택";
            _isStartSelected = false;
            _isEndSelected = false;
            _isDateSelected = false;
          }
          else {
            _startDate = "${start.month}월 ${start.day}일";
            _endDate = "${end.month}월 ${end.day}일";
            _isStartSelected = true;
            _isEndSelected = true;
            _isDateSelected = true;
          }
        }
      });
    }
    else if (_generateReservationDateTime().contains(DateTime(selectedDay.year, selectedDay.month, selectedDay.day))) {
      _showDialog("이미 예약된 날짜를 선택했어요.");
    }
  }

  void _onRangeSelected(DateTime start, DateTime end, DateTime focusedDay) {
    if (start.isAfter(DateTime.now())
        && !_generateReservationDateTime().contains(DateTime(start.year, start.month, start.day))) {
      setState(() {
        // 첫번째 선택
        if (end == null) {
          _temp = [];
          _cnt = 0;
          _isRangeSelected = false;
          _isDateSelected = false;
          _sumDay = 0;
          _setCheckDayFalse();
          if (!isSameDay(DateTime.now(), focusedDay)) {
            // _selectedDay = null;
            _focusedDay = focusedDay;
            _rangeStartDay = start;
            _rangeEndDay = end;
            _startDate = "${_rangeStartDay.month}월 ${_rangeStartDay.day}일";
            _endDate = "미선택";
            _isStartSelected = true;
            _isEndSelected = false;
          }
          else {
            // _selectedDay = null;
            _focusedDay = focusedDay;
            // print(_focusedDay);
            _rangeStartDay = null;
            _rangeEndDay = null;
            _startDate = "미선택";
            _endDate = "미선택";
            _isStartSelected = false;
            _isEndSelected = false;
          }
        }
        // 두번째 선택
        else {
          if (focusedDay.isBefore(end)) {
            _focusedDay = focusedDay;
            _rangeStartDay = null;
            _rangeEndDay = null;
            _startDate = "미선택";
            _isStartSelected = false;
            _isEndSelected = false;
          }
          else if (_generateReservationDateTime().contains(DateTime(end.year, end.month, end.day))
          || _rangeContainsEvents(start, end)) {
            _focusedDay = focusedDay;
            _rangeStartDay = null;
            _rangeEndDay = null;
            _startDate = "미선택";
            _isStartSelected = false;
            _isEndSelected = false;
            _showDialog("이미 예약된 날짜가 포함되어 있어요.");
          }
          else {
            _focusedDay = focusedDay;
            _rangeStartDay = start;
            _rangeEndDay = end;
            _endDate = "${_rangeEndDay.month}월 ${_rangeEndDay.day}일";
            _isEndSelected = true;
          }
        }

        if (_rangeStartDay != null && _rangeEndDay != null) {
          _rangeDays = getDates(_rangeStartDay, _rangeEndDay);
          _diff = _rangeEndDay.difference(_rangeStartDay).inDays;
          for (int i = 0; i < _rangeDays.length; i++) {
            _temp.add(_rangeDays[i]);
          }
          _weekdays = _getWeekday(_temp);
          _cnt = _temp.length;
          _sumDay = _getSumDay(_weekdays);
          _isRangeSelected = true;
          _isDateSelected = true;
          _totalPayment = (int.parse(((_paymentController.text.isEmpty)?"0":_paymentController.text)) * _cnt)
              .toString();
        }
      });
    }
  }

  bool _rangeContainsEvents(DateTime start, DateTime end) {
    List<DateTime> range = List.generate(end.difference(start).inDays + 1, (index) =>
        DateTime(start.year, start.month, start.day).add(Duration(days: index)));
    for (DateTime dateTime in _generateReservationDateTime()) {
      if (range.contains(dateTime)) {
        return true;
      }
    }
    return false;
  }

  void _showDialog(String message) {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _dialog(message);
        });
  }

  Widget _dialog(String message) {
    AlertDialog dialog = new AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.9)
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.1653),
      content: AspectRatio(
        aspectRatio: 251/150,
        child:Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8))
                ),
                child: Column(
                  children: [
                    Spacer(),
                    Icon(Icons.error_rounded, color: mainColor,),
                    Spacer(),
                    Text(message, style: TextStyle(color: mainColor,
                        fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),),
                    Spacer(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent)
                  ),
                  alignment: Alignment.center,
                  child: Text("확인", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.6),),
                ),
              ),
            )

          ],
        ),
      ),
    );
    return dialog;
  }

  void _onPageChanged(DateTime dateTime) {
    setState(() {
      _focusedDay = dateTime;
      _isPageChanged = !_isPageChanged;
    });
  }

  List<ReservationEvent> _getReservationEventsForDay(DateTime day, List<dynamic> infoList) {
    return getReservationEvents(infoList)[day] ?? [];
  }

  List<DateTime> _generateReservationDateTime() {
    List<DateTime> result = [];
    List<dynamic> events =  _reservationList;

    for (int i = 0; i < events.length; i++) {
      DateTime ele = DateTime.parse(_reservationList[i]["dateinfo"]);
      DateTime dt = DateTime(ele.year, ele.month, ele.day);
      result.add(dt);
    }
    return result;
  }

  Widget _disabledBuilder(BuildContext context, DateTime one, DateTime two) {
      return Container(
          alignment: Alignment.center,
          child: Text("${one.day}", style: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),));
  }

  Widget _markerBuilder(BuildContext context, DateTime one, List<ReservationEvent> event) {
    for (int i = 0; i < event.length; i++) {
      return Text(event[i].time, style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.bold, fontSize: _uiCriteria.textSize7, letterSpacing: 0.4),);
    }
    return null;
  }

  Widget _defaultBuilder(BuildContext context, DateTime one, DateTime two) {
    if (one.isBefore(DateTime.now()) || _generateReservationDateTime().contains(DateTime(one.year, one.month, one.day))) {
      return Container(
          alignment: Alignment.center,
          child: Text("${one.day}", style: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),));
    }
    return Container(
        alignment: Alignment.center,
        child: Text("${one.day}", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),));
  }

  Widget _getReservationCalendar(BuildContext context, List<dynamic> reservationList) {
    return TableCalendar<ReservationEvent>(
      availableGestures: AvailableGestures.horizontalSwipe,
      eventLoader: (DateTime dateTime) {
        return _getReservationEventsForDay(dateTime, reservationList);
      },
      locale: 'ko_KR',
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      firstDay: _firstDay,
      rangeStartDay: _rangeStartDay,
      rangeEndDay: _rangeEndDay,
      rowHeight: _uiCriteria.screenWidth * 0.1307,
      calendarFormat: CalendarFormat.month,

      calendarBuilders: CalendarBuilders(
          todayBuilder: (BuildContext context, DateTime one, DateTime two) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.transparent
              ),
              child: Container(
                alignment: Alignment.center,
                width: _uiCriteria.screenWidth * 0.064,
                height: _uiCriteria.screenWidth * 0.064,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: mainColor.withOpacity(0.1), width: 0.2),
                  boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), spreadRadius: 1, blurRadius: 6, offset: Offset(0,0))],
                ),
                child: Text(
                    "${one.day}",
                    style: TextStyle(fontWeight: FontWeight.w700, color: mainColor, fontSize: _uiCriteria.textSize3)
                ),
              ),
            );
          },
          defaultBuilder: _defaultBuilder,
          disabledBuilder: _disabledBuilder,
          markerBuilder: _markerBuilder,
        withinRangeBuilder: (BuildContext context, DateTime one, DateTime two) {
           return Container(
              alignment: Alignment.center,
              child: Text(
                  "${one.day}",
                  style: TextStyle(color: (_getDayCheck(one.weekday))?mainColor:greyAAAAAA,
                      fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700,
                      decoration: (_getDayCheck(one.weekday))?null:TextDecoration.lineThrough)));
        }
      ),
      calendarStyle: CalendarStyle(
        weekendTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        todayTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        rangeStartTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        rangeEndTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        selectedTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        withinRangeTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700,),
        outsideDaysVisible: false,
        cellMargin: EdgeInsets.all(_uiCriteria.screenWidth * 0.01067),
        selectedDecoration: BoxDecoration(
            color: mainColor,
            shape: BoxShape.circle
        ),
        rangeStartDecoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
            color: mainColor,
            shape: BoxShape.circle
        ),
        rangeHighlightColor: greyF5F5F6,
        // todayDecoration: BoxDecoration(
        //   color: Colors.white,
        //   shape: BoxShape.circle,
        //   border: Border.all(color: mainColor.withOpacity(0.1), width: 0.2),
        //   boxShadow: [BoxShadow(color: mainColor.withOpacity(0.5), spreadRadius: 1, blurRadius: 6, offset: Offset(0,0))],
        // ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        weekdayStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),
        weekendStyle: TextStyle(color: const Color(0XFFE7535C), fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),
      ),
      daysOfWeekHeight: _uiCriteria.totalHeight * 0.0431,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(letterSpacing: 0.6,fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        headerMargin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.01379),
        headerPadding: EdgeInsets.zero,
        leftChevronMargin: EdgeInsets.zero,
        rightChevronMargin: EdgeInsets.only(right: _uiCriteria.horizontalPadding),
        leftChevronPadding: EdgeInsets.only(left: _uiCriteria.horizontalPadding),
        rightChevronPadding: EdgeInsets.zero,
        leftChevronIcon:  Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent)
            ),
            child: Icon(Icons.chevron_left_sharp, color: (_isPageChanged)? greyD8D8D8 : Colors.transparent, size: _uiCriteria.textSize4,)),
        rightChevronIcon: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent)
            ),
            child: Icon(Icons.chevron_right_sharp, color: (_isPageChanged)?Colors.transparent : greyD8D8D8, size: _uiCriteria.textSize4,)),
      ),
      rangeSelectionMode: _rangeSelectionMode,
      selectedDayPredicate: (DateTime day) {
        return _selectedDays.contains(day);
      },
      onDaySelected: _onDaySelected,
      onRangeSelected: _onRangeSelected,
      onPageChanged: _onPageChanged
    );
  }

  void _calCNT(List<DateTime> rangeDays, bool checked, List<int> weekdays) {
    setState(() {
      for (int i = 0; i < weekdays.length; i ++) {
        for (int j = 1; j < _rangeDays.length - 1; j++) {
          if (rangeDays[j].weekday == weekdays[i]) {
            if (checked) {
              _temp.add(rangeDays[j]);
            }
            else {
              _temp.remove(rangeDays[j]);
            }
          }
        }
      }
      _cnt = _temp.length;
      _totalPayment = (int.parse((_paymentController.text.isEmpty)?"0":_paymentController.text) * _cnt).toString();
    });
  }

  void _setCheckDayFalse() {
    setState(() {
      _monChecked = false;
      _tueChecked = false;
      _wedChecked = false;
      _thuChecked = false;
      _friChecked = false;
      _satChecked = false;
      _sunChecked = false;
      _weekdayChecked = false;
      _weekendChecked = false;
    });
  }

  void _setCheckDay(int weekday) {
    switch (weekday) {
      case 1:
        setState(() {
          _monChecked = true;
        });
        break;
      case 2:
        setState(() {
          _tueChecked = true;
        });
        break;
      case 3:
        setState(() {
          _wedChecked = true;
        });
        break;
      case 4:
        setState(() {
          _thuChecked = true;
        });
        break;
      case 5:
        setState(() {
          _friChecked = true;
        });
        break;
      case 6:
        setState(() {
          _satChecked = true;
        });
        break;
      case 7:
        setState(() {
          _sunChecked = true;
        });
        break;
    }
  }

  bool _getDayCheck(int weekday) {
    switch (weekday) {
      case 1:
        return _monChecked;
      case 2:
        return _tueChecked;
      case 3:
        return _wedChecked;
      case 4:
        return _thuChecked;
      case 5:
        return _friChecked;
      case 6:
        return _satChecked;
      case 7:
        return _sunChecked;
    }
    return false;
  }

  int _getSumDay(List<int> weekdays) {
    int sumDay = 0;
    for (int i = 0; i < _weekdays.length; i++) {
      _setCheckDay(_weekdays[i]);
      sumDay += pow(2, _weekdays[i] - 1);
    }
    return sumDay;
  }

  List<int> _getWeekday(List<DateTime> rangeDays) {
    List<int> result = [];
    if (rangeDays.length < 7) {
      for (int i = 0; i < rangeDays.length; i++) {
        result.add(rangeDays[i].weekday);
      }
    }
    else {
      for (int i = 0; i < 7; i++) {
        result.add(rangeDays[i].weekday);
      }
    }
    return result;
  }
  
  String _startDate;
  String _endDate;
  String _reservationDate;
  String _canAuthTime;
  bool _monChecked;
  bool _tueChecked;
  bool _wedChecked;
  bool _thuChecked;
  bool _friChecked;
  bool _satChecked;
  bool _sunChecked;
  bool _weekdayChecked;
  bool _weekendChecked;
  String _time;

  DateTime _firstDay;
  DateTime _lastDay;
  int _lastDayDay;
  DateTime _focusedDay;
  RangeSelectionMode _rangeSelectionMode;
  DateTime _rangeStartDay;
  DateTime _rangeEndDay;
  DateTime _selectedStartDay;
  DateTime _selectedEndDay;

  bool _isRangeSelected;
  bool _isPageChanged;
  bool _isStartSelected;
  bool _isEndSelected;
  bool _isDateSelected;
  List<DateTime> _rangeDays;
  List<DateTime> _temp = [];
  List<int> _weekdays;
  int _sumDay;
  int _diff;
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode
  );
  int _selectedIndex;
  bool _holiday;
  TextEditingController _paymentController = new TextEditingController();
  TextEditingController _accountOwnerController = new TextEditingController();
  String _oneDayAmount;
  String _totalPayment;
  int _deposit;
  int _cnt;
  bool _correctMoney;
  bool _accountOwnerNotEmpty;
  bool _moneySystemClicked;
  bool _speckCashPay;
  bool _sendAccount;
  String _speckCash;
  int _paymentId;
  List<dynamic> _reservationList;
  String _accumAtt;
  String _accumDeposit;
  String _avgDeposit;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _firstDay = DateTime(_focusedDay.year, _focusedDay.month);
    // _firstDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    DateTime x1 = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).toUtc();
    _lastDayDay = DateTime(_focusedDay.year, _focusedDay.month + 2, 0).toLocal().difference(x1).inDays;
    _lastDay = DateTime(DateTime.now().year, DateTime.now().month + 1, _lastDayDay);
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    _isRangeSelected = false;
    _isPageChanged = false;
    _isStartSelected = false;
    _isEndSelected = false;
    _isDateSelected = false;
    _monChecked = false;
    _tueChecked = false;
    _wedChecked = false;
    _thuChecked = false;
    _friChecked = false;
    _satChecked = false;
    _sunChecked = false;
    _weekdayChecked = false;
    _weekendChecked = false;
    _sumDay = 0;
    _diff = 0;
    _selectedIndex = 0;
    _holiday = false;
    _oneDayAmount = "0";
    _startDate = "미선택";
    _endDate = "미선택";
    _totalPayment = "0";
    _reservationDate = "";
    _isRangeSelected = false;
    _moneySystemClicked = false;
    _correctMoney = false;
    _speckCashPay = false;
    _sendAccount = false;
    _accountOwnerNotEmpty = false;
    switch (widget.timeNum) {
      case 1:
        _canAuthTime = "07:00 ~ 08:00";
        _time = "08:00";
        break;
      case 2:
        _canAuthTime = "08:00 ~ 09:00";
        _time = "09:00";
        break;
      case 3:
        _canAuthTime = "09:00 ~ 10:00";
        _time = "10:00";
        break;
      case 4:
        _canAuthTime = "10:00 ~ 11:00";
        _time = "11:00";
        break;
      case 5:
        _canAuthTime = "11:00 ~ 12:00";
        _time = "12:00";
        break;
      case 6:
        _canAuthTime = "12:00 ~ 13:00";
        _time = "13:00";
        break;
      case 7:
        _canAuthTime = "13:00 ~ 14:00";
        _time = "14:00";
        break;
      case 8:
        _canAuthTime = "14:00 ~ 15:00";
        _time = "15:00";
        break;
      case 9:
        _canAuthTime = "15:00 ~ 16:00";
        _time = "16:00";
        break;
      case 10:
        _canAuthTime = "16:00 ~ 17:00";
        _time = "17:00";
        break;
      case 11:
        _canAuthTime = "17:00 ~ 18:00";
        _time = "18:00";
        break;
      case 12:
        _canAuthTime = "18:00 ~ 19:00";
        _time = "19:00";
        break;
      case 13:
        _canAuthTime = "19:00 ~ 20:00";
        _time = "20:00";
        break;
      case 14:
        _canAuthTime = "20:00 ~ 21:00";
        _time = "21:00";
        break;
      case 15:
        _canAuthTime = "21:00 ~ 22:00";
        _time = "22:00";
        break;
      case 16:
        _canAuthTime = "22:00 ~ 23:00";
        _time = "23:00";
        break;
      case 17:
        _canAuthTime = "23:00 ~ 00:00";
        _time = "00:00";
        break;
      case 18:
        _canAuthTime = "00:00 ~ 01:00";
        _time = "01:00";
        break;
      case 19:
        _canAuthTime = "01:00 ~ 02:00";
        _time = "02:00";
        break;
      case 20:
        _canAuthTime = "02:00 ~ 03:00";
        _time = "03:00";
        break;
      case 21:
        _canAuthTime = "03:00 ~ 04:00";
        _time = "04:00";
        break;
      case 22:
        _canAuthTime = "04:00 ~ 05:00";
        _time = "05:00";
        break;
      case 23:
        _canAuthTime = "05:00 ~ 06:00";
        _time = "06:00";
        break;
      case 24:
        _canAuthTime = "06:00 ~ 07:00";
        _time = "07:00";
        break;
    }
    _cnt = 0;
  }

  void _reservation() {
    switch (_paymentId) {
      case 2: 
        _showCashReserveDialog(context);
        break;
      case 3:
        _showNotice();
        break;
    }
  }

  void _reservationByCash() async {
    print(int.parse(_speckCash));
    print(int.parse(_totalPayment));
    if (int.parse(_speckCash) >= int.parse(_totalPayment)) {
      Future future = _request();
      int statusCode;
      await future.then((value) => statusCode = value).onError((error, stackTrace) => print("error: $error"));
      _onResponse(statusCode);
    }
    else {
      Navigator.pop(context);
      errorToast("캐시가 부족합니다.");
    }
  }

  void _reservationByAccount() async {
    Future future = _request();
    int statusCode;
    await future.then((value) => statusCode = value).onError((error, stackTrace) => print("error: $error"));
    _onResponse(statusCode);
  }

  void _showNotice() {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        context: context,
        builder: (BuildContext context) {
          return _accountNotice();
        });
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

  Widget _accountNotice() {
    AlertDialog dialog = new AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.5)
      ),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.1666),
      contentPadding: EdgeInsets.zero,
      content: AspectRatio(
        aspectRatio: 250/194,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 398,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                ),
                child: Text("계좌이체", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.bold, letterSpacing: 0.7),),
              ),
            ),
            Expanded(
              flex: 1538,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.048),
                    child: Column(
                      children: <Widget>[
                        Spacer(flex: 11,),
                        Text("필독!", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6)),
                        Spacer(flex: 11,),
                        Text("입금 후, 스펙 고객센터 번호로 예약확인 문자를", style: TextStyle(color: mainColor,
                            fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5),),
                        Spacer(flex: 6,),
                        Text("받으셔야 예약이 완료된다는 점 유의부탁드립니다.", style: TextStyle(color: mainColor,
                            fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5),),
                        Spacer(flex: 12,),
                        Text("(24시간 내로 문자가 안 온다면, 문의 부탁드립니다)", style: TextStyle(color: greyAAAAAA,
                            fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5),),
                        Spacer(flex: 12,),
                        AspectRatio(
                          aspectRatio: 226/39,
                          child: MaterialButton(
                            elevation: 0,
                            onPressed: _reservationByAccount,
                            color: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.5),
                            ),
                            child: Text("확인", style: TextStyle(fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        ),
                        Spacer(flex: 11,),
                      ]
                    ),
                  );
                },
              )
            )
          ],
        ),
      ),
    );
    return dialog;
  }

  void _onResponse(int statusCode) {
    if (statusCode == 200) {
      Future.delayed(Duration(microseconds: 1500), () {
        Navigator.pop(context);
      }).whenComplete(() => _navigateNext());
    }
    else if (statusCode == 402) {
      Future.delayed(Duration(microseconds: 1500), () {
        Navigator.pop(context);
      }).whenComplete(() => errorToast("이미 예약된 날짜가 포함되어있어요."));

    }
    else if (statusCode == 404) {
      Future.delayed(Duration(microseconds: 1500), () {
        Navigator.pop(context);
      }).whenComplete(() => errorToast("다시 시도해주세요."));
    }
  }

  void _navigateNext() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ReservationComplete(
      schoolName: widget.galaxyName,
      imagePath: widget.imagePath,
      time: _time,
      canAuthTime: _canAuthTime,
      type: widget.official,
      cnt: _cnt,
      startDate: (_selectedIndex == 0)?_rangeStartDay:_selectedStartDay,
      endDate: (_selectedIndex == 0)?_rangeEndDay:_selectedEndDay,
      oneDayAmount: _oneDayAmount, pay: (_paymentId == 2)?"스펙캐시":"계좌이체",
      account: "하나 748-911346-03807 노지훈(파이다고고스)",
      payType: _paymentId,
    )), (route) => false);
  }

  List<String> _generateListDate(int index) {
    if (index == 0) {
      return List.generate(_temp.length, (index) => "\"${_temp[index].toString().substring(0, 10)}\"");
    }
    else {
      List<DateTime> selectedDays = _selectedDays.toList();
      selectedDays.sort();
      return List.generate(selectedDays.length, (index) => "\"${selectedDays[index].toString().substring(0, 10)}\"");
    }
  }

  Future<dynamic> _request() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userEmail = sp.getString("email");
    String start = (_selectedIndex == 0)?_rangeStartDay.toString().substring(0,10):_selectedStartDay.toString().substring(0, 10);
    String end = (_selectedIndex == 0)?_rangeEndDay.toString().substring(0,10):_selectedEndDay.toString().substring(0,10);
    List<String> date = _generateListDate(_selectedIndex);
    _showLoader();
    var url = Uri.parse("$speckUrl/booking");
    String body = '''{
      "startdate": "$start",
      "enddate": "$end",
      "userEmail": "$userEmail",
      "groupnum": ${widget.galaxyNum},
      "explorer": ${widget.timeNum},
      "dateinfo": $date,
      "deposit": $_deposit,
      "paymentId" : $_paymentId,
      "paymentSetName" : "${_accountOwnerController.text}" 
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    var utf = utf8.decode(response.bodyBytes);
    print(utf);
    var result = jsonDecode(utf)["statusCode"];
    print("예약 요청 결과: $result");
    return Future(() {
      return result;
    });
  }

  void _onChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        try {
          _deposit = int.parse(value);

          if (_deposit == 0) {
            _paymentController.clear();
            _correctMoney = false;
          }
          else if ((_deposit < 1000 || _deposit > 20000) || (_deposit % 1000 != 0)) {
            _correctMoney = false;
          }
          else {
            _oneDayAmount = value;
            _totalPayment = (int.parse(
                value) *
                _cnt)
                .toString();
            _correctMoney = true;

          }
        }
        catch (e) {
          print(e);
        }
      }
      else {
        _oneDayAmount = "0";
        _correctMoney = false;
      }
    });
  }

  void _showCashReserveDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _cashReserveDialog(context);
        });
  }

  Widget _cashReserveDialog(BuildContext context) {
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
                      child: Text("스펙 캐시를 이용하여 예약하시겠어요?", style: TextStyle(letterSpacing: 0.7,color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),))),
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
                              _reservationByCash();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: greyD8D8D8, width: 0.5))),
                                alignment: Alignment.center,
                                child: Text("예약", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
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
