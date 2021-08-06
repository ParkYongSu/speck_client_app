import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:speck_app/FocusTime/focus_time.dart';
import 'package:speck_app/Main/home/page_state.dart';
import 'package:speck_app/State/banner_state.dart';
import 'package:speck_app/State/explorer_state.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/Time/stopwatch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/main/explorer/explorer.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:url_launcher/url_launcher.dart';

class MainHome extends StatefulWidget {
  static String email;

  @override
  MainHomeState createState() => MainHomeState();
}

class MainHomeState extends State<MainHome> with WidgetsBindingObserver {
  CardTime _cardTime;
  BannerState _bannerState;
  int _currentSec;
  var bottomSheetController;
  final UICriteria _uiCriteria = new UICriteria();
  SharedPreferences _sp;
  ExplorerState _es;
  int _route;
  PageState _pageState;
  BannerState _bs;

  @override
  Widget build(BuildContext context) {
    _pageState = Provider.of<PageState>(context, listen: false);
    _uiCriteria.init(context);
    _cardTime = Provider.of<CardTime>(context, listen: true);
    /// 배너
    _bannerState = Provider.of<BannerState>(context, listen: false);
    _es = Provider.of<ExplorerState>(context, listen: false);
    _route = 1;
    _bs = Provider.of<BannerState>(context, listen: false);

    return Container(
      alignment: Alignment.center,
      width: _uiCriteria.screenWidth,
      height: _uiCriteria.totalHeight,
      decoration: BoxDecoration(
        color: mainColor
      ),
      child: FutureBuilder(
          future: _infoWidget(context),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == true) {
              return snapshot.data;
            }
            else {
              return Container(
                  width: _uiCriteria.screenWidth * 0.065,
                  height: _uiCriteria.screenWidth * 0.065,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                );
            }
          } ),
    );
  }

  bool _bottomSheetOpened;
  List<int> times;
  String _numFocus;
  String _userTypeMode1;
  String _userTypeMode0;
  String _attImage;
  String _nickname;
  String _userEmail;
  String _dust;
  int _character;
  List<int> _timeList = [];
  @override
  void initState() {
    super.initState();
    _userEmail = "";
    _nickname = "";
    _dust = "";
    _attImage = "";
    _bottomSheetOpened = false;
    WidgetsBinding.instance.addObserver(this);
    times = [];
    _numFocus = "0";
    _userTypeMode1 =
        '''{"user":"${MainHome.email}", "type":"5", "mode":"1"}''';
    _userTypeMode0 =
        '''{"user":"${MainHome.email}", "type":"5", "mode":"0"}''';
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _cardTime.stopTimer();
    // SpeckApp.socket.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_bottomSheetOpened && state == AppLifecycleState.inactive) {
      print("집중모드 닫힘");
      // setState(() {
      //   _bottomSheetOpened = false;
      // });
      // Navigator.pop(context);
    }
  }

  /// 최신순으로 정렬
  void _selectionSort(List<dynamic> list) {
    for (int i = 0; i < list.length - 1; i++) {
      int min = i;

      for (int j = i + 1; j < list.length; j++) {
        if (DateTime.parse(list[min]["nextReserveTime"]).isAfter(DateTime.parse(list[j]["nextReserveTime"]))) {
          min = j;
        }
      }
      dynamic temp = list[i];
      list[i] = list[min];
      list[min] = temp;
    }
  }

  /// 정보 창
  Future<Widget> _infoWidget(BuildContext context) async {
    _sp = await SharedPreferences.getInstance();
    _character = _sp.getInt("characterIndex");
    _nickname = _sp.getString("nickname");
    _userEmail = _sp.getString("email");
    List<Widget> items = [];
    //String email = sp.getString("email");
    // String __memberEmail = "zkspffh@naver.com";
    var url = Uri.parse("http://$speckUrl/maincard");
    String body = '''{
      "userEmail" : "$_userEmail"
    }''';
    Map<String, String> header = {
      "Content-Type":"application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var utf = utf8.decode(response.bodyBytes);
    dynamic result = jsonDecode(utf);
    print(result);
    dynamic homeDataMyInfo = result["homeDataMyInfo"];
    _dust = homeDataMyInfo["dust"].toString();
    // _attImage = "http://icnogari96.cafe24.com:8080/file/get.do?imagePath=${homeDataMyInfo["attImage"]}";
    int myAttNum = homeDataMyInfo["myAttNum"];
    int allAttNum = homeDataMyInfo["allAttNum"];
    String myPoint = homeDataMyInfo["myPoint"].toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');// 총 출첵횟수

    List<dynamic> homeExplorerVOS = result["homeExplorerVOS"]; // 카드 정보

    if (homeExplorerVOS.isEmpty) {

      items.add(
        GestureDetector(
          onTap: () {
            _pageState.setIndex(1);
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => MakePlanPage()));
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6.9),
                border: Border.all(color: greyB3B3BC)
            ),
            width: double.infinity,
            height: _uiCriteria.totalHeight * 0.2069,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("아직 가입한 갤럭시가 없어요.",
                      style: TextStyle(
                          letterSpacing: 0.6,
                          color: greyB3B3BC,
                          fontWeight: FontWeight.w500,
                          fontSize: _uiCriteria.textSize3)),
                  AspectRatio(aspectRatio: 375/6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("갤럭시 가입하기 ",
                          style: TextStyle(
                              letterSpacing: 1.1,
                              color: greyB3B3BC,
                              fontWeight: FontWeight.w700,
                              fontSize: _uiCriteria.totalHeight * 0.02709)),
                      Icon(Icons.add, color: greyB3B3BC, size:  _uiCriteria.screenWidth * 0.07,)
                    ],
                  )
                ]
            ),
          )
      ));
    }
    else {
      _selectionSort(homeExplorerVOS); // 최신순 정렬

      for (int i = 0; i < homeExplorerVOS.length; i++) {

        dynamic info = homeExplorerVOS[i];
        int galaxyNum = info["galaxyNum"];
        int timeNum = info["timeNum"];
        _timeList.add(timeNum);
        int official = info["official"];
        String authTime = getAuthTime(timeNum);
        String galaxyName = info["galaxyName"];
        String imgUrl = info["imgUrl"];
        int myDeposit = info["myDeposit"];
        int totalDeposit = info["totalDeposit"];
        int todayReserve = info["todayReserve"];
        int totalCount = info["totalCount"];
        int attendCount = info["attendCount"];
        int bookInfo = info["bookinfo"];
        String nextReserveTime = info["nextReserveTime"];
        int remainingTime = DateTime.parse(nextReserveTime + " " + getAuthTime(timeNum)).difference(DateTime.now()).inSeconds;
        _cardTime.setSeconds(remainingTime);

        _cardTime.startTimer();

        if (i == 0) {
            await _sp.setInt("bookInfo", bookInfo);
        }

        int hour = _cardTime.seconds ~/ (60 * 60);
        int min = (_cardTime.seconds - (hour * 60 * 60)) ~/ 60;
        int sec = (_cardTime.seconds) - (hour * 60 * 60) - (min * 60);

        // todo.
        items.add(
          GestureDetector(
              onTap: () {
                _cardTime.stopTimer();
                _cardTap(galaxyName, imgUrl, galaxyNum, official, timeNum);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.17),
                    borderRadius: BorderRadius.circular(6.9),
                    // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.67), blurRadius: 13, spreadRadius: 0, offset: Offset(3, 3))]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 37,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(6.9), topRight: Radius.circular(6.9)),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                              decoration: BoxDecoration(
                                // border: Border(bottom: BorderSide(color: Color(0XFFCACAD1))),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                        children: <Widget>[
                                          Text("$_nickname님의 탐험단", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                                          Text(" 오늘 예약자 $todayReserve명", style: TextStyle(color: greyD8D8D8, fontSize: _uiCriteria.screenWidth * 0.0266),)
                                        ]
                                    ),
                                    Text("자유장소", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),)
                                    // Text((schoolType == 1)?"지정장소":"자유장소", style: TextStyle(color: Color(0XFFB3B3BC), fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),)
                                  ]
                              ),
                            ),
                            Container(
                                height: 0.5,
                                color: Colors.white.withOpacity(0.19)
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 131,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.0466, vertical: constraints.maxHeight * 0.1825),
                            child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              // border: Border.all(color: Color(0XFFB3B3BC), width: 0.5)
                                            ),
                                            child: ClipOval(
                                                child: Image.network(imgUrl, height: constraints.maxHeight * 0.4961,)
                                            ),
                                          ),
                                          Row(
                                              children: <Widget>[
                                                Icon(Icons.access_time, color: Colors.white, size: _uiCriteria.textSize2,),
                                                Text(" ${hour.toString().padLeft(2,"0")}:${min.toString().padLeft(2,"0")}:${sec.toString().padLeft(2,"0")}", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize5),)
                                              ]
                                          )
                                        ]
                                    ),
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.0466),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      (official == 1)?Text("[공식] $galaxyName ($authTime)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2)):Text("$galaxyName ($authTime)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("출석 횟수", style: TextStyle(letterSpacing: 0.6, color: greyD8D8D8, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                                SizedBox(height: constraints.maxHeight * 0.0476),
                                                Text("보증금", style: TextStyle(letterSpacing: 0.6,color: greyD8D8D8, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                                SizedBox(height: constraints.maxHeight * 0.0476),
                                                Text("누적 상금", style: TextStyle(letterSpacing: 0.6,color: greyD8D8D8, fontSize: _uiCriteria.textSize3,  fontWeight: FontWeight.w500),),
                                              ]
                                          ),
                                          SizedBox(width: constraints.maxWidth * 0.0583,),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                    children: <Widget>[
                                                      Text("$attendCount회", style: TextStyle(letterSpacing: 0.5,color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3)),
                                                      Text(" /$totalCount회", style: TextStyle(letterSpacing: 0.5,color: Colors.white, fontSize: _uiCriteria.screenWidth * 0.0266,))
                                                    ]
                                                ),
                                                SizedBox(height: constraints.maxHeight * 0.0476),
                                                Row(
                                                    children: <Widget>[
                                                      Text("${myDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(letterSpacing: 0.6,color: Colors.white,fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3)),
                                                      Text(" /${totalDeposit.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원", style: TextStyle(letterSpacing: 0.5,fontSize: _uiCriteria.screenWidth * 0.0266, color: Colors.white,))
                                                    ]
                                                ),
                                                SizedBox(height: constraints.maxHeight * 0.0476),
                                                Text("$myPoint원", style: TextStyle(letterSpacing: 0.6, color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),),
                                              ]
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ]
                            ),
                          );
                        },
                      ),
                    )
                  ],

                ),
              )
          ),
        );
      }
    }

    _checkBanner2();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset("assets/png/main_stars.png", height: _uiCriteria.totalHeight, width: _uiCriteria.screenWidth, fit: BoxFit.fill,),
        Container(
            padding: EdgeInsets.only(top: _uiCriteria.statusBarHeight, bottom: _uiCriteria.naviHeight),
            child: Image.asset("assets/png/main_planet.png", height: _uiCriteria.totalHeight * 0.2455, width: _uiCriteria.screenWidth, fit: BoxFit.fill,)),
        Positioned(
          bottom: _uiCriteria.totalHeight * 0.35,
          child: Container(
              padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.0602, right: _uiCriteria.screenWidth * 0.0704),
              child: Image.asset("assets/png/main_dust_friends.png",fit: BoxFit.fill,)),
          ),
        Container(
                padding: EdgeInsets.only(top: _uiCriteria.statusBarHeight, bottom: _uiCriteria.naviHeight),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    // border: Border(top: BorderSide(color: Colors.black,width : 0.5)),
                ),
                child: Column(children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding,),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: _uiCriteria.totalHeight * 0.01),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text("나의 출석 횟수 ", style: TextStyle(letterSpacing: 0.6, color: greyD8D8D8, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                              Text("$myAttNum회  ", style: TextStyle(letterSpacing: 0.6, color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                              Container(
                                  height: _uiCriteria.textSize3,
                                  width: 1,
                                  color: greyD8D8D8
                              ),
                              Text("  나의 상금 ", style: TextStyle(letterSpacing: 0.6, color: greyD8D8D8, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700)),
                              Text("$myPoint원", style: TextStyle(letterSpacing: 0.6, color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700))
                            ]
                        ),
                        SizedBox(height: _uiCriteria.totalHeight * 0.007),
                        // AspectRatio(aspectRatio: 375/6),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("지금 $allAttNum명이 우주탐험 중", style: TextStyle(letterSpacing: 0.5,  color: Colors.white, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w600)),
                        ),
                      ]
                    )
                  ),
                  SizedBox(height: _uiCriteria.totalHeight * 0.015),
                  CarouselSlider(
                      items: items,
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayAnimationDuration: Duration(seconds: 5),
                        autoPlayInterval: Duration(seconds: 5),
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        viewportFraction: 0.928,
                        aspectRatio: 343/168,
                      )
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Spacer(flex: 1106,),
                       _userNickname(context),
                        Spacer(flex: 220,),
                        _focusModeButton(context),
                        Spacer(flex: 590,),
                        Container(
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 26, spreadRadius: 0, offset: Offset(-4, 0))]
                            ),
                            child: Text("출석 인증하기", style: TextStyle(letterSpacing: 1.84, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), fontSize: _uiCriteria.textSize4),)),
                        Spacer(flex: 100,),
                        Container(
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 26, spreadRadius: 0, offset: Offset(-4, 0))]
                            ),
                            child: Image.asset("assets/png/double_arrow.png")),
                        Spacer(flex: 360,),
                      ],
                    ),
                  ),
                  ]),
            ),
      ],
    );
  }

  void _checkBanner2() {
    if (_bs.getEventStatus() == 1) {
      _bs.setEventStatus(0);
      _showBanner();
    }
  }

  void _showBanner() async {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _banner();
        }
    );
  }

  Widget _banner() {
    AlertDialog dialog = new AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        content: AspectRatio(
            aspectRatio: 343/343.4,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
                return Container(
                  padding: EdgeInsets.all(constraint.maxWidth * 0.0233),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _bannerTap,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("assets/png/banner.png"),
                                  fit: BoxFit.fill
                              )
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(constraint.maxWidth * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:  <Widget>[
                            GestureDetector(
                              onTap: _noToday,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.check_circle_outline_sharp, color: Colors.white, size: _uiCriteria.textSize2,),
                                  Text("  오늘 그만 보기", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize5),)
                                ],
                              ),
                            ),
                            GestureDetector(
                                onTap: closeTap,
                                child: Icon(Icons.close, color: Colors.white, size: _uiCriteria.textSize6,))
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
        )
    );
    return dialog;
  }

  void _noToday() async {
    var url = Uri.parse("http://$speckUrl/home/banner");
    String body = '''{
      "userEmail" : "${_sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    await http.post(url, body: body, headers: header);
    Navigator.pop(context);
  }

  void closeTap() {
    Navigator.pop(context);
  }

  void _bannerTap() async {
    String package;
    String urlScheme;
    bool isInstalled;

    if (Platform.isAndroid) {
      package = "https://play.google.com/store/apps/details?id=com.instagram.android";
    }
    else if (Platform.isIOS){
      package = "https://apps.apple.com/us/app/instagram/id389801252";
    }
    urlScheme = "instagram://user?username=speck_app";

    await canLaunch("instagram://app").then((value) => isInstalled = value).onError((error, stackTrace) {
      print("설치여부 $error");
      return false;
    });

    if (isInstalled) {
      try {
        launch(urlScheme);
      }
      catch (e) {
        print(e);
      }
    }
    else {
      try {
        launch(package);
      }
      catch (e) {
        print(e);
      }
    }

  }


  /// 유저 레벨정보 가져오기
  Widget _userLevel(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.32),
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 119/24,
          child: SpeechBubble(
            padding: EdgeInsets.zero,
            borderRadius: 85,
            color: Color(0XFF404040),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(letterSpacing: 0.5,color: greyD8D8D8, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),
                    children: <TextSpan>[
                      TextSpan(text: "나는 "),
                      TextSpan(text: "$_dust", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      TextSpan(text: " 단계"),
                    ]
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    child: Icon(Icons.chevron_right, size: _uiCriteria.textSize4, color: greyD8D8D8,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userNickname(BuildContext context) {
    return  GestureDetector(
      onTap: () => _pageState.setIndex(3),
      child: SpeechBubble(
          padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.032, right: _uiCriteria.screenWidth * 0.014,
              top: _uiCriteria.totalHeight * 0.0098, bottom: _uiCriteria.totalHeight * 0.0098),
          borderRadius: 85,
          color: Color(0XFF404040),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$_nickname", style: TextStyle(letterSpacing: 0.5,color: greyD8D8D8, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3)),
              GestureDetector(
                child: Icon(Icons.chevron_right, size: _uiCriteria.textSize4, color: greyD8D8D8,),
              ),
            ],
          ),

      ),
    );
  }

  /// 집중모드 버튼 가져오기
  Widget _focusModeButton(BuildContext context) {
    AboutTime timer = Provider.of<AboutTime>(context, listen: false);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.3779),
      // height: _uiCriteria.screenWidth * 0.305,
      child: AspectRatio(
        aspectRatio: 915.2/878.4,
        child:  GestureDetector(
            // onTap: () async {
            //   // 실시간 집중모드 사용인원 업데이트
            //   _updateNumFocus();
            //   List<dynamic> result;
            //   Future<List<dynamic>> future1 = _getPastTime();
            //   await future1.then((value) => result = value,
            //       onError: (e) => print(e));
            //   for (int i = 0; i < result.length; i++) {
            //     if (times.length <= 7) {
            //       if (result[i] == null) {
            //         times.add(0);
            //       } else {
            //         times.add(result[i]["focusTime"]);
            //       }
            //     }
            //   }
            //   setState(() {
            //     _bottomSheetOpened = true;
            //   });
            //   Future<int> future = _getCurTime();
            //   await future.then((value) => _currentSec = value,
            //       onError: (e) => print(e));
            //   bottomSheetController = showModalBottomSheet(
            //       context: context,
            //       builder: _buildTimer,
            //       backgroundColor: Colors.transparent)
            //     ..whenComplete(() {
            //       timer.pauseTimer();
            //       print("specksochet: ${SpeckApp.socket}");
            //       SpeckApp.socket.send(_userTypeMode0);
            //       setState(() {
            //         _bottomSheetOpened = false;
            //       });
            //     });
            //   if (!timer.isRunning) {
            //     timer.startTimer();
            //   }
            // },
            // child: Image.network("http://icnogari96.cafe24.com:8080/resources/purple_att.png", scale: 0.1,)
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 26, spreadRadius: 0, offset: Offset(-4, 0))],
                    image: DecorationImage(
                        image: AssetImage(getCharacter(_character)),
                        fit: BoxFit.fill
                    )
                )
            ),
                // child: Image.asset()),

        ),
      ),
    );
  }

  Future<int> _getCurTime() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getInt("seconds") == null) {
      await sp.setInt("seconds", 0);
    }
    int currentSec = sp.getInt("seconds");
    return Future<int>(() {
      return currentSec;
    });
  }

  List<FocusTimeData> data;

  List<charts.Series<FocusTimeData, String>> _getSeriesData() {
    List<charts.Series<FocusTimeData, String>> series = [
      charts.Series(
        id: "FocusTime1",
        data: data,
        domainFn: (FocusTimeData data, _) => data.date.toString(),
        measureFn: (FocusTimeData data, _) => (data.time / 3600),
        colorFn: (FocusTimeData data, _) => data.barColor,
        fillColorFn: (FocusTimeData data, _) =>
            charts.ColorUtil.fromDartColor(Colors.transparent),
      ),
      charts.Series(
        id: "FocusTime",
        data: data,
        domainFn: (FocusTimeData data, _) => data.date.toString(),
        measureFn: (FocusTimeData data, _) => (data.time / 3600),
        colorFn: (FocusTimeData data, _) => data.barColor,
      ),
      charts.Series(
        id: "FocusTime2",
        data: data,
        domainFn: (FocusTimeData data, _) => data.date.toString(),
        measureFn: (FocusTimeData data, _) => (data.time / 3600),
        colorFn: (FocusTimeData data, _) => data.barColor,
        fillColorFn: (FocusTimeData data, _) =>
            charts.ColorUtil.fromDartColor(Colors.transparent),
      )
    ];
    return series;
  }

  /// 타이머 가져오기
  Widget _buildTimer(BuildContext context) {
    AboutTime timer = Provider.of<AboutTime>(context, listen: true);
    int totalTime = _currentSec + timer.seconds;
    int hour = (totalTime) ~/ (60 * 60);
    int min = (totalTime - (hour * 60 * 60)) ~/ 60;
    int sec = (totalTime) - (hour * 60 * 60) - (min * 60);
    int sum = 0;
    int max = 0;
    for (int i = 0; i < times.length; i++) {
      if (max < times[i]) {
        // 최고시간(임계치 구하는데 사용)
        max = times[i];
      }
      sum += times[i];
    }
    double mean = sum / 7;
    int mHour = mean ~/ (60 * 60);
    int mMinute = (mean - (mHour * 60 * 60)) ~/ 60;
    DateTime today = DateTime.now().add(Duration(hours: 9));
    data = [
      FocusTimeData(
          date: (today.add(Duration(days: -6))).day,
          time: times[times.length - 2],
          barColor: charts.ColorUtil.fromDartColor(mainColor)),
      FocusTimeData(
          date: (today.add(Duration(days: -5))).day,
          time: times[times.length - 3],
          barColor: charts.ColorUtil.fromDartColor(mainColor)),
      FocusTimeData(
          date: (today.add(Duration(days: -4))).day,
          time: times[times.length - 4],
          barColor: charts.ColorUtil.fromDartColor(mainColor)),
      FocusTimeData(
          date: (today.add(Duration(days: -3))).day,
          time: times[times.length - 5],
          barColor: charts.ColorUtil.fromDartColor(mainColor)),
      FocusTimeData(
          date: (today.add(Duration(days: -2))).day,
          time: times[times.length - 6],
          barColor: charts.ColorUtil.fromDartColor(mainColor)),
      FocusTimeData(
          date: (today.add(Duration(days: -1))).day,
          time: times[times.length - 7],
          barColor: charts.ColorUtil.fromDartColor(mainColor)),
      FocusTimeData(
        date: today.day,
        time: totalTime,
        barColor: charts.ColorUtil.fromDartColor(mainColor),
      ),
    ];
    return AspectRatio(
      aspectRatio: 375/403.5,
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.497,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(13.8), topLeft: Radius.circular(13.8)),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
              children: <Widget>[
                Container(
                    height: constraint.maxHeight * 0.099,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyD8D8D8))
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "집중모드",
                            style: TextStyle(
                                letterSpacing: 0.7,
                                color: mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: _uiCriteria.textSize2),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("실시간 집중 인원 ",
                                  style: TextStyle(
                                      letterSpacing: 0.7,
                                      color: mainColor,
                                      fontSize: _uiCriteria.textSize2,
                                      fontWeight: FontWeight.w500
                                  )),
                              Text("${_numFocus.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}명", style: TextStyle(
                                color: mainColor,
                                letterSpacing: _uiCriteria.screenWidth * 0.0018,
                                fontSize: _uiCriteria.textSize2,
                                fontWeight: FontWeight.w700,
                              ))
                            ],
                          )
                        ])
                ),
                Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),

                      child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: constraint.maxHeight * 0.094),
                              child: Text(
                                "${hour.toString().padLeft(2, "0")} : ${min.toString().padLeft(2, "0")} : ${sec.toString().padLeft(2, "0")}",
                                style: TextStyle(
                                    color: mainColor,
                                    letterSpacing: 1.2,
                                    fontSize: _uiCriteria.screenWidth * 0.064,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: constraint.maxHeight * 0.025),
                              child: Text("다른 곳을 터치하면 시간이 정지합니다",
                                  style: TextStyle(
                                      letterSpacing: 0.7,
                                      color: greyAAAAAA,
                                      fontSize: _uiCriteria.textSize2,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: constraint.maxHeight * 0.089),
                              height: constraint.maxHeight * 0.311,
                              child: charts.BarChart(
                                _getSeriesData(),
                                behaviors: [
                                  charts.RangeAnnotation([
                                    charts.LineAnnotationSegment(
                                      mean / 3600,
                                      charts.RangeAnnotationAxisType.measure,
                                      color: charts.MaterialPalette.black,
                                      strokeWidthPx: 1,
                                      dashPattern: [4],
                                    )
                                  ])
                                ],
                                animate: true,
                                barGroupingType: charts.BarGroupingType.grouped,
                                domainAxis: charts.OrdinalAxisSpec(
                                  renderSpec: charts.SmallTickRendererSpec(
                                      labelOffsetFromAxisPx: (constraint.maxHeight * 0.02974).round(),
                                      tickLengthPx: 0,
                                      labelRotation: 0,
                                      labelStyle: charts.TextStyleSpec(
                                        fontSize: (_uiCriteria.screenWidth * 0.026).round(),
                                        color: charts.MaterialPalette.black,
                                      ),
                                      lineStyle: charts.LineStyleSpec(
                                        thickness: 1,
                                        color: charts.MaterialPalette.black,
                                      )),
                                ),
                                primaryMeasureAxis: charts.NumericAxisSpec(
                                  tickProviderSpec: ((max ~/ 3600) == 0)?charts.BasicNumericTickProviderSpec(desiredTickCount: 2):charts.BasicNumericTickProviderSpec(desiredTickCount: 3),
                                  tickFormatterSpec: charts.BasicNumericTickFormatterSpec((num value) => "${value.toInt()}시간"),
                                  renderSpec: charts.GridlineRendererSpec(
                                      labelOffsetFromAxisPx: (constraint.maxWidth * 0.032).round(),
                                      lineStyle: charts.LineStyleSpec(
                                          thickness: 1, color: charts.Color.fromHex(code: "#d8d8d8")),
                                      labelStyle: charts.TextStyleSpec(
                                          fontSize: (_uiCriteria.screenWidth * 0.026).round(),
                                          color: charts.MaterialPalette.black)),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: constraint.maxHeight * 0.062),

                              child: Text(
                                "이번주 일일 평균 $mHour시간 $mMinute분",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    color: Colors.black,
                                    fontSize: _uiCriteria.screenWidth * 0.0266,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                            ),
                          ]
                      ),
                    )
                )

              ],
            );
          }
        ), //
      ),
    );
  }

  void _cardTap(String galaxyName, String imagePath, int galaxyNum, int official, int timeNum) {
    _es.setGalaxyName(galaxyName);
    _es.setGalaxyNum(galaxyNum);
    _es.setImagePath(imagePath);
    _es.setOfficial(official);
    _es.setRoute(_route);
    _es.setSelectedDate(DateTime.now().toString().substring(0, 10));
    _es.setSelectedDateWeekdayText("오늘");
    _es.setTimeNum(timeNum);
    _es.setTimeList(_timeList);
    Navigator.push((context), MaterialPageRoute(builder: (context) => Explorer(
        galaxyName: galaxyName,
        imageUrl: imagePath,
        galaxyNum: galaxyNum,
        official: official,
        timeNum: timeNum,)));
  }
}
