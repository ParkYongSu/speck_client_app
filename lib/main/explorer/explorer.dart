import 'package:flutter/material.dart';
import 'package:speck_app/main/explorer/chat_page.dart';
import 'package:speck_app/main/explorer/explorer_detail.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Explorer extends StatefulWidget {

  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> with TickerProviderStateMixin {
  UICriteria _uiCriteria = new UICriteria();
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return _explorer();
  }
  
  Widget _explorer() {
    return Scaffold(
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
                // Container(
                //   alignment: Alignment.center,
                //   height: _uiCriteria.totalHeight * 0.049,
                //   child: Text("갤럭시", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                // ),
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
    );
  }

  Widget _tabView() {
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        // GalaxyDetail(
        //     route: _route,
        //     galaxyName: widget.galaxyName,
        //     imagePath: widget.imageUrl,
        //     galaxyNum: widget.galaxyNum,
        //     official: widget.official,
        // ),
        ExplorerDetail(),
        ChatPage()
      ],
    );
  }
}
