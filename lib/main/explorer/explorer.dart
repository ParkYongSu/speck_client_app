import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speck_app/State/explorer_tab_state.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/main/explorer/explorer_detail.dart';
import 'package:speck_app/main/plan/galaxy_detail.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Explorer extends StatefulWidget {
  final String galaxyName; // 학교이름
  final String imageUrl; // 프로필
  final int galaxyNum; // 학교아이디
  final int official;
  final int timeNum;

  const Explorer({
    Key key,
    @required this.galaxyName,
    @required this.imageUrl,
    @required this.galaxyNum,
    @required this.official,
    @required this.timeNum}) : super(key: key);

  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> with TickerProviderStateMixin {
  UICriteria _uiCriteria = new UICriteria();
  TabController _controller;
  int _route;
  ExplorerTabState _ets;
  CardTime _cardTime;

  @override
  void initState() {
    super.initState();
    _route = 1;
    _controller = new TabController(length: 3, vsync: this);
  }


  @override
  void dispose() {
    super.dispose();
    _cardTime.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    _ets = Provider.of<ExplorerTabState>(context);
    _cardTime = Provider.of<CardTime>(context, listen: false);
    _controller.index = _ets.getTabIndex();
    _controller.addListener(() {
      _ets.setTabIndex1(_controller.index);
    });
    _uiCriteria.init(context);
    return _explorer();
  }
  
  Widget _explorer() {
    return MaterialApp(
      title: "탐험단",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: mainColor,
        appBar: appBar(context, "나의 탐험단"),
        body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: mainColor,
              ),
              child: TabBar(
                controller: _controller,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: _uiCriteria.totalHeight * 0.049,
                    child: Text("갤럭시", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: _uiCriteria.totalHeight * 0.049,
                    child: Text("탐험단",  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: _uiCriteria.totalHeight * 0.049,
                    child: Text("채팅",  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                  )
                ],
              ),
            ),
            Expanded(
              child: _tabView()
            )
          ],
        ),
      ),
    );
  }

  Widget _tabView() {
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        GalaxyDetail(
            route: _route,
            galaxyName: widget.galaxyName,
            imagePath: widget.imageUrl,
            galaxyNum: widget.galaxyNum,
            official: widget.official,
        ),
        ExplorerDetail(
          route: _route,
        ),
        Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: _uiCriteria.appBarHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("스펙 오픈채팅방", style: TextStyle(fontSize: _uiCriteria.textSize1, color: mainColor, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                GestureDetector(
                    onTap: () => launch("https://open.kakao.com/o/g5wavQmd"),
                    child: Text("https://open.kakao.com/o/g5wavQmd", style: TextStyle(decoration: TextDecoration.underline,fontSize: _uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.bold))),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Text("참여코드: G01T", style: TextStyle(fontSize: _uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.bold)),
              ],
            )
        )
      ],
    );
  }
}
