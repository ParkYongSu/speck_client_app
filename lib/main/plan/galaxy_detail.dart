import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Todo/state_time_sort.dart';
import 'package:speck_app/State/explorer_state.dart';
import 'package:speck_app/State/explorer_tab_state.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/main/explorer/explorer_detail.dart';
import 'package:speck_app/main/explorer/explorer_form.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import "package:http/http.dart" as http;
import 'package:speck_app/util/util.dart';

class GalaxyDetail extends StatefulWidget {
  final String galaxyName; // 학교이름
  final String imagePath; // 프로필
  final int galaxyNum; // 학교아이디
  final int official;
  final int route;

  GalaxyDetail(
  {Key key,
  @required this.galaxyName,
  @required this.imagePath,
  @required this.galaxyNum,
  @required this.official,
  @required this.route
  })
      : super(key : key);

  @override
  State createState() {
    return GalaxyDetailState();
  }
}

class GalaxyDetailState extends State<GalaxyDetail> {
  List<Widget> _popularList;
  dynamic _result;
  String _selectedDate;
  String _selectedDateText;
  String _selectedDateWeekdayText;
  int _totalReserveAM = 0; // 오전 총 예약
  int _totalReservePM = 0; // 오후 총 예약
  final UICriteria _uiCriteria = new UICriteria();
  List<Widget> _amList;
  List<Widget> _pmList;
  DateTime _current;
  int _diff;
  String _accumAtt;
  int _accumAttRank;
  String _accumDepo;
  int _accumDepoRank;
  String _avgDepo;
  List<dynamic> _timeList;
  ExplorerState _es;
  String _avgAttRank;
  String _avgAtt;
  String _message;
  List<dynamic> _hashTags;
  List<dynamic> _myTimeNumList;

  void initState() {
    super.initState();
    // 탐험단 상세페이지로 보낼 weekday
    _diff = 0;
    _selectedDateWeekdayText = "오늘";
    _current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _selectedDate = _current.toString().substring(0, 10);
    _selectedDateText = "${_current.year}.${_current.month}.${_current.day}";
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _es = Provider.of<ExplorerState>(context, listen: false);
    String imageUrl = widget.imagePath;
    return _galaxyDetail();
  }

  Widget _galaxyDetail() {
    return FutureBuilder(
      // future: _getPopularSortList(context),
      future: _getDetail(widget.galaxyNum),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == true) {
          _result = snapshot.data;
          _setData(_result);
          // _popularList = snapshot.data;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    children: <Widget>[
                      _galaxyImage(context),
                      /// 제목
                      _galaxyTitle(context, widget.official, widget.galaxyName, generateHashTags(context, _hashTags)),
                      /// 탐험단 정보
                      _galaxyInfo(_message, _accumAtt, _accumAttRank, _avgAtt, _avgAttRank, _accumDepo, _accumDepoRank, _avgDepo),
                      _reservationTips(),
                      _reservationByTime(context),
                      _authSystem(context)
                    ]
                )
            ),
          );
        }
        else {
          return loader(context, 0);
        }
      },
    );
  }

  /// 데이터 적용
  void _setData(dynamic result) async {
    // 모든 시간대별 리스트를 가져옴, 총 예약자 수, 인증 수
    dynamic galaxyDetail = result["galaxyDetail"];
    _accumAtt = galaxyDetail["accumAtt"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');;
    _accumAttRank = galaxyDetail["accumAttRank"];
    _accumDepo = galaxyDetail["accumDeposit"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    _accumDepoRank = galaxyDetail["accumDepositRank"];
    _avgDepo = galaxyDetail["avgDeposit"].round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    _timeList = result["timeList"];
    _myTimeNumList = galaxyDetail["myTimeNumList"];
    print(">>>>>>>>>>>>>>>>>> $_myTimeNumList");
    _avgAttRank = galaxyDetail["avgAttRank"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    _avgAtt = galaxyDetail["avgAtt"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    _message = galaxyDetail["oneLineMessage"];
    _hashTags = galaxyDetail["hashTags"];
    // 리스트를 인기순으로 정렬

    _updateTimeList(_timeList);
  }

  void _updateTimeList(List<dynamic> timeList) {
    List<Widget> popularSortList = [];
    List<Widget> amWidget = [];
    List<Widget> pmWidget = [];
    _timeSelectionSort(timeList, "timenum");
    _popularSelectionSort(timeList, "total");
    print(timeList);
    int totalReserveAM = 0;
    int totalReservePM = 0;
    // 위젯으로 리턴
    for (int i = 0; i < timeList.length; i++) {

      int timeNum = timeList[i]["timenum"];
      String time = getAuthTime(timeNum);
      int att = timeList[i]["att"];
      int total = timeList[i]["total"];
      List<int> am = <int>[1, 2, 3, 4, 17, 18, 19, 20, 21, 22, 23, 24];
      // List<int> pm = <int>[5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

      if (am.contains(timeNum)) {
        totalReserveAM += total;
        amWidget.add(
            _ampm(time, timeNum, att, total, amWidget)
        );
      }
      else {
        totalReservePM += total;
        pmWidget.add(
            _ampm(time, timeNum, att, total, pmWidget)
        );
      }
      // if (popularSortList.length != 5) {
      //   popularSortList.add(
      //       _popular(timeNum, popularSortList, time, att, total)
      //   );
      // }
    }
    timeList = timeList.reversed.toList().sublist(0, 5).reversed.toList();

    for (int i = 0; i < 5; i++) {
      int timeNum = timeList[i]["timenum"];
      String time = getAuthTime(timeNum);
      int att = timeList[i]["att"];
      int total = timeList[i]["total"];
      popularSortList.add(
          _popular(timeNum, popularSortList, time, att, total)
      );
    }

    _totalReserveAM = totalReserveAM;
    _totalReservePM = totalReservePM;
    _popularList = popularSortList;
    _amList = amWidget;
    _pmList = pmWidget;
  }

  void _setExplorerState(int timeNum) {
    _es.setGalaxyName(widget.galaxyName);
    _es.setGalaxyNum(widget.galaxyNum);
    _es.setImagePath(widget.imagePath);
    _es.setOfficial(widget.official);
    _es.setRoute(widget.route);
    _es.setSelectedDate(_selectedDate);
    _es.setSelectedDateWeekdayText(_selectedDateWeekdayText);
    _es.setTimeList(_myTimeNumList);
    _es.setTimeNum(timeNum);
    _es.setTotalPayment(_accumDepo);
  }

  Widget _ampm(String time, int timeNum, int att, int total, List<Widget> ampm) {
    return GestureDetector(
      onTap: (widget.route == 1)
        ? () => _timeTap1(timeNum)
        :() {
        _setExplorerState(timeNum);
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => ExplorerForm(route: widget.route,)));
      },
      child: Container(
        margin: EdgeInsets.only(left: (ampm.length == 11)?_uiCriteria.horizontalPadding:0, right: _uiCriteria.screenWidth * 0.032),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6.9)),
            border: Border.all(color: greyB3B3BC, width: 0.5)
        ),
        width: _uiCriteria.screenWidth * 0.192,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 32,
              child: Container(
                alignment: Alignment.center,
                child: Text(time, style: TextStyle(letterSpacing: -0.28, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              flex: 21,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.9), bottomRight: Radius.circular(6.9)),
                    color: greyF5F5F6
                ),
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, color: mainColor),
                      children: <TextSpan>[
                        TextSpan(text: "$att명"),
                        TextSpan(text: "/$total명", style: TextStyle(color: Color(0XFFE7535C))),
                      ]
                  ),
                ),
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Text("$authMembers명", style: TextStyle(color: Colors.red, fontSize: 12.0),),
                //     Text("/$allMembers명", style: TextStyle(fontSize: 12.0),)
                //   ],
                // ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _popular(int timeNum, List<Widget> popularSortList, String time, int att, int total) {
    return GestureDetector(
      onTap: (widget.route == 1)
      ? () => _timeTap1(timeNum)
      :(){
        _setExplorerState(timeNum);
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => ExplorerForm(route: widget.route,)));
      },
      child: Container(
          margin: EdgeInsets.only(left: (popularSortList.length == 4)? _uiCriteria.horizontalPadding : 0, right: _uiCriteria.screenWidth * 0.032),
          width: _uiCriteria.screenWidth * 0.3493,
          decoration: BoxDecoration(
              border: Border.all(color: Color(0XFFB3B3BC), width: 0.5),
              borderRadius: BorderRadius.circular(6.9)
          ),
          child: Column(
              children: <Widget>[
                Expanded(
                    flex: 59,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.016, vertical:  _uiCriteria.screenWidth * 0.016),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(
                                          color:
                                          (popularSortList.length == 2)
                                              ? Color(0XFFE2C28B)
                                              : (popularSortList.length == 3)
                                              ? greyD8D8D8
                                              : (popularSortList.length == 4)
                                              ? mainColor
                                              : Colors.transparent, width: 1.5
                                      ))
                                  ),
                                  child: Text(time, style: TextStyle(letterSpacing: -0.32, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1)))),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              (popularSortList.length == 2)
                                  ? Image.asset(
                                "assets/png/dust_icon.png",
                                height: _uiCriteria.textSize4,
                                color: Color(0XFFE2C28B),
                              )
                                  : (popularSortList.length == 3)
                                  ? Image.asset(
                                "assets/png/dust_icon.png",
                                height: _uiCriteria.textSize4,
                                color: greyD8D8D8,
                              )
                                  : (popularSortList.length == 4)
                                  ? Image.asset(
                                "assets/png/dust_icon.png",
                                height: _uiCriteria.textSize4,
                                color: mainColor,
                              )
                                  : Container(),
                              (popularSortList.length == 2)
                                  ? Text("3", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)
                                  : (popularSortList.length == 3)
                                  ? Text("2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)
                                  : (popularSortList.length == 4)
                                  ? Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)
                                  : Text("")
                            ],
                          )
                        ],
                      ),
                    )

                ),
                Expanded(
                  flex: 35,
                  child: Container(
                    decoration: BoxDecoration(
                        color: greyF5F5F6,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.9), bottomRight: Radius.circular(6.9))
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("$att명", style: TextStyle(color: Color(0XFFE7735C), fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500),),
                          Text("/$total명", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500),)
                        ]
                    ),
                  ),
                ),
              ]
          )
      ),
    );
  }

  /// 날짜 선택 위젯
  Widget _dateTimeWidget() {
    return AspectRatio(
      aspectRatio: 375/40,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.025),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
                onTap: () => _onTapLeft(),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent)
                    ),
                    child: Icon(Icons.chevron_left_sharp, color: mainColor,))),
            RichText(text: TextSpan(
                style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),
                children: <TextSpan>[
                  TextSpan(text: _selectedDateText),
                  TextSpan(text: "  $_selectedDateWeekdayText", style: TextStyle(color: Color(0XFFE7535C)))
                ]
            )),
            GestureDetector(
                onTap: () => _onTapRight(),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent)
                    ),
                    child: Icon(Icons.chevron_right_sharp, color: mainColor,))),
          ],
        ),
      ),
    );
  }

  void _getDateLeft(int diff, int weekday) {
    if (diff == 1) {
      _selectedDateWeekdayText = "내일";
    }
    else if (diff == 0) {
      _selectedDateWeekdayText = "오늘";
    }
    else {
      switch(weekday) {
        case 1:
          _selectedDateWeekdayText = "월";
          break;
        case 2:
          _selectedDateWeekdayText = "화";
          break;
        case 3:
          _selectedDateWeekdayText = "수";
          break;
        case 4:
          _selectedDateWeekdayText = "목";
          break;
        case 5:
          _selectedDateWeekdayText = "금";
          break;
        case 6:
          _selectedDateWeekdayText = "토";
          break;
        case 7:
          _selectedDateWeekdayText = "일";
          break;
      }
    }
  }

  void _getDateRight(int diff, int weekday) {
    if (diff == 1) {
      _selectedDateWeekdayText = "내일";
    }
    else {
      switch(weekday) {
        case 1:
          _selectedDateWeekdayText = "월";
          break;
        case 2:
          _selectedDateWeekdayText = "화";
          break;
        case 3:
          _selectedDateWeekdayText = "수";
          break;
        case 4:
          _selectedDateWeekdayText = "목";
          break;
        case 5:
          _selectedDateWeekdayText = "금";
          break;
        case 6:
          _selectedDateWeekdayText = "토";
          break;
        case 7:
          _selectedDateWeekdayText = "일";
          break;
      }
    }
  }

  // /// 탭을 눌렀을 때 시간별 데이터를 가져옴
  // void _getTimeList() async {
  //   var url = Uri.parse("http://$speckUrl/galaxy/detail/timelist");
  //   String body = """{
  //     "galaxyNum":${widget.galaxyNum},
  //     "dateInfo":"$_selectedDate"
  //   }""";
  //   print(body);
  //   Map<String, String> header = {
  //     "Content-Type" : "application/json"
  //   };
  //   var response = await http.post(url, body: body, headers: header);
  //   dynamic result = jsonDecode(response.body);
  //   print("시간 $result");
  //   _updateTimeList(result);
  // }

  void _onTapLeft() async {
    DateTime date = DateTime.parse(_selectedDate);
    setState(() {
      if (_diff > 0) {
        date = date.add(Duration(days: - 1));
        _diff = date.difference(_current).inDays;
        _selectedDate = date.toString().substring(0, 10);
        _selectedDateText = "${date.year}.${date.month}.${date.day}";
        _getDateLeft(_diff, date.weekday);
        // _getTimeList();
      }
    });
  }

  void _onTapRight() {
    DateTime date = DateTime.parse(_selectedDate);
    setState(() {
      if (_diff < 30) {
        date = date.add(Duration(days: 1));
        _diff = date.difference(_current).inDays;
        _selectedDate = date.toString().substring(0, 10);
        _selectedDateText = "${date.year}.${date.month}.${date.day}";
        _getDateRight(_diff, date.weekday);
        // _getTimeList();
      }
    });
  }

  Widget _reservationByTime(BuildContext context) {
    return Column(
      children: <Widget>[
        greyBar(),
        _dateTimeWidget(),
        _popularTimes(),
        greyBar(),
        Column(
          children: <Widget>[
            _totalReserveTitle(),
            _amTimes(),
            _pmTimes()
          ],
        )
      ],
    );
  }

  Widget _pmTimes() {
    return AspectRatio(
      aspectRatio: 375/128.5,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
            padding: EdgeInsets.only(top: constraint.maxHeight * 0.1789),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "오후", style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, color: mainColor)),
                          TextSpan(text: "  예약자 $_totalReservePM명", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, color: greyAAAAAA, fontWeight: FontWeight.w500))
                        ]
                    ),
                  ),
                ),
                SizedBox(height: constraint.maxHeight * 0.0856),
                Container(
                  width: _uiCriteria.screenWidth,
                  height: constraint.maxHeight * 0.4124,
                  child: Scrollbar(
                    child: Container(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pmList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _pmList[_pmList.length - index - 1];
                          }),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _amTimes() {
    return AspectRatio(
      aspectRatio: 375/128.5,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            padding: EdgeInsets.only(top: constraint.maxHeight * 0.1789),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "오전", style: TextStyle(letterSpacing: 0.7, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, color: mainColor)),
                          TextSpan(text: "  예약자 $_totalReserveAM명", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, color: greyAAAAAA, fontWeight: FontWeight.w500))
                        ]
                    ),
                  ),
                ),
                SizedBox(height: constraint.maxHeight * 0.0856),
                Container(
                  width: _uiCriteria.screenWidth,
                  height: constraint.maxHeight * 0.4124,
                  child: Scrollbar(
                    child: Container(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _amList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _amList[_amList.length - index - 1];
                          }),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _totalReserveTitle() {
    return AspectRatio(
      aspectRatio: 375/40,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, color: mainColor),
                  children: <TextSpan>[
                    TextSpan(text: "총 예약자"),
                    TextSpan(text: " ${_totalReserveAM + _totalReservePM}명", style: TextStyle(color: Color(0XFFE7535C)))
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popularTimes() {
    return AspectRatio(
      aspectRatio: 375/170,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            padding: EdgeInsets.only(top: constraint.maxHeight * 0.1352),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                      child: Text("인기 시간대", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)),
                  SizedBox(height: constraint.maxHeight * 0.0706,),
                  Container(
                      height: constraint.maxHeight * 0.5529,
                      child: Scrollbar(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _popularList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _popularList[_popularList.length - index - 1];
                            }),
                      )
                  )
                ]
            ),
          );
        },
      ),
    );

  }

  void _showSortList(BuildContext context) {
    TimeSort timeSort = Provider.of<TimeSort>(context, listen: false);
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13.8)
        ),
        context: context,
        builder: (BuildContext context) {
          return AspectRatio(
            aspectRatio: 375/194,
            child: Container(
              child: Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 375/41.8,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
                      ),
                      alignment: Alignment.center,
                      child: Text("정렬", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1))
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      timeSort.setSortName("예약자순");
                      Navigator.pop(context);
                    },
                    child: AspectRatio(
                      aspectRatio: 375/39.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("예약자순", style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500),),
                            (timeSort.getSortName() == "예약자순")
                                ? Icon(Icons.check_circle, color: Color(0XFFFFED5A),)
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      timeSort.setSortName("시간 오름차순");
                      Navigator.pop(context);
                    },
                    child: AspectRatio(
                      aspectRatio: 375/39.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("시간 오름차순", style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500),),
                            (timeSort.getSortName() == "시간 오름차순")
                                ? Icon(Icons.check_circle, color: Color(0XFFFFED5A),)
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      timeSort.setSortName("시간 내림차순");
                      Navigator.pop(context);
                    },
                    child: AspectRatio(
                      aspectRatio: 375/39.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("시간 내림차순", style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500),),
                            (timeSort.getSortName() == "시간 내림차순")
                                ? Icon(Icons.check_circle, color: Color(0XFFFFED5A),)
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
          );
        });
  }

  Widget _galaxyImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/246,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.imagePath),
                fit: BoxFit.fitWidth,

              // image: NetworkImage(widget.imagePath)
            )
        ),
      ),
    );
  } // 갤럭시 대표

  /// 갤럭시 타이틀
  Widget _galaxyTitle(BuildContext context, int type, String galaxyName, List<Widget> hashTags) {
    return AspectRatio(
      aspectRatio: 375/118.8,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: constraint.maxHeight * 0.0959),
                  (type == 1)
                      ?Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Image.asset("assets/png/speck_public.png", height: constraint.maxHeight * 0.1986,),
                            Text("  SPECK 공식", style: TextStyle(letterSpacing: 0.6, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3, color: greyAAAAAA),)
                          ]
                      )
                  )
                      : Container(),
                  SizedBox(height: constraint.maxHeight * 0.0589),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: _uiCriteria.screenWidth,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                (type == 1)
                                    ? AutoSizeText("[공식] $galaxyName",
                                  style: TextStyle(letterSpacing: 1.04, color: mainColor, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                                    : AutoSizeText(galaxyName,
                                  style: TextStyle(letterSpacing: 1.04, color: mainColor, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(
                                    width: _uiCriteria.textSize1
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.016, vertical: constraint.maxHeight * 0.0252),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: mainColor),
                                      borderRadius: BorderRadius.circular(5.0)
                                  ),
                                  child: Text("모집중", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                )
                              ],
                            ),
                            SizedBox(height: constraint.maxHeight * 0.1010,),
                            Row(
                                children: (hashTags.isNotEmpty)
                                    ? hashTags
                                    : []
                            )
                          ]
                      )
                  )
                ],
              )
          );
        },
      ),
    );
  }

  /// 갤럭시 정보
  Widget _galaxyInfo(String message, String accumAtt, int accumAttRank, String avgAtt, String avgAttRank, String accumDepo, int accumDepoRank, String avgDepo) {
    return AspectRatio(
      aspectRatio: 375/195.8,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.1215),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset("assets/png/deco1.png", color: mainColor, height: constraint.maxHeight * 0.0664,),
                      Text("리더의 한마디", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, color: greyAAAAAA, fontWeight: FontWeight.w500)),
                      Image.asset("assets/png/deco2.png", color: mainColor, height: constraint.maxHeight * 0.0664,)
                    ],
                  ),
                  Spacer(
                      flex: 50
                  ),
                  // SizedBox(height: constraint.maxHeight * 0.0306),
                  Container(
                      child: Text(
                        message,
                        style: TextStyle(letterSpacing: 0.7, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500),)),
                  // SizedBox(height: constraint.maxHeight * 0.0383),
                  Spacer(
                      flex: 75
                  ),
                  Container(
                    width: constraint.maxWidth,
                    height: 1.5,
                    color: greyD8D8D8,
                  ),
                  Spacer(
                      flex: 230
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset("assets/png/dust_profile.png", height: constraint.maxHeight * 0.0664),
                      SizedBox(width: constraint.maxWidth * 0.032),
                      Container(
                        child: Text("누적 출석인원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                      ),
                      SizedBox(width: constraint.maxWidth * 0.032),
                      RichText(
                        text: TextSpan(
                            style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: mainColor),
                            children: <TextSpan>[
                              TextSpan(text: "${accumAtt.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명"),
                              TextSpan(text: "($accumAttRank위)", style: TextStyle(color: greyAAAAAA))
                            ]
                        ),
                      )
                      // Container(
                      //   child: Row(
                      //     children: <Widget>[
                      //       Text("${widget.sumPerson}명", style: TextStyle(fontSize: 12.0),),
                      //       Text("(1위)", style: TextStyle(fontSize: _uiCriteria.textSize3, color: Color(0XFFB3B3BC), fontWeight: FontWeight.bold),),
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                  Spacer(
                      flex: 100
                  ),
                  // SizedBox(
                  //   height: constraint.maxHeight * 0.0612,
                  // ),
                  Row(
                    children: <Widget>[
                      Image.asset("assets/png/dust_check.png", height: constraint.maxHeight * 0.0664,),
                      SizedBox(width: constraint.maxWidth * 0.032),
                      Container(
                        child: Text("평균 출석인원", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                      ),
                      SizedBox(width: constraint.maxWidth * 0.032),
                      RichText(
                        text: TextSpan(
                            style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: mainColor),
                            children: <TextSpan>[
                              TextSpan(text: "${avgAtt.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명"),
                              TextSpan(text: "($avgAttRank위)", style: TextStyle(color: greyAAAAAA))
                            ]
                        ),
                      ),
                    ],
                  ),
                  Spacer(
                      flex: 100
                  ),
                  // SizedBox(
                  //   height: constraint.maxHeight * 0.0612,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset("assets/png/dust_won.png", height: constraint.maxHeight * 0.0664,),
                      SizedBox(width: constraint.maxWidth * 0.032),
                      Container(
                        child: Text("누적 보증금액", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                      ),
                      SizedBox(width: constraint.maxWidth * 0.032),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: mainColor),
                                children: <TextSpan>[
                                  TextSpan(text: "$accumDepo원"),
                                  TextSpan(text: "($accumDepoRank위)", style: TextStyle(color: greyAAAAAA))
                                ]
                            ),
                          ),
                          SizedBox(height: constraint.maxHeight * 0.0153,),
                          Text("평균적으로 하루에 $avgDepo원을 걸었어요", style: TextStyle(letterSpacing: 0.5, color: greyAAAAAA, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),)
                        ],
                      ),

                    ],
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  /// 예약 팁
  Widget _reservationTips() {
    return AspectRatio(
      aspectRatio: 375/162,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.1111),
              decoration: BoxDecoration(
                  color: greyF5F5F6,
                  border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    // width: constraint.maxWidth,
                    // height: constraint.maxHeight * 0.2469,
                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.0679),
                    decoration: BoxDecoration(
                        color: Colors.white
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset("assets/png/dust_icon.png", height: _uiCriteria.textSize1,),
                          Text("나만의 자유로운 일정 예약 방법", style: TextStyle(letterSpacing: 0.5, color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),),
                          Image.asset("assets/png/dust_icon.png", height: _uiCriteria.textSize1,),
                        ]
                    ),
                  ),
                  Spacer(
                    flex: 11,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("첫번째  시간대 선택하기", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                        Row(
                          children: <Widget>[
                            Text("첫번째  ", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: Colors.transparent)),
                            Text("시간대를 선택해 탐험단의 정보와 탐험단원들을 확인해 보세요.", style: TextStyle(letterSpacing: 0.5, color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500,),)
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("두번째  예약 날짜 선택하기", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                        Row(
                          children: <Widget>[
                            Text("두번째  ", style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: Colors.transparent)),
                            Text("원하는 기간 혹은 요일을 자유롭게 선택할 수 있어요.(하루~한달)", style: TextStyle(letterSpacing: 0.5, color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500,),)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  } // 인증 방법

  /// 인증시스템

  Widget _authSystem(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white
        ),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 375/11.8,
              child: Container(
                color: greyF0F0F1,
              ),
            ),
            _authTip(),
            Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),

        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _authScan(),
                    SizedBox(width: _uiCriteria.screenWidth * 0.04533,),
                    _authGPS(),
                  ]
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _authTime(),
                    SizedBox(width: _uiCriteria.screenWidth * 0.04533,),
                    _authReward(),
                  ]
              )
            ]
        ),
      )
          ],
        )
    );
  }

  Widget _authTime() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 163/205.5,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
                children: <Widget>[
                  Spacer(flex: 390,),
                  Padding(
                    padding: EdgeInsets.only(left: constraint.maxWidth * 0.2085, right: constraint.maxWidth * 0.1288),
                    child: AspectRatio(
                        aspectRatio: 100.2/83.2,
                        child: Image.asset("assets/png/auth_way1.png", fit: BoxFit.fill,)),
                  ),
                  Spacer(flex: 247,),
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: greyD8D8D8.withOpacity(0.5),
                  ),
                  Spacer(flex: 103,),
                  Text("출석 인증은 예약된 시간", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 50,),
                  Text("1시간 전부터 가능해요.", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 220,),
                ]
            );
          },
        ),
      ),
    );
  } // 인증 시간

  void _timeTap1(int timeNum) {
    ExplorerTabState ets = Provider.of<ExplorerTabState>(context, listen: false);
    _setExplorerState(timeNum);
    ets.setTabIndex2(1);
  }

  Widget _authGPS() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 163/212.2,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
                children: <Widget>[
                  Spacer(flex: 130),
                  Container(
                    padding: EdgeInsets.only(left: constraint.maxWidth * 0.2499, right: constraint.maxWidth * 0.0996),
                    child: AspectRatio(
                        aspectRatio: 99.5/89.4,
                        child: Image.asset("assets/png/auth_way2.png", fit: BoxFit.fill,)),
                  ),
                  Spacer(flex: 248),
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: greyD8D8D8.withOpacity(0.5),
                  ),
                  Spacer(flex: 103,),
                  Text("인증 방법 2", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),),
                  Spacer(flex: 50,),
                  Text("이동거리를 GPS로 측정하여", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 50,),
                  Text("집밖 출석을 인증!", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 50,),
                  Text("(전 지역에서 가능해요)", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),

                ]
            );
          },
        ),
      ),
    );
  } // 인증 장소

  Widget _authTip() {
    return AspectRatio(
      aspectRatio: 375/40,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
          ),
          child: Row(
            children: [
              Text("인증 방법 안내 ", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),),
              Text("방법 1, 2 중 택일", style: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),)
            ],
          )
      ),
    );
  }

  Widget _authScan() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 163/212.2,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
                children: <Widget>[
                  Spacer(flex: 231,),
                  Container(
                    padding: EdgeInsets.only(left: constraint.maxWidth * 0.1665, right: constraint.maxWidth * 0.1088),
                    child: AspectRatio(
                        aspectRatio: 111.6/82.7,
                        child: Image.asset("assets/png/auth_way3.png",fit: BoxFit.fill,)),
                  ),
                  Spacer(flex: 217,),
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: greyD8D8D8.withOpacity(0.5),
                  ),
                  Spacer(flex: 103,),
                  Text("인증 방법 1", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),),
                  Spacer(flex: 50,),
                  Text("스펙존의 QR코드를 스캔하여", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 50,),
                  Text("집밖 출석을 인증!", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 50,),
                  Text("(스펙존에서만 가능해요)", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                ]
            );
          },
        ),
      ),
    );
  } // 인증하는 방법

  Widget _authReward() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 163/205.5,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
                children: <Widget>[
                  Spacer(flex: 348,),
                  Padding(
                    padding: EdgeInsets.only(left: constraint.maxWidth * 0.1169, right: constraint.maxWidth * 0.0896),
                    child: AspectRatio(
                      aspectRatio: 119.1/87.2,
                      child: Image.asset("assets/png/auth_way4.png", fit: BoxFit.fill,)),
                  ),
                  Spacer(flex: 235,),
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: greyD8D8D8.withOpacity(0.5),
                  ),
                  Spacer(flex: 103,),
                  Text("집밖 출석을 인증하면", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 50,),
                  Text("보증금 페이백 + 상금을 받아요!", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                  Spacer(flex: 220,),
                ]
            );
          },
        )
      ),
    );
  } // 인증 보상

// 갤럭시 상세 페이지에서 클래스 시간별 유저정보들을 가져옴
  Future<dynamic> _getDetail(int galaxyNum) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    var url = Uri.parse("http://$speckUrl/galaxy/detail");
    String body = '''{
      "userEmail": "$email",
      "galaxyNum":$galaxyNum,
      "dateInfo" : "$_selectedDate"
    }''';
    print(body);
    Map<String, String> header = {
      "Content-Type" : "application/json",
    };
    var response = await http.post(url, body: body, headers: header);
    dynamic result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return Future(() {
      return result;
    });
  }

   // 시간 정렬(선택정렬)
  void _timeSelectionSort(List<dynamic> list, String key) {
    for (int i = 0; i < list.length - 1; i++) {
      int min = i;
      for (int j = i + 1; j < list.length; j++) {
        int m = (list[min]["$key"] < 17)?list[min]["$key"] + 7 : list[min]["$key"] - 17;
        int t = (list[j]["$key"] < 17)?list[j]["$key"] + 7 : list[j]["$key"] - 17;
        if (m < t) {
          min = j;
        }
      }
      dynamic temp = list[i];
      list[i] = list[min];
      list[min] = temp;
    }
  }

  void _popularSelectionSort(List<dynamic> list, String key) {
    for (int i = 0; i < list.length - 1; i++) {
      int min = i;
      for (int j = i + 1; j < list.length; j++) {
        int m = (list[min]["$key"] < 17)?list[min]["$key"] + 7 : list[min]["$key"] - 17;
        int t = (list[j]["$key"] < 17)?list[j]["$key"] + 7 : list[j]["$key"] - 17;
        if (m > t) {
          min = j;
        }
      }
      dynamic temp = list[i];
      list[i] = list[min];
      list[min] = temp;
    }
  }
}