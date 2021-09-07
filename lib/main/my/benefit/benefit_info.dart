import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Main/my/benefit/benefit_withdrawal_page.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';
import 'benefit_event.dart';

class BenefitInfo extends StatefulWidget {
  final String benefit;

  const BenefitInfo({Key key,@required this.benefit}) : super(key: key);

  @override
  State createState() {
    return BenefitInfoState();
  }
}

class BenefitInfoState extends State<BenefitInfo> {
  final UICriteria _uiCriteria = new UICriteria();

  bool _is1000Up;
  DateTime _firstDay;
  DateTime _lastDay;
  DateTime _focusedDay;
  RangeSelectionMode _rangeSelectionMode;
  DateTime _rangeStartDay;
  DateTime _rangeEndDay;
  int _accumPrize;
  int _withdrawalPrize;
  int _available;
  List<dynamic> _rewardDetailList;
  DateTime _selectedDay;
  ValueNotifier<List<BenefitEvent>> _selectedEvents;
  bool _tapped;
  bool _moneySystemTapped;

  @override
  void initState() {
    super.initState();
    // _check1000Up(widget.benefitAmount);
    _focusedDay = DateTime.now();
    _firstDay = DateTime(_focusedDay.year - 1, _focusedDay.month);
    _lastDay = DateTime(DateTime.now().year + 1, DateTime.now().month + 1, 0);
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    _tapped = false;
    _moneySystemTapped = false;
  }


  @override
  void dispose() {
    super.dispose();
    _selectedEvents.dispose();
  }

  void _check1000Up(int available) {
    try {
      int amount = available;
      if (amount >= 1000) {
        _is1000Up = true;
      }
      else {
        _is1000Up = false;
      }
    }
    catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
      title: "상금 정보 페이지",
      debugShowCheckedModeBanner: false,
      home: Stack(
        alignment: Alignment.topRight,
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: _appBar(context),
            body: FutureBuilder(
              future: _getData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  _setData(snapshot.data);
                  _check1000Up(_available);
                  return  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _benefitInfo(context),
                        _withdrawInfo(context)
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
          (_moneySystemTapped)
              ? Padding(
            padding: EdgeInsets.only(top: _uiCriteria.appBarHeight + _uiCriteria.statusBarHeight,right: _uiCriteria.horizontalPadding),
            child: Align(
              alignment: Alignment.topRight,
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
    );
  }

  Future<dynamic> _getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/mypage/myPrize");
    String body = '''{
      "userEmail" : "${sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    
    var response = await http.post(url, body: body, headers: header);
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    print(data);
    return data;
  }

  void _setData(dynamic data) {
    _accumPrize = data["accumPrize"];
    _withdrawalPrize = data["withdrawalPrize"];
    _available = data["available"];
    _rewardDetailList = data["rewardDetailList"];
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
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              width: _uiCriteria.screenWidth,
              child: Text("나의 상금", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize16),)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(right: _uiCriteria.horizontalPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("상금제도 ",
                            style: TextStyle(
                                letterSpacing: 0.6,
                                color: greyD8D8D8,
                                fontWeight: FontWeight.w700,
                                fontSize: _uiCriteria.textSize3)),
                        Image.asset("assets/png/question_mark.png", height: _uiCriteria.textSize16,)
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _moneySystemTapped = !_moneySystemTapped;
                    });
                  }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _benefitInfo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: greyF0F0F1
      ),
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0443),
      child: AspectRatio(
        aspectRatio: 343/158,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.9)
          ),
          child: Column(
            children: <Widget>[
              _benefitAmount(context),
              _withdrawalButton(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitAmount(BuildContext context) {
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
                        Image.asset("assets/png/dust_won_fill_white.png", height: constraint.maxHeight * 0.1983, fit: BoxFit.fill),
                        Text(" 상금", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize6, letterSpacing: 1.0),)
                      ]
                  ),
                  Text("${widget.benefit.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize6, letterSpacing: 1.0))
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
          child:
            _is1000Up
            ? Text("지금 바로 출금하기", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),)
            : Text("1,000원 이상일 때 출금할 수 있어요.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
        ),
        onTap:
        _is1000Up
        ? () => _navigateWithdrawalPage(context)
        : null,
      ),
    );
  }

  void _navigateWithdrawalPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BenefitWithdrawalPage(benefit: widget.benefit)));
  }
  
  Widget _calendarTitle(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/40,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Text("일별 상금 내역", style: TextStyle(color: mainColor, letterSpacing: 0.7, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),),
      ),
    );
  }

  List<BenefitEvent> _getEventsForDay(DateTime day, List<dynamic> infoList) {
    return getEvents(infoList)[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, List<dynamic> infoList) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStartDay = null;
        _rangeEndDay = null;
      });
    }
    _selectedEvents.value = _getEventsForDay(selectedDay, infoList);
  }

  Widget _markerBuilder(BuildContext context, DateTime one, List<BenefitEvent> event) {
    for (int i = 0; i < event.length; i++) {
      return Container(
        width: _uiCriteria.calendarMarkerSize,
        height: _uiCriteria.calendarMarkerSize,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mainColor
        ),
      );
    }
    return null;
  }

  Widget _withdrawalInfo(DateTime prizeTime, int withdrawalPrize, int sumPrize) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0147),
      child: AspectRatio(
          aspectRatio: 343/77,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraint) {
              return Container(
              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0349),
              decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.9),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), spreadRadius: 0, blurRadius: 6, offset: Offset(0, 3))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(flex: 12,),
                    Text("${prizeTime.month}월 ${prizeTime.day}일 ${prizeTime.hour.toString().padLeft(2, "0")}:${prizeTime.minute.toString().padLeft(2, "0")} 출석",
                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, letterSpacing: 0.4, fontWeight: FontWeight.w500),),
                    Spacer(flex: 11,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("상금 출금",
                          style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.bold),),
                        Text("${withdrawalPrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",style: TextStyle(color: Color(0XFFE7535C), fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.bold))
                      ],
                    ),
                    Spacer(flex: 3,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text("${sumPrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                        style: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4),)
                      ]
                    ),
                    Spacer(flex: 12,),
                  ],
                ),
              );
            },
          )
      ),
    );
  }

  Widget _rewardDetailListInfo(int official, String galaxyName, DateTime dateInfo, int timeNum, int myReward, int myAccumReward,
      int attCount, int absentCount, int totalCount, int dailyDeposit, int totalReward, int unitReward, int deposit) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.9),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), spreadRadius: 0, blurRadius: 6, offset: Offset(0, 3))]
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 343/77,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(flex: 12,),
                  Text("${dateInfo.month}월 ${dateInfo.day}일 ${dateInfo.hour.toString().padLeft(2, "0")}:${dateInfo.minute.toString().padLeft(2, "0")} 출석",
                    style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4),),
                  Spacer(flex: 11,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text((official == 1)?"[공식] $galaxyName(${getAuthTime(timeNum)})":"$galaxyName(${getAuthTime(timeNum)})",
                        style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.bold),),
                      Text("+${myReward.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.bold),)
                    ],
                  ),
                  Spacer(flex: 3,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("${myAccumReward.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                        style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.4)),
                  ),
                  Spacer(flex: 12,),
                ],
              ),
            ),
          ),
          (_tapped)
          ? Container()
          : Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 343/77,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Spacer(flex: 12,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("출석자", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                                  Text("${attCount.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명",
                                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                                ],
                              ),
                              Spacer(flex: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("결석자", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                                  Text("${absentCount.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명",
                                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                                ],
                              ),
                              Spacer(flex: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("총 예약자", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                                  Text("${totalCount.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명",
                                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                                ],
                              ),
                              Spacer(flex: 12,),
                            ],
                          ),
                        ),
                        SizedBox(width: _uiCriteria.screenWidth * 0.1466),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Spacer(flex: 12,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("오늘 총 보증금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                                  Text("${dailyDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                                ],
                              ),
                              Spacer(flex: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("오늘 총 상금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                                  Text("${totalReward.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                                ],
                              ),
                              Spacer(flex: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("1,000원당 상금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                                  Text("${unitReward.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                                      style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                                ],
                              ),
                              Spacer(flex: 12,),
                            ],
                          ),
                        )

                      ],
                    )
                ),
              ),
              AspectRatio(
                aspectRatio: 343/77,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                  ),
                  child: Column(
                    children: <Widget>[
                      Spacer(flex: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("나의 하루 보증금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                          Text("${deposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                              style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                        ],
                      ),
                      Spacer(flex: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("내가 받은 상금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                          Text("${myReward.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                              style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                        ],
                      ),
                      Spacer(flex: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("합계", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
                          Text("${(myReward + deposit).toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                              style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                        ],
                      ),
                      Spacer(flex: 12,),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AspectRatio(
            aspectRatio: 343/16.8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tapped = !_tapped;
                });
              },
              child: RotatedBox(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/png/arrow_up.png")
                      )
                  ),
                ),
                quarterTurns: (_tapped)?2:0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _calendarView(BuildContext context, List<dynamic> infoList) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
      ),
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0295),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0283),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.9),
                  color: Colors.white,
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))]
              ),
              child: _calendar(context, _rewardDetailList)
          ),
          ValueListenableBuilder<List<BenefitEvent>>(
              valueListenable: _selectedEvents = new ValueNotifier(_getEventsForDay(_selectedDay, _rewardDetailList)),
              builder: (context, value, _) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int index) {
                    List<dynamic> tempValue = value[index].prizeWithdrawal??[];
                    List<Widget> withdrawal = [];
                    for (int i = 0; i < tempValue.length; i++) {
                      withdrawal.add(_withdrawalInfo(DateTime.parse(tempValue[index]["prizeTime"]), tempValue[index]["withdrawalPrize"], tempValue[index]["sumPrize"]));
                    }
                    return Container(
                      child: Column(
                        children: [
                          (tempValue != null)
                          ? Column(
                            children: withdrawal,
                          )
                          : Container(),
                          (value[index].official != null)
                          ? Column(
                            children: [
                              SizedBox(height: _uiCriteria.totalHeight * 0.0147,),
                              _rewardDetailListInfo(value[index].official, value[index].galaxyName, value[index].dateInfo, value[index].timeNum, value[index].myReward
                                  , value[index].myAccumReward, value[index].attCount, value[index].absentCount, value[index].totalCount, value[index].dailyDeposit,
                                  value[index].totalReward, value[index].unitReward, value[index].deposit),
                            ],
                          )
                          : Container()
                        ],
                      ),
                    );
                  },
                );
              })
        ],
      ),
    );
  }

  Widget _calendar(BuildContext context, List<dynamic> infoList) {
    return  TableCalendar<BenefitEvent>(
      availableGestures: AvailableGestures.horizontalSwipe,
      locale: 'ko_KR',
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      firstDay:  _firstDay,
      rangeStartDay: _rangeStartDay,
      rangeEndDay: _rangeEndDay,
      rowHeight: _uiCriteria.screenWidth * 0.1307,
      calendarFormat: CalendarFormat.month,
      eventLoader: (DateTime dateTime) {
        return _getEventsForDay(dateTime, infoList);
      },
      calendarBuilders: CalendarBuilders(
          markerBuilder: _markerBuilder,
          selectedBuilder: (BuildContext context, DateTime one, DateTime two) {
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
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                    "${one.day}",
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: _uiCriteria.textSize3)
                ),
              ),
            );
          },
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
          }
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle:  TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        weekendTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        disabledTextStyle: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        // outsideTextStyle: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        todayTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        rangeStartTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        rangeEndTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        selectedTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
        // withinRangeTextStyle: TextStyle(color: Colors.black, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700,),
        outsideDaysVisible: false,
        cellMargin: EdgeInsets.all(_uiCriteria.screenWidth * 0.01067),

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
        titleTextStyle: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
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
            child: Icon(Icons.chevron_left_sharp, color: mainColor, size: _uiCriteria.textSize4,)),
        rightChevronIcon: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent)
            ),
            child: Icon(Icons.chevron_right_sharp, color: mainColor, size: _uiCriteria.textSize4,)),
      ),
      rangeSelectionMode: _rangeSelectionMode,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        _onDaySelected(selectedDay, focusedDay, infoList);
      },
    );
  }

  Widget _withdrawInfo(BuildContext context) {
    return Column(
      children: <Widget>[
        _calendarTitle(context),
        _calendarView(context, _rewardDetailList),
        _totalBenefitTitle(context),
        _totalBenefitContent(),
        AspectRatio(
          aspectRatio: 375/11.8,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
          ),
        )      ],
    );
  }

  Widget _totalBenefitTitle(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 375/11.8,
          child: Container(
            color: greyF0F0F1,
          ),
        ),
        AspectRatio(
          aspectRatio: 375/40,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
            child: Text("총 상금 내역", style: TextStyle(color: mainColor, letterSpacing: 0.7, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),),
          ),
        ),
      ],
    );
  }

  Widget _totalBenefitContent() {
    return AspectRatio(
      aspectRatio: 375/140.2,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 982,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              child: Column(
                children: <Widget>[
                  Spacer(flex: 23,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("누적 상금", style: TextStyle(color: mainColor, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                      Text("${_accumPrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: mainColor, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Spacer(flex: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("상금 출금", style: TextStyle(color: mainColor, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                      Text("${_withdrawalPrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: mainColor, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Spacer(flex: 23,),

                ],
              ),
            )
          ),
          Expanded(
            flex: 420,
            child: Container(
              decoration: BoxDecoration(
                color: greyF0F0F1
              ),
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("출금 가능한 상금", style: TextStyle(fontSize: _uiCriteria.textSize16, letterSpacing: 0.8, fontWeight: FontWeight.bold, color: mainColor),),
                  Text("${_available.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(fontSize: _uiCriteria.textSize16, letterSpacing: 0.8, fontWeight: FontWeight.bold, color: mainColor),),
                ],
              ),
            ),
          )
        ],
      )
    );
  }


}
