import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:speck_app/Main/my/setting/my_settings.dart';
import 'package:speck_app/State/searching_word_state.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/auth/select_auth_method.dart';
import 'package:speck_app/auth/todo_auth.dart';
import 'package:speck_app/Main/explorer/main_explorer.dart';
import 'package:speck_app/Main/notify/main_notify.dart';
import 'package:speck_app/Map/main_map.dart';
import 'package:speck_app/State/notice.dart';
import 'package:provider/provider.dart';

import 'package:speck_app/Main/plan/main_galaxy.dart';
import 'package:speck_app/auth/qr_scanner.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'home/main_home.dart';
import 'home/page_state.dart';
import 'my/home/main_my.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final UICriteria _uiCriteria = new UICriteria();
  List<Widget> _widgetOptions = <Widget>[
    MainHome(),
    MainPlan(),
    MainExplorer(),
    MainMyPage(),
    MainNotifyPage()
  ];

  TodoAuth todoAuth = new TodoAuth();

  CardTime _cardTime;
  PageState _ps;

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    print("hihi");
    _ps.setIndex1(0);
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _cardTime = Provider.of<CardTime>(context, listen: false);
    _ps = Provider.of<PageState>(context, listen: false);

    return Consumer<PageState>(
      builder: (BuildContext context, PageState pageState, Widget child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody:(pageState.getIndex() == 0)? true:false,
          extendBodyBehindAppBar: (pageState.getIndex()  == 0)?true:false,
          appBar: (pageState.getIndex() == 1)
              ? AppBar(
            toolbarHeight: _uiCriteria.appBarHeight,
            backgroundColor: mainColor,
            centerTitle: true,
            titleSpacing: 0,
            elevation: 0,
            backwardsCompatibility: false,
            // brightness: Brightness.dark,
            systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
            title: Container(
              alignment: Alignment.center,
              child: Text("전체 갤럭시", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1),),
            ),
          )
              :(pageState.getIndex() == 4)
              ? AppBar(
            toolbarHeight: _uiCriteria.appBarHeight,
            elevation: 0,
            backgroundColor: mainColor,
            centerTitle: true,
            titleSpacing: 0,
            backwardsCompatibility: false,
            // brightness: Brightness.dark,
            systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
            title: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.008, right: _uiCriteria.horizontalPadding),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                            child:  Icon(Icons.chevron_left_rounded,
                                color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                            onTap: () {
                              pageState.setIndex(0);
                              // __pageState.getIndex() = _pageState.getIndex();
                              Notice notice = Provider.of<Notice>(context, listen: false);
                              notice.clearWidgetList();
                              notice.clearNotRead();
                              notice.setZero();
                            }),
                        GestureDetector(
                          child: Container(child: Image.asset("assets/png/settings.png", height: _uiCriteria.textSize4,)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Settings())),
                        )
                      ]
                  ),
                ),
                Text("알림", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1))
              ],
            ),
          )
              : (pageState.getIndex() == 2)
              ? AppBar(
            toolbarHeight: _uiCriteria.appBarHeight,
            elevation: 0,
            backgroundColor: mainColor,
            titleSpacing: 0,
            centerTitle: true,
            backwardsCompatibility: false,
            // brightness: Brightness.dark,
            systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
            title: Text("나의 탐험단", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1)),
          )
              : (pageState.getIndex() == 3)
              ? AppBar(
              toolbarHeight: _uiCriteria.appBarHeight,
              elevation: 0,
              backgroundColor: mainColor,
              titleSpacing: 0,
              backwardsCompatibility: false,
              // brightness: Brightness.dark,
              systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
              centerTitle: true,
              title: Stack(
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        width: _uiCriteria.screenWidth,
                        child: Text("마이페이지", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize1,))),
                    Container(
                      padding: EdgeInsets.only(right: _uiCriteria.horizontalPadding),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent)
                              ),
                              child: Image.asset("assets/png/settings.png", color: Colors.white, height: _uiCriteria.screenWidth * 0.0573,))
                      ),
                    )
                  ]
              )
          )
              :AppBar(
              toolbarHeight: _uiCriteria.appBarHeight,
              elevation: 0,
              brightness: Brightness.dark,
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              backwardsCompatibility: false,
              // brightness: Brightness.dark,
              systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset(
                          "assets/png/main_logo.png",
                          height: _uiCriteria.screenWidth * 0.0533
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                pageState.setIndex(4);
                              },
                              child: Image.asset("assets/png/notify.png", height: _uiCriteria.screenWidth * 0.0533,),
                            ),
                            SizedBox(width: _uiCriteria.textSize1,),
                            GestureDetector(
                              onTap: () {
                                SearchingWordState sws = Provider.of<SearchingWordState>(context, listen: false);
                                sws.setSearchingWord("스펙존 지도");
                                _cardTime.stopTimer();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MainMap()));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.transparent)
                                ),
                                child: Image.asset(
                                    "assets/png/map.png",
                                    height: _uiCriteria.screenWidth * 0.0533
                                ),
                              ),
                            )
                          ]
                      ),
                    ]
                ),
              )
          ),
          backgroundColor: (pageState.getIndex() == 0)? mainColor : Colors.white,
          body: _widgetOptions[pageState.getIndex()],
          floatingActionButton:
          Padding(
            padding: EdgeInsets.only(top: _uiCriteria.screenWidth * 0.05),
            child: Container(
              width: _uiCriteria.screenWidth * 0.1365,
              height: _uiCriteria.screenWidth * 0.1365,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle
              ),
              child: FloatingActionButton(
                elevation: 0,
                highlightElevation: 0,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: _uiCriteria.screenWidth * 0.1186,
                    height: _uiCriteria.screenWidth * 0.1186,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: mainColor, width: 2)
                    ),
                  ),
                ),
                onPressed: () {
                  _cardTime.stopTimer();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AuthMethod()));
                },
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            elevation: 10,
            color: mainColor,
            child: AspectRatio(
                aspectRatio: 375/60,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraint) {
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.00666, vertical: constraint.maxHeight * 0.175),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  pageState.setIndex(0);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.transparent)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset((pageState.getIndex() == 0)?"assets/png/main_home_fill.png":"assets/png/home.png", height: constraint.maxHeight * 0.32, fit: BoxFit.fill,),
                                      Text("홈", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize7, ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  pageState.setIndex(1);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.transparent)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset((pageState.getIndex() == 1)?"assets/png/main_galaxy_fill.png":"assets/png/galaxy.png", height: constraint.maxHeight * 0.32, fit: BoxFit.fill,),
                                      Text("갤럭시", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize7,letterSpacing: 0.45))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: constraint.maxWidth * 0.1744,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  pageState.setIndex(2);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.transparent)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset((pageState.getIndex() == 2)?"assets/png/main_explorer_fill.png":"assets/png/explorer.png", height: constraint.maxHeight * 0.32, fit: BoxFit.fill,),
                                      Text("탐험단", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize7,letterSpacing: 0.45),)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  pageState.setIndex(3);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.transparent)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset((pageState.getIndex() == 3)?"assets/png/main_my_fill.png":"assets/png/my.png", height: constraint.maxHeight * 0.32, fit: BoxFit.fill,),
                                      Text("마이페이지", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize7, letterSpacing: 0.45))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]
                      ),

                    );
                  },
                )
            ),
          ),
        );
      },
    );
  }

}
