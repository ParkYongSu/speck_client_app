import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/State/explorer_state.dart';
import 'package:speck_app/Time/myInfo_timer.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/reservation/reservation_page.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';

class ExplorerDetail extends StatefulWidget {
  final int route;

  const ExplorerDetail({Key key, @required this.route}) : super(key: key);
  @override
  _ExplorerDetailState createState() => _ExplorerDetailState();
}

class _ExplorerDetailState extends State<ExplorerDetail> {

  bool _myInfo;
  bool _benefit;
  bool _invite;
  List<Widget> _usersList;
  int _allCount = 0;
  int _authCount = 0;
  bool _panelOpened;
  List<dynamic> result; // 탐험단 시간별 유저
  dynamic galaxyInfo; // 갤럭시 정보, 누적 상금 등
  String _selectedDateText;
  DateTime _current;
  int _diff;
  String _time;
  String _nickname;
  int _myCharacterIndex;
  int _explorerRank;
  int _attCount;
  int _todayCount;
  String _galaxyName; // 학교이름
  String _imagePath; // 프로필
  String _totalPayment; // 누적 보증
  int _sumPerson; // 누적인원
  int _galaxyNum; // 학교아이디
  int _timeNum;
  int _official;
  String _selectedDate;
  String _selectedDateWeekdayText;
  List<dynamic> _timeList;
  int _myAttendCount;
  int _myTotalCount;
  int _myAttendRate;
  int _myDeposit;
  int _totalDeposit;
  int _accumPrize;
  int _dust;
  int _totalDust;
  String _nextReserveTime;
  String _avgAtt;
  int _avgAttRate;
  int _remainingTime;
  MyInfoTimer _myInfoTimer;
  int _bookInfo;

  @override
  void initState() {
    super.initState();
    _myInfo = false;
    _benefit = false;
    _invite = false;
    _usersList = <Widget>[];
    _panelOpened = false;
    _setNickAndChar();
  }


  @override
  void dispose() {
    super.dispose();
    _myInfoTimer.stopTimer();
  }

  final UICriteria _uiCriteria = new UICriteria();
  ExplorerState _es;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _es = Provider.of<ExplorerState>(context, listen: false);
    _galaxyName = _es.getGalaxyName(); // 학교이름
    _imagePath = _es.getImagePath();// 프로필
    _totalPayment = _es.getTotalPayment(); // 누적 보증
    _sumPerson = _es.getSumPerson(); // 누적인원
    _galaxyNum = _es.getGalaxyNum(); // 학교아이디
    _timeNum = _es.getTimeNum();
    _official = _es.getOfficial();
    _selectedDate = _es.getSelectedDate();
    _selectedDateWeekdayText = _es.getSelectedDateWeekdayText();
    _timeList = _es.getTimeList();
    _time = getAuthTime(_timeNum);
    _selectedDateText = "${DateTime.parse(_selectedDate).year}.${DateTime.parse(_selectedDate).month}.${DateTime.parse(_selectedDate).day}";
    _current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _diff = DateTime.parse(_selectedDate).difference(_current).inDays;
    _myInfoTimer = Provider.of<MyInfoTimer>(context, listen: true);
    return FutureBuilder(
        future: _explorer(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == true) {
            return snapshot.data;
          }
          else {
            return Container(
                decoration: BoxDecoration(
                    color: mainColor
                ),
                alignment: Alignment.center,
                width: _uiCriteria.screenWidth,
                height: _uiCriteria.totalHeight,
                child: Container(
                    width: _uiCriteria.screenWidth * 0.0666,
                    height: _uiCriteria.screenWidth * 0.0666,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                )
            );
          }
        }
      );
  }

  void _selectionSort(List<dynamic> userList) {
    for (int i = 0; i < userList.length - 1; i++) {
      int max = i;
      for (int j = i + 1; j < userList.length; j++) {
        if (userList[max]["attendvalue"] < userList[j]["attendvalue"]) {
          max = j;
        }
      }
      dynamic temp = userList[i];
      userList[i] = userList[max];
      userList[max] = temp;
    }
    userList = userList.reversed.toList();
  }

  /// 탐험단 서버 완료 후 수정
  Future<Widget> _explorer(BuildContext context) async {
    Map<String, dynamic> result;
    List<Widget> userList = [];
    // todo. shcoolId, classId 가져오기
    Future future = _getExplorerInfo(_galaxyNum, _timeNum, _selectedDate);
    await future.then((value) => result = value, onError: (e) => print(e));
    _avgAtt = result["avgAtt"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    _avgAttRate = result["avgAttRate"];
    _todayCount = result["todayCount"];
    _attCount = result["attCount"];
    _explorerRank = result["explorerRank"];
    _bookInfo = result["bookInfo"];
    List<dynamic> explorerTodayList = result["explorerTodayList"];
    _selectionSort(explorerTodayList);
    for (int i = 0; i < explorerTodayList.length; i++) {
      _allCount += 1;
      dynamic user = explorerTodayList[i];
      String imagePath = user["imgPath"];
      String nickname = user["nickName"];
      int characterIndex = user["character"];
      int attendValue = user["attendvalue"];
      int countAtt = user["countAtt"];

      userList.add(
          _userInfo(context, nickname, countAtt, characterIndex, attendValue)
      );
    }
    _usersList = userList;

    return Future(() {
      return Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _background(context, _avgAtt, _avgAttRate),
            _slidingPanel(context)
          ],
        ),
      );
    });
  }

  /// 아래 캐릭터
  Widget _userInfo(BuildContext context, String nickname, int countAtt, int characterIndex, int attendValue) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: _uiCriteria.screenWidth * 0.1554,
            height: _uiCriteria.screenWidth * 0.1538,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage((attendValue == 1)?getCharacter(characterIndex):getSleepCharacter(characterIndex),),
                    fit: BoxFit.fill
                ),
                // boxShadow: [BoxShadow(color: shadowColor(characterIndex), blurRadius: 12, spreadRadius: 6, offset: Offset(0,3))]
            ),
          ),
          Spacer(flex: 20,),
          Text(nickname, style: TextStyle(letterSpacing: 0.6, color: mainColor, fontWeight: FontWeight.w600, fontSize: _uiCriteria.textSize3)),
          Spacer(flex: 6,),
          Text("출석 $countAtt", style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.w600, fontSize: _uiCriteria.textSize5, color: greyAAAAAA),),
        ]
    );
  }

  /// 뒷배경
  Widget _background(BuildContext context, String attendNum, int rate) {
    return Container(
      decoration: BoxDecoration(
        color: mainColor
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Stack(
            children: [
              Container(
                  child: Image.asset("assets/png/explorer_background1.png", fit: BoxFit.fill,)),
              (!_timeList.contains(_timeNum))
              ? Container()
              : Container(
                  child: Image.asset("assets/png/explorer_background1.png", fit: BoxFit.fill,)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0283),
            width: _uiCriteria.screenWidth,
            height: _uiCriteria.totalHeight,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              (_official == 1)
                                  ? Text("[공식] $_galaxyName ", style: TextStyle(letterSpacing: 0.9, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize4))
                                  : Text("$_galaxyName ", style: TextStyle(letterSpacing: 0.9, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize4)),
                              InkWell(
                                onTap: () {
                                  _showTimeTable(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.02, vertical: _uiCriteria.screenWidth * 0.005),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width :1.5),
                                      borderRadius: BorderRadius.circular(6.9)
                                  ),
                                  child: Text( "$_time", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),),
                                ),
                              )
                            ],
                          ),
                          AspectRatio(aspectRatio: 375/6),
                          Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  RichText(
                                      text: TextSpan(
                                          style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
                                          children: <TextSpan>[
                                            TextSpan(text: "평균 출석률", style: TextStyle(color: greyD8D8D8),),
                                            TextSpan(text: " ${double.parse(rate.toStringAsFixed(1))}%  ", style: TextStyle(color: Colors.white))
                                          ]
                                      )
                                  ),
                                  Container(
                                    width: 1,
                                    height: _uiCriteria.textSize3,
                                    color: greyD8D8D8,
                                  ),
                                  RichText(
                                      text: TextSpan(
                                          style: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
                                          children: <TextSpan>[
                                            TextSpan(text: "  평균 출석 인원", style: TextStyle(color: greyD8D8D8),),
                                            TextSpan(text: " $attendNum명", style: TextStyle(color: Colors.white))
                                          ]
                                      )
                                  ),
                                ]
                            ),
                          )
                        ]
                    ),
                  ),
                  AspectRatio(aspectRatio: 375/10),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset((!_timeList.contains(_timeNum))?"assets/png/planet_draw.png":"assets/png/explorer_draw_color.png",),
                    ),
                  ),
                  AspectRatio(aspectRatio: 375/10),
                  /// 받침
                  Container(
                    height: (widget.route == 0)?(uiCriteria.totalHeight - uiCriteria.appBarHeight) * 0.55 : (uiCriteria.totalHeight - uiCriteria.appBarHeight - uiCriteria.totalHeight * 0.049) * 0.55,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getDateLeft(int diff, int weekday) {
    if (diff == 1) {
      _es.setSelectedDateWeekdayText("내일");
    }
    else if (diff == 0) {
      _es.setSelectedDateWeekdayText("오늘");
    }
    else {
      switch(weekday) {
        case 1:
          _es.setSelectedDateWeekdayText("월");
          break;
        case 2:
          _es.setSelectedDateWeekdayText("화");
          break;
        case 3:
          _es.setSelectedDateWeekdayText("수");
          break;
        case 4:
          _es.setSelectedDateWeekdayText("목");
          break;
        case 5:
          _es.setSelectedDateWeekdayText("금");
          break;
        case 6:
          _es.setSelectedDateWeekdayText("토");
          break;
        case 7:
          _es.setSelectedDateWeekdayText("일");
          break;
      }
    }
  }

  void _getDateRight(int diff, int weekday) {
    if (diff == 1) {
      _es.setSelectedDateWeekdayText("내일");
    }
    else {
      switch(weekday) {
        case 1:
          _es.setSelectedDateWeekdayText("월");
          break;
        case 2:
          _es.setSelectedDateWeekdayText("화");
          break;
        case 3:
          _es.setSelectedDateWeekdayText("수");
          break;
        case 4:
          _es.setSelectedDateWeekdayText("목");
          break;
        case 5:
          _es.setSelectedDateWeekdayText("금");
          break;
        case 6:
          _es.setSelectedDateWeekdayText("토");
          break;
        case 7:
          _es.setSelectedDateWeekdayText("일");
          break;
      }
    }
  }

  void _onTapLeft() {
    DateTime date = DateTime.parse(_selectedDate);
    setState(() {
      if (_diff > 0) {
        date = date.add(Duration(days: -1));
        _diff = date.difference(_current).inDays;
        _es.setSelectedDate(date.toString().substring(0, 10));
        _selectedDateText = "${date.year}.${date.month}.${date.day}";

        _getDateLeft(_diff, date.weekday);
      }
    });
  }

  void _onTapRight() {
    print("right");
    DateTime date = DateTime.parse(_selectedDate);
    setState(() {
      if (_diff < 30) {
        date = date.add(Duration(days: 1));
        _diff = date.difference(_current).inDays;
        _es.setSelectedDate(date.toString().substring(0, 10));
        _selectedDateText = "${date.year}.${date.month}.${date.day}";
        _getDateRight(_diff, date.weekday);
      }
    });
  }

  /// 날짜 표시 위
  Widget _dateTimeWidget() {
    return AspectRatio(
      aspectRatio: 375/40,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.020),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  _onTapLeft();
                },
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
                onTap: () {
                  setState(() {
                    _onTapRight();
                  });
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent)
                    ),
                    child: Icon(Icons.chevron_right_sharp, color: mainColor,))),
          ],
        ),
      )
    );
  }

  /// 판넬 꼭다리
  Widget _panelTop() {
    return AspectRatio(
      aspectRatio: 375/24.8,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Container(
            width: _uiCriteria.screenWidth * 0.1733,
            height: 2,
            color: greyD8D8D8.withOpacity(0.5)
        ),
      ),
    );
  }

  Widget _myInfoButton(BoxConstraints constraint) {
    return GestureDetector(
      onTap: (!_timeList.contains(_timeNum))
      ? null
      : () {
        if (_myInfo) {
          setState(() {
            _myInfo = false;
            _myInfoTimer.stopTimer();
          });
        }
        else {
          setState(() {
            _myInfo = true;
            _benefit = false;
            _invite =false;
          });
        }
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: (!_timeList.contains(_timeNum))?greyF5F5F6:(_myInfo)?mainColor:Colors.white,
                shape: BoxShape.circle,
                boxShadow: (!_timeList.contains(_timeNum))
                    ? null
                    : [BoxShadow(color: Colors.black.withOpacity(0.13), spreadRadius: 0, blurRadius: 6, offset: Offset(0,1))],
              ),
              width: constraint.maxHeight * 0.4864,
              height: constraint.maxHeight * 0.4864,
              padding: EdgeInsets.all(constraint.maxHeight * 0.1018),
              child: Image.asset("assets/png/my_info.png", color: (!_timeList.contains(_timeNum))?greyAAAAAA:(_myInfo)?Colors.white:mainColor),),
            SizedBox(height: constraint.maxHeight * 0.0630),
            Text("나의 정보", style: TextStyle(letterSpacing: 0.6, color: (!_timeList.contains(_timeNum))?greyAAAAAA:mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),)
          ]
      ),
    );
  }

  /// 상금 버튼
  Widget _benefitButton(BoxConstraints constraint) {
    return GestureDetector(
      onTap: () {
        if (_benefit) {
          setState(() {
            _benefit = false;
          });
        }
        else {
          setState(() {
            _myInfo = false;
            _benefit = true;
            _invite =false;
          });
        }
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: (_benefit)?mainColor:Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.13), spreadRadius: 0, blurRadius: 6, offset: Offset(0,1))],
              ),
              width: constraint.maxHeight * 0.4864,
              height: constraint.maxHeight * 0.4864,
              padding: EdgeInsets.all(constraint.maxHeight * 0.0991),
              child: Image.asset("assets/png/my_reward.png",color: (_benefit)?Colors.white:mainColor),),
            SizedBox(height: constraint.maxHeight * 0.0630),
            Text("상금", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),)
          ]
      ),
    );
  }

  /// 친구 초대하기 버튼
  Widget _inviteButton(BoxConstraints constraint) {
    return GestureDetector(
      onTap: () {
        _myInfoTimer.stopTimer();
        inviteFriends();
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                  color: (_invite)?mainColor:Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.13), spreadRadius: 0, blurRadius: 6, offset: Offset(0,1))],
                ),
                width: constraint.maxHeight * 0.4864,
                height: constraint.maxHeight * 0.4864,
                padding: EdgeInsets.all(constraint.maxHeight * 0.0991),
                child: Image.asset("assets/png/add_friends.png" ,color: (_invite)?Colors.white:mainColor)),
            SizedBox(height: constraint.maxHeight * 0.0630),
            Text("친구초대", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),)
          ]
      ),
    );
  }

  /// 나의 정보, 상금, 친구초대 버튼
  Widget _threeButton() {
    return AspectRatio(
        aspectRatio: 375/110.2,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              padding: EdgeInsets.only(top: constraint.maxHeight * 0.1089),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.136),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _myInfoButton(constraint),
                          _benefitButton(constraint),
                          _inviteButton(constraint)
                        ],
                      ),
                    ),
                  ]
              ),
            );
          },
        )
    );
  }

  /// 예약하기 버튼
  Widget _reservationButton() {
    return AspectRatio(
        aspectRatio: 375/52,
        child: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
          ),
          child: AspectRatio(
            aspectRatio: 375/40,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => Reservation(
                      galaxyNum: _galaxyNum,
                      imagePath: _imagePath,
                      accumulativePayment: _totalPayment,
                      schoolName: _galaxyName,
                      timeNum: _timeNum,
                      official: _official,
                    )));
                  },
                  elevation: 0,
                  color: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: Text("추가 예약하기", style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700,),
                  ),
                )
            ),
          ),
        )
    );
  }

  Widget _checkedUserTitle() {
    return AspectRatio(
      aspectRatio: 375/40,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "총 $_attCount명 탐험중", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2),),
                    TextSpan(text: " /$_todayCount명", style: TextStyle(letterSpacing: 0.6, color: greyAAAAAA, fontSize: _uiCriteria.textSize3),)
                  ]
              ),
            ),
            RichText(
              text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "탐험단 순위", style: TextStyle(letterSpacing: 0.7, color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2)),
                    TextSpan(text: " $_explorerRank위", style: TextStyle(letterSpacing: 0.7, color:Color(0XFFE7535C), fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2))
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 내정보에서 닉네임과 레벨
  Widget _nickAndLevel(BoxConstraints constraint, String nickname) {
    return Container(
      padding: EdgeInsets.only(bottom: constraint.maxHeight * 0.0215),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: greyD8D8D8, width: 1.5))
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: _uiCriteria.textSize2, color: mainColor, letterSpacing: 0.7, fontWeight: FontWeight.w500),
          children: <TextSpan>[
            TextSpan(text: "$nickname", style: TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: "님은 지금",),
            TextSpan(text: " 먼지뭉치", style: TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: " 단계예요.",),
          ]
        ),
      ),
    );
  }

  Widget _myHistory(BoxConstraints constraint, int characterIndex, int myAttendCount, int totalAttendCount, int myDeposit, int totalDeposit,
     int accumPrize, int myDust, int totalDust) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0384),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _myCharacter(constraint, characterIndex),
          Spacer(flex: 267,),
          _myHistoryTitle(constraint),
          Spacer(flex: 200,),
          _myHistoryContent(constraint, myAttendCount, totalAttendCount, myDeposit, totalDeposit, accumPrize, myDust, totalDust),
          Spacer(flex: 423,)
        ],
      ),
    );
  }

  Widget _myCharacter(BoxConstraints constraint, int characterIndex) {
    return Container(
      width: constraint.maxHeight * 0.2444,
      height: constraint.maxHeight * 0.2346,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: shadowColor(characterIndex), blurRadius: 26, spreadRadius: 0, offset: Offset(-4, 0))],
          image: DecorationImage(
              image: AssetImage(getCharacter(characterIndex)),
              fit: BoxFit.fill
          )
      ),
    );
  }

  Widget _myHistoryTitle(BoxConstraints constraint) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("출석 횟수", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.w500),),
        SizedBox(height: constraint.maxHeight * 0.0234,),
        Text("보증금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.w500),),
        SizedBox(height: constraint.maxHeight * 0.0234,),
        Text("누적 상금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.w500),),
        SizedBox(height: constraint.maxHeight * 0.0234,),
        Text("더스트", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6, fontWeight: FontWeight.w500),),
      ],
    );
  }

  Widget _myHistoryContent(BoxConstraints constraint, int myAttendCount, int totalAttendCount, int myDeposit, int totalDeposit,
      int accumPrize, int myDust, int totalDust) {
    int rate = (myAttendCount * 100 / totalAttendCount).round();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: "$myAttendCount회", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3)),
              TextSpan(text: " /$totalAttendCount회($rate%)", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5)),
            ]
          ),
        ),
        SizedBox(height: constraint.maxHeight * 0.0234,),
        RichText(
          text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "${myDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3)),
                TextSpan(text: " /${totalDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5)),
              ]
          ),
        ),
        SizedBox(height: constraint.maxHeight * 0.0234,),
        Text("${accumPrize.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3)),
        SizedBox(height: constraint.maxHeight * 0.0234,),
        RichText(
          text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "$myDust", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3)),
                TextSpan(text: " /${totalDust.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: _uiCriteria.textSize5)),
              ]
          ),
        ),
      ]
    );
  }

  Widget _timer(BoxConstraints constraint, String nextReserveTime) {
    _myInfoTimer.startTimer();
    int h, m, s;
    h = _myInfoTimer.getTime() ~/ 3600;
    m = ((_myInfoTimer.getTime() - h * 3600)) ~/ 60;
    s = _myInfoTimer.getTime() - (h * 3600) - (m * 60);
    return AspectRatio(
      aspectRatio: 343/40,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(94),
          border: Border.all(color: greyB3B3BC, width: 1.5)
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: (_myInfoTimer.getTime() <= 600)?Color(0XFFE7535C):mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7),
            children: <TextSpan>[
              TextSpan(text: "나의 출석까지 남은 시간 "),
              TextSpan(text: "${h.toString().padLeft(2,"0")}:${m.toString().padLeft(2,"0")}:${s.toString().padLeft(2,"0")}", style: TextStyle(fontWeight: FontWeight.bold)),
            ]
          ),
        ),
      ),
    );
  }
  /// 내정보
  Widget _myInformation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
      child: AspectRatio(
        aspectRatio: 343/255.7,
        child: FutureBuilder(
          future: _getMyInfo(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _setMyInfo(snapshot.data);
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return Container(
                    margin: EdgeInsets.only(bottom: constraint.maxHeight * 0.09507),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 1.5), bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 1.5))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Spacer(flex: 222,),
                        _nickAndLevel(constraint, _nickname),
                        Spacer(flex: 230,),
                        _myHistory(constraint, _myCharacterIndex, _myAttendCount, _myTotalCount, _myDeposit, _totalDeposit, _accumPrize, _dust, _totalDust),
                        Spacer(flex: 230,),
                        _timer(constraint, _nextReserveTime),
                        Spacer(flex: 232,),
                      ],
                    ),
                  );
                },
              );
            }
            else {
              return loader(context, 0);
            }
          },
        ),
      ),
    );
  }

  /// 내정보 가져오기
  Future<dynamic> _getMyInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://$speckUrl/explorer/myinfo");
    String body = '''{
      "userEmail" : "${sp.getString("email")}",
      "bookinfo" : $_bookInfo
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url, headers: header, body: body);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    return result;
  }

  void _setNickAndChar() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _myCharacterIndex = sp.getInt("characterIndex");
    _nickname = sp.getString("nickname");
  }

  void _setMyInfo(dynamic result) {
    _myAttendCount = result["attendCount"];
    _myTotalCount = result["totalCount"];
    _myDeposit = result["myDeposit"];
    _totalDeposit = result["totalDeposit"];
    _accumPrize = result["cumPrize"];
    _dust = result["dust"];
    _totalDust = result["totalDust"];
    _nextReserveTime = result["nextReserveTime"];
    DateTime nrt = DateTime.parse(_nextReserveTime + " " + getAuthTime(_timeNum));
    _remainingTime = nrt.difference(DateTime.now()).inSeconds;
    _myInfoTimer.setTime(_remainingTime);
  }

  /// 탐험단 상금 정보
  Widget _benefitInfo() {
    return FutureBuilder(
        future: _checkBenefit(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == true) {
            return snapshot.data;
          }
          else {
            return AspectRatio(
                aspectRatio: 375/290.6,
                child: Container(
                    alignment: Alignment.center,
                    child: Container(
                        width: _uiCriteria.screenWidth * 0.06666,
                        height: _uiCriteria.screenWidth * 0.06666,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                        ))));
          }
        });
  }

  /// 슬라이딩 판넬
  Widget _slidingPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(13.8), topLeft: Radius.circular(13.8)),
        color: Colors.white
      ),
      child: DraggableScrollableSheet(
        maxChildSize: 1.0,
        minChildSize: 0.6,
        initialChildSize: 0.6,
        expand: false,
        builder: (BuildContext context, ScrollController controller) {
          return SingleChildScrollView(
            controller: controller,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(13.8), topRight: Radius.circular(13.8)),
              ),
              child: Column(
                  children: <Widget>[
                    _panelTop(),
                    _dateTimeWidget(),
                    _threeButton(),
                    (_myInfo)
                        ? _myInformation()
                        : (_benefit)
                        ? _benefitInfo()
                        : Container(),
                    _reservationButton(),
                    greyBar(),
                    greyBar(),
                    _checkedUserTitle(),
                    GridView.builder(
                        padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.04),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          childAspectRatio: 1.16,
                          mainAxisSpacing: _uiCriteria.totalHeight * 0.05,
                        ),
                        itemCount: _usersList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _usersList[index];
                        }),
                  ]
              ),
            ),
          );
        },),
    );
    // return SlidingUpPanel(
    //   onPanelOpened: () {
    //     setState(() {
    //       _panelOpened = true;
    //       _physics = ScrollPhysics();
    //     });
    //   },
    //   onPanelSlide: (double position) {
    //     if (position == 0) {
    //       setState(() {
    //         _panelOpened = false;
    //         _physics = NeverScrollableScrollPhysics();
    //       });
    //     }
    //   },
    //   minHeight: _uiCriteria.totalHeight * 0.5209,
    //   maxHeight: _uiCriteria.totalHeight,
    //   borderRadius: (_panelOpened)?null:BorderRadius.only(topRight: Radius.circular(13.8), topLeft: Radius.circular(13.8)),
    //   panel: Column(
    //       children: <Widget>[
    //         _panelTop(),
    //         _dateTimeWidget(),
    //         Expanded(
    //           child: ListView.builder(
    //             // shrinkWrap: true,
    //             physics: _physics,
    //             itemCount: widgets.length,
    //             itemBuilder: (BuildContext context, int index) {
    //               return widgets[index];
    //             },
    //           ),
    //         )
    //         // Expanded(
    //         //   child: SingleChildScrollView(
    //         //     child: Container(
    //         //       width: _uiCriteria.screenWidth,
    //         //       child: Column(
    //         //         children: <Widget>[
    //         //           _threeButton(),
    //         //           (_myInfo)
    //         //           ? _myInformation()
    //         //           : (_benefit)
    //         //               ? _benefitInfo()
    //         //               : Container(),
    //         //           _reservationButton(),
    //         //           greyBar(),
    //         //           _checkedUserTitle(),
    //         //           GridView.builder(
    //         //               padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.04),
    //         //               physics: NeverScrollableScrollPhysics(),
    //         //               shrinkWrap: true,
    //         //               gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //         //                 maxCrossAxisExtent: 150,
    //         //                 childAspectRatio: 1.16,
    //         //                 mainAxisSpacing: _uiCriteria.totalHeight * 0.05,
    //         //               ),
    //         //               itemCount: _usersList.length,
    //         //               itemBuilder: (BuildContext context, int index) {
    //         //                 return _usersList[index];
    //         //               }),
    //         //         ],
    //         //       ),
    //         //     ),
    //         //   ),
    //         // )
    //       ]
    //   ),
    // );
  }

  Future<Map<String, dynamic>> _getExplorerInfo(int galaxyNum, int timeNum, String dateInfo) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    var url = Uri.parse("http://$speckUrl/explorer/detail");
    String body = '''{
    "galaxyNum" : $galaxyNum,
    "timeNum": $timeNum,
    "dateinfo": "$dateInfo",
    "userEmail" : "$email"
     }''';
    Map<String, String> header = {
      "Content-Type":"application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var utf = utf8.decode(response.bodyBytes);
    Map<String, dynamic> result = jsonDecode(utf);
    return Future(() {
      return result;
    });
  }

  Widget _predictBenefit(int book, [String prize]) {
    return  Container(
      alignment: Alignment.centerLeft,
      child: Container(
        child: RichText(
          text: TextSpan(
              style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
              children: <TextSpan>[
                TextSpan(text: "${DateTime.parse(_selectedDate).month}/${DateTime.parse(_selectedDate).day} "),
                TextSpan(text: (book == 0)?"상금 보기    ": "나의 상금    "),
                TextSpan(text: (book == 0)? "":(book == -1)?"(예상) 0원 ~ $prize원":"$prize원")
              ]
          ),
        ),
      ),
    );
  }

  Future<Widget> _checkBenefit(BuildContext context) async {
    _myInfoTimer.stopTimer();
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://$speckUrl/explorer/reward");
    int galaxyNum = _galaxyNum;
    String memberEmail = sp.getString("email");
    String body = ''' {
      "userEmail" : "$memberEmail",
      "galaxyNum" : $galaxyNum,
      "timeNum" : $_timeNum,
      "dateinfo" : "$_selectedDate"
      }''';
    print("reward body $body");
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    dynamic result = jsonDecode(response.body);
    print("result $result");
    int book = result["book"]; /// 0 예약 X 1 인증시간 지남 -1 인증시간 안지남
    String rewardPrize = result["rewardPrize"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'); /// 상금
    dynamic rewardTotal = result["rewardTotal"];
    dynamic rewardTotalExplorer = result["rewardTotalExplorer"];

    int totalAvgAttRate = rewardTotal["avgAttRate"]; // 평균 출석률
    int totalAvgAtt = rewardTotal["avgAtt"]; // 평균 출석 인원
    int totalAccumAtt = rewardTotal["accumAtt"]; // 누적 출석인원
    String totalAccumDeposit = rewardTotal["accumDeposit"].toString()
        .replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'); // 누적 보증금
    String totalAccumDepositByDate = rewardTotal["accumDepositByDate"]
        .toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'); // 하루 누적 보증금
    String totalAvgDepositByDate = rewardTotal["avgDepositByDate"]
        .toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'); // 하루 평균 보증금

    int expAvgAttRate = rewardTotalExplorer["avgAttRate"];
    int expAvgAtt = rewardTotalExplorer["avgAtt"];
    int expAccumAtt = rewardTotalExplorer["accumAtt"];
    String expAccumDeposit = rewardTotalExplorer["accumDeposit"]
        .toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    String expAccumDepositByDate = rewardTotalExplorer["accumDepositByDate"]
        .toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    String expAvgDepositByDate = rewardTotalExplorer["avgDepositByDate"]
        .toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Future(() {
      return AspectRatio(
        aspectRatio: 375/290.6,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              margin: EdgeInsets.only(bottom: constraint.maxHeight * 0.07639),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: greyD8D8D8.withOpacity(0.5) ,width: 1.5), bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 1.5))
                  ),
                  padding: EdgeInsets.symmetric(vertical: constraint.maxHeight * 0.07639),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      (book == 0)
                      ? _predictBenefit(book)
                      :_predictBenefit(book, rewardPrize),
                      SizedBox(height: constraint.maxHeight * 0.0757),
                      Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text("모든 갤럭시의 $_time 탐험단", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                  ),
                                  SizedBox(height: constraint.maxHeight * 0.0341),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 149,
                                                  child: Container(
                                                      child:  Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text("평균 출석률", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                          Text("$totalAvgAttRate%", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: constraint.maxWidth * 0.0773,),
                                                Expanded(
                                                  flex: 165,
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text("누적 보증금", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                        Text("$totalAccumDeposit원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 149,
                                                  child: Container(
                                                      child:  Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text("평균 출석인원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                          Text("$totalAvgAtt명", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: constraint.maxWidth * 0.0773,),
                                                Expanded(
                                                  flex: 165,
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text("오늘 보증금", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                        Text("$totalAccumDepositByDate원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 149,
                                                  child: Container(
                                                      child:  Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text("누적 출석인원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                          Text("$totalAccumAtt명",  style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: constraint.maxWidth * 0.0773,),
                                                Expanded(
                                                  flex: 165,
                                                  child: Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text("평균적으로 하루에 $totalAvgDepositByDate원을 걸었어요", style: TextStyle(fontSize: _uiCriteria.textSize5, color: greyAAAAAA, fontWeight: FontWeight.w500))),
                                                )
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ]
                            )
                        ),
                      ),
                      SizedBox(height: constraint.maxHeight * 0.0757),
                      Expanded(
                        child: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text("\'$_galaxyName\'의 $_time 탐험단", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                                  ),
                                  SizedBox(height: constraint.maxHeight * 0.0341),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 149,
                                                  child: Container(
                                                      child:  Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text("평균 출석률", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                          Text("$expAvgAttRate%", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: constraint.maxWidth * 0.0773,),
                                                Expanded(
                                                  flex: 165,
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text("누적 보증금", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                        Text("$expAccumDeposit원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 149,
                                                  child: Container(
                                                      child:  Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text("평균 출석인원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                          Text("$expAvgAtt명",style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: constraint.maxWidth * 0.0773,),
                                                Expanded(
                                                  flex: 165,
                                                  child: Container(
                                                    child:Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text("오늘 보증금", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                        Text("$expAccumDepositByDate원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 149,
                                                  child: Container(
                                                      child:  Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text("누적 출석인원", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500)),
                                                          Text("$expAccumAtt명", style: TextStyle(letterSpacing: 0.6, color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                SizedBox(width: constraint.maxWidth * 0.0773,),
                                                Expanded(
                                                  flex: 165,
                                                  child: Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text("평균적으로 하루에 $expAvgDepositByDate원을 걸었어요", style: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize5,  fontWeight: FontWeight.w500))),
                                                )
                                              ]
                                          ),
                                        ),
                                      ]
                                    ),
                                  )
                                ]
                            )
                        ),
                      )
                    ],
                  )
              ),
            );
          },
        ),
      );
    });
  }

  List<Widget> _generateAMList(BuildContext context) {
    List<Widget> amList = [];
    String time = "";
    for (int i = 1; i <= 12; i++) {
      int id;
      amList.add(
          GestureDetector(
            child: AspectRatio(
              aspectRatio: 72/32,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  switch (i) {
                    case 1:
                      time = "00:00";
                      id = 17;
                      break;
                    case 2:
                      time = "01:00";
                      id = 18;
                      break;
                    case 3:
                      time = "02:00";
                      id = 19;
                      break;
                    case 4:
                      time = "03:00";
                      id = 20;
                      break;
                    case 5:
                      time = "04:00";
                      id = 21;
                      break;
                    case 6:
                      time = "05:00";
                      id = 22;
                      break;
                    case 7:
                      time = "06:00";
                      id = 23;
                      break;
                    case 8:
                      time = "07:00";
                      id = 24;
                      break;
                    case 9:
                      time = "08:00";
                      id = 1;
                      break;
                    case 10:
                      time = "09:00";
                      id = 2;
                      break;
                    case 11:
                      time = "10:00";
                      id = 3;
                      break;
                    case 12:
                      time = "11:00";
                      id = 4;
                      break;
                  }
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.065, vertical: constraint.maxHeight * 0.06),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                border: (_timeNum == id)
                                    ?Border.all(color: mainColor, width: 1.5)
                                    :Border.all(color: greyB3B3BC, width: 0.5)
                            ),
                            child: AutoSizeText("$time", maxLines: 1, style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
                        ),
                      ),
                      (_timeList.contains(id))
                          ? Image.asset("assets/png/dust_icon.png")
                          : Container()
                    ],
                  );
                },
              ),
            ),
            onTap: () {
              setState(() {
                _es.setTimeNum(id);
                _myInfo = false;
              });
              Navigator.of(context, rootNavigator: true).pop(context);
            },
          )
      );
    }
    return amList;
  }

  List<Widget> _generatePMList(BuildContext context) {
    List<Widget> pmList = [];
    String time = "";
    for (int i = 1; i <= 12; i++) {
      int id = 0;
      pmList.add(
          GestureDetector(
            child: AspectRatio(
              aspectRatio: 72/32,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  switch (i) {
                    case 1:
                      time = "12:00";
                      id = 5;
                      break;
                    case 2:
                      time = "13:00";
                      id = 6;
                      break;
                    case 3:
                      time = "14:00";
                      id = 7;
                      break;
                    case 4:
                      time = "15:00";
                      id = 8;
                      break;
                    case 5:
                      time = "16:00";
                      id = 9;
                      break;
                    case 6:
                      time = "17:00";
                      id = 10;
                      break;
                    case 7:
                      time = "18:00";
                      id = 11;
                      break;
                    case 8:
                      time = "19:00";
                      id = 12;
                      break;
                    case 9:
                      time = "20:00";
                      id = 13;
                      break;
                    case 10:
                      time = "21:00";
                      id = 14;
                      break;
                    case 11:
                      time = "22:00";
                      id = 15;
                      break;
                    case 12:
                      time = "23:00";
                      id = 16;
                      break;
                  }
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.065, vertical: constraint.maxHeight * 0.06),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                border: (_timeNum == id)
                                    ?Border.all(color: mainColor, width: 1.5)
                                    :Border.all(color: greyB3B3BC, width: 0.5)
                            ),
                            child: AutoSizeText("$time", maxLines: 1, style: TextStyle(letterSpacing: 0.7,color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),)
                        ),
                      ),
                      (_timeList.contains(id))
                          ? Image.asset("assets/png/dust_icon.png")
                          : Container()
                    ],
                  );
                },
              ),
            ),
            onTap: () {
              setState(() {
                _es.setTimeNum(id);
                _myInfo = false;
              });
              Navigator.of(context, rootNavigator: true).pop(context);
            },
          )
      );
    }

    return pmList;
  }

  void _showTimeTable(BuildContext context) {
    List<Widget> amList = _generateAMList(context);
    List<Widget> pmList = _generatePMList(context);
    Dialog timeTable = new Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.9)
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
      child: AspectRatio(
        aspectRatio: 343/364,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.9),
                  color: Colors.white
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: constraint.maxWidth,
                    height: constraint.maxHeight * 0.1098,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                    ),
                    child: Text("탐험단 둘러보기", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700),),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                      ),
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.025),
                        shrinkWrap: true,
                        physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 72/32,
                            // crossAxisSpacing: constraint.maxWidth * 0.0291,
                            // mainAxisSpacing: constraint.maxHeight * 0.0247
                        ),
                        itemCount: amList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return amList[index];
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                      ),
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.025),
                        shrinkWrap: true,
                        physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 72/32,
                            // crossAxisSpacing: constraint.maxWidth * 0.0291,
                            // mainAxisSpacing: constraint.maxHeight * 0.0247
                        ),
                        itemCount: pmList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return pmList[index];
                        },

                      ),
                    ),
                  ),
                ]
              ),
            );
          },
        )
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return timeTable;
        });
  }
}
