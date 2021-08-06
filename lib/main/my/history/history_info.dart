import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/main/main_page.dart';
import 'package:speck_app/reservation/check_event.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:speck_app/util/util.dart';

import 'history_event.dart';
import 'my_history.dart';

class HistoryInfo extends StatelessWidget {
  final int type;
  final int bookInfo;

  HistoryInfo({Key key,@required this.type, @required this.bookInfo})
      : super(key: key);

  UICriteria _uiCriteria = new UICriteria();

  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _lastDay = DateTime(DateTime.now().year, DateTime.now().month + 1, 31);
  int _official;
  String _galaxyName;
  int _timeNum;
  int _attendCount;
  int _totalCount;
  String _startDate;
  String _endDate;
  String _paymentMethod;
  int _deposit;
  int _totalPaid;
  int _getDust;
  int _getDeposit;
  int _getReward;
  List<dynamic> _checkList;
  int _lastDayDay;
  int _paymentId;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return _historyInfo(context);
  }

  Widget _historyInfo(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _setData(snapshot.data);
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  greyBar(),
                  _reservationInfo(context, _timeNum),
                  greyBar(),
                  _calendar(_checkList),
                  rule(context),
                  _whiteBar(),
                  greyBar(),
                  _paymentInfo(context),
                  greyBar(),
                  _progressInfo(context),
                  greyBar(),
                  _twoButton(context)
                ],
              ),
            );
          }
          else {
            return loader(context, 0);
          }
        },
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
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
              child: Text("탐험중인 갤럭시", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),)),
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

  String _canAuthTime(int timeNum) {
    switch (timeNum) {
      case 1:
        return "07:00 ~ 08:00";
        break;
      case 2:
        return "08:00 ~ 09:00";
        break;
      case 3:
        return "09:00 ~ 10:00";
        break;
      case 4:
        return "10:00 ~ 11:00";
        break;
      case 5:
        return "11:00 ~ 12:00";
        break;
      case 6:
        return "12:00 ~ 13:00";
        break;
      case 7:
        return "13:00 ~ 14:00";
        break;
      case 8:
        return "14:00 ~ 15:00";
        break;
      case 9:
        return "15:00 ~ 16:00";
        break;
      case 10:
        return "16:00 ~ 17:00";
        break;
      case 11:
        return "17:00 ~ 18:00";
        break;
      case 12:
        return "18:00 ~ 19:00";
        break;
      case 13:
        return "19:00 ~ 20:00";
        break;
      case 14:
        return "20:00 ~ 21:00";
        break;
      case 15:
        return "21:00 ~ 22:00";
        break;
      case 16:
        return "22:00 ~ 23:00";
        break;
      case 17:
        return "23:00 ~ 00:00";
        break;
      case 18:
        return "00:00 ~ 01:00";
        break;
      case 19:
        return "01:00 ~ 02:00";
        break;
      case 20:
        return "02:00 ~ 03:00";
        break;
      case 21:
        return "03:00 ~ 04:00";
        break;
      case 22:
        return "04:00 ~ 05:00";
        break;
      case 23:
        return "05:00 ~ 06:00";
        break;
      case 24:
        return "06:00 ~ 07:00";
        break;
    }
    return null;
  }

  Widget _reservationInfo(BuildContext context, int timeNum) {

    return AspectRatio(
      aspectRatio: 375/215,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Column(
          children: <Widget>[
            title(context, "공식 갤럭시"),
            reservedGalaxyInfo(context, DateTime.parse(_startDate), DateTime.parse(_endDate), _galaxyName, type, _totalCount, _attendCount, timeNum),
            authTime(context, _canAuthTime(timeNum)),
          ],
        ),
      ),
    );
  }

  Widget _paymentInfo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
      ),
      child: Column(
        children: <Widget>[
          paymentTitle(context),
          paymentContent(context, DateTime.parse(_startDate), DateTime.parse(_endDate), _deposit, _totalCount, _paymentId),
          totalAmount(context, _totalPaid)
        ],
      ),
    );
  }

  Widget _whiteBar() {
    return AspectRatio(
      aspectRatio: 375/11.8,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white))
        ),
      ),
    );
  }

  List<HistoryEvent> _getReservationEventsForDay(DateTime day, List<dynamic> infoList) {
    return getHistoryEvents(infoList)[day] ?? [];
  }

  Widget _markerBuilder(BuildContext context, DateTime one, List<HistoryEvent> event) {
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

  Widget _calendar(List<dynamic> checkList) {
    return Container(
      padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding,
          top: _uiCriteria.verticalPadding, bottom: _uiCriteria.totalHeight * 0.0283),
      child: TableCalendar<HistoryEvent>(
        availableGestures: AvailableGestures.horizontalSwipe,
        locale: 'ko_KR',
        lastDay: DateTime(DateTime.parse(_endDate).year, DateTime.parse(_endDate).month, _lastDayDay),
        focusedDay: DateTime.parse(_startDate),
        firstDay:  DateTime(DateTime.parse(_startDate).year, DateTime.parse(_startDate).month, 1),
        rowHeight: _uiCriteria.screenWidth * 0.1307,
        calendarFormat: CalendarFormat.month,
        eventLoader:  (DateTime dateTime) {
          return _getReservationEventsForDay(dateTime, checkList);
        },
        calendarBuilders: CalendarBuilders(
            markerBuilder: _markerBuilder,
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
          markerDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0XFFE7535C),
          ),
          markerSize: _uiCriteria.calendarMarkerSize,
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
          leftChevronVisible: false,
          rightChevronVisible: false,
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          headerMargin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.01379),
          headerPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _progressInfo(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/210,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Column(
          children: <Widget>[
            title(context, "나의 진행도"),
            _explorerResult(_attendCount, _getDust),
            _benefitCash(_getReward, _getDeposit)
          ],
        ),
      ),
    );
  }

  Widget _explorerResult(int attendCount, int getDust) {
    return AspectRatio(
      aspectRatio: 375/85.8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        child: Column(
          children: <Widget>[
            Spacer(flex: 23,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("출석 횟수", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),),
                Text("${attendCount.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}회", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),)
              ],
            ),
            Spacer(flex: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("받은 더스트", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),),
                Text("${getDust.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}D", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),)
              ],
            ),
            Spacer(flex: 23,)
          ],
        ),
      ),
    );
  }

  Widget _benefitCash(int getReward, int getDeposit) {
    return AspectRatio(
      aspectRatio: 375/82,
      child: Container(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 375/72,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
            decoration: BoxDecoration(
              color: greyF0F0F1
            ),
            child: Column(
              children: <Widget>[
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("회수한 보증금", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1, color: mainColor, letterSpacing: 0.8),),
                    Text("${getDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1, color: mainColor, letterSpacing: 0.8),),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("총상금", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1, color: mainColor, letterSpacing: 0.8),),
                    Text("${getReward.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1, color: mainColor, letterSpacing: 0.8),),
                  ],
                ),
                Spacer(),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget _twoButton(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/120,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(flex: 11,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _questionButton(constraint),
                    _cancelButton(context, constraint),
                  ],
                ),
                Spacer(flex: 10,),
                _notice(constraint),
                Spacer(flex: 32,)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _questionButton(BoxConstraints constraint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.5),
              border: Border.all(color: mainColor)
          ),
          width: constraint.maxWidth * 0.4426,
          height: constraint.maxHeight * 0.325,
          child: MaterialButton(
            onPressed: () {launch("tel://070-8095-2363");},
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.chat_bubble_outline_rounded, size: _uiCriteria.textSize2, color: mainColor,),
                Text(" 문의하기", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),)
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _cancelButton(BuildContext context, BoxConstraints constraint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: constraint.maxWidth * 0.4426,
          height: constraint.maxHeight * 0.325,
          child: MaterialButton(
            disabledColor: greyB3B3BC,
            color: mainColor,
            onPressed: (type == 1)
            ? null
            : () {
              showDialog(
                  barrierColor: Colors.black.withOpacity(0.2),
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      elevation: 0,
                      content: AspectRatio(
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
                                        Text("정말 취소하시겠어요?", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.screenWidth * 0.042, fontWeight: FontWeight.w700),),
                                        Spacer(flex: 50),
                                        Text((type == 0)?"취소시 스펙 캐시로 환급됩니다.":"취소시 예약데이터가 삭제됩니다.", style: TextStyle(letterSpacing: 0.5, color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),),
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
                                              child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFF3478F6), fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
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
                                              child: Text("예약취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFFe7535c), fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                                          onTap:() async {
                                            int pre = (type == -1)?1:0;
                                            var url = Uri.parse("http://$speckUrl/bookingdelete");
                                            String body = ''' {
                                             "bookinfo" : $bookInfo,
                                             "pre" : $pre
                                            } ''';
                                            Map<String, String> header = {
                                              "Content-Type" : "application/json"
                                            };

                                            var response = await http.post(url, headers: header, body: body);
                                            var result = jsonDecode(utf8.decode(response.bodyBytes));
                                            print(result);
                                            var statusCode = result["statusCode"];
                                            print("result $result");
                                            if (statusCode == 202) {
                                              errorToast("예약이 취소되었습니다.");
                                              Navigator.pop(context);
                                            }
                                            else {
                                              errorToast("다시 시도해주세요.");
                                            }
                                            Navigator.pop(context);
                                          } ,
                                        )),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.cancel_outlined, size: _uiCriteria.textSize2, color: Colors.white,),
                Text(" 예약 취소하기", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),)
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _notice(BoxConstraints constraint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("- 환불은 탐험 시작일 전날 자정까지만 가능합니다.", style: TextStyle(
            fontSize: _uiCriteria.textSize5,
            fontWeight: FontWeight.w500,
            color: greyAAAAAA,
            letterSpacing: 0.5),),
        SizedBox(height: constraint.maxHeight * 0.0216,),
        Text("- 환불은 24시간 내에 이루어집니다.", style: TextStyle(
            fontSize: _uiCriteria.textSize5,
            fontWeight: FontWeight.w500,
            color: greyAAAAAA,
            letterSpacing: 0.5),),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            elevation: 0,
            content: AspectRatio(
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
                              Text("정말 취소하시겠어요?", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.screenWidth * 0.042, fontWeight: FontWeight.w700),),
                              Spacer(flex: 50),
                              Text("취소시 스펙 캐시로 환급됩니다.", style: TextStyle(letterSpacing: 0.5, color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),),
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
                                    child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFF3478F6), fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
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
                                    child: Text("예약취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFFe7535c), fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                                onTap:() async {
                                  var url = Uri.parse("http://$speckUrl/bookingdelete");
                                  String body = ''' {
                            "bookinfo" : $bookInfo}
                            } ''';
                                  Map<String, String> header = {
                                    "Content-Type" : "application/json"
                                  };

                                  var response = await http.post(url, headers: header, body: body);
                                  var result = jsonDecode(utf8.decode(response.bodyBytes));
                                  var statusCode = result["statusCode"];
                                  print("result $result");
                                  if (statusCode == 202) {
                                    errorToast("예약이 취소되었습니다.");
                                    Navigator.pop(context);
                                  }
                                  else {
                                    errorToast("다시 시도해주세요.");
                                  }
                                  Navigator.pop(context);
                                } ,
                              )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _cancelDialog(BuildContext context) {
    AlertDialog dialog = new AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      content: AspectRatio(
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
                        Text("정말 취소하시겠어요?", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.screenWidth * 0.042, fontWeight: FontWeight.w700),),
                        Spacer(flex: 50),
                        Text("취소시 스펙 캐시로 환급됩니다.", style: TextStyle(letterSpacing: 0.5, color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),),
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
                              child: Text("취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFF3478F6), fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
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
                              child: Text("예약취소", style: TextStyle(letterSpacing: 0.7, color: Color(0XFFe7535c), fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),)),
                          onTap:() async {
                            var url = Uri.parse("http://$speckUrl/bookingdelete");
                            String body = ''' {
                            "bookinfo" : $bookInfo}
                            } ''';
                            Map<String, String> header = {
                              "Content-Type" : "application/json"
                            };

                            var response = await http.post(url, headers: header, body: body);
                            var result = jsonDecode(utf8.decode(response.bodyBytes));
                            var statusCode = result["statusCode"];
                            print("result $result");
                            if (statusCode == 202) {
                              errorToast("예약이 취소되었습니다.");
                              Navigator.pop(context);
                            }
                            else {
                              errorToast("다시 시도해주세요.");
                            }
                            Navigator.pop(context);
                          } ,
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
    return dialog;
  }

  void _cancel(BuildContext context) async {
    var url = Uri.parse("http://$speckUrl/bookingdelete");
    String body = ''' {
      "bookinfo" : $bookInfo}
    } ''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    var statusCode = result["statusCode"];
    print("result $result");
    if (statusCode == 202) {
      errorToast("예약이 취소되었습니다.");
      Navigator.pop(context);
    }
    else {
      errorToast("다시 시도해주세요.");
    }
    Navigator.pop(context);
  }

  dynamic _getData() async {
    var url = Uri.parse("http://$speckUrl/mypage/mygalaxyDetail");
    String body = '''{
      "bookinfo" : $bookInfo
    }''';
    print("body $body");
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return result;
  }
  
  void _setData(dynamic data) {
    _checkList = data["calendarList"];
    dynamic result = data["myGalaxyDetail"];
    _official = result["official"];
    _galaxyName = result["galaxyName"];
    _timeNum = result["timeNum"];
    _attendCount = result["attendCount"];
    _totalCount = result["totalCount"];
    _startDate = result["startdate"];
    _endDate = result["enddate"];
    _paymentMethod = result["paymentMethod"];
    _deposit = result["deposit"];
    _totalPaid = result["totalPaid"];
    _getDust = result["getDust"];
    _getDeposit = result["getDeposit"];
    _getReward = result["getReward"];
    DateTime x1 = DateTime(DateTime.parse(_endDate).year, DateTime.parse(_endDate).month, 0).toUtc();
    _lastDayDay = DateTime(DateTime.parse(_endDate).year, DateTime.parse(_endDate).month + 1, 0).toLocal().difference(x1).inDays;
    _paymentId = result["paymentId"];
  }
  
}
