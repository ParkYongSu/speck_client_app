
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/main/explorer/chat_page.dart';
import 'package:speck_app/main/explorer/chat_user_state.dart';
import 'package:speck_app/main/explorer/explorer_detail.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';

class Explorer extends StatefulWidget {
  final int galaxyNum;

  const Explorer({Key key, @required this.galaxyNum}) : super(key: key);

  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> with TickerProviderStateMixin {
  UICriteria _uiCriteria = new UICriteria();
  TabController _controller;
  ChatUserState _cus;
  SharedPreferences _sp;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    _controller.addListener(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      if (_controller.index == 0) {
        _cus.setCount(0);
      }
    });
    _getSharedPreferences();
  }

  Future<dynamic> _getSharedPreferences() async {
    _sp = await SharedPreferences.getInstance();
    return _sp;
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _cus = Provider.of<ChatUserState>(context, listen: false);
    return _explorer();
  }
  
  Widget _explorer() {
    return FutureBuilder(
      future: _getSharedPreferences(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                    Container(
                      alignment: Alignment.center,
                      height: _uiCriteria.totalHeight * 0.049,
                      child: Text("탐험단",  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: _uiCriteria.totalHeight * 0.049,
                      child: Text((_cus.getCount() == null || _cus.getCount() == 0)?"채팅":"채팅(${_cus.getCount()}명)",  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
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
      },
    );
  }

  Widget _tabView() {
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        ExplorerDetail(),
        ChatPage(galaxyNum: widget.galaxyNum, token: _sp.getString("token"), id: _sp.getInt("userId"), email: _sp.getString("email"),)
      ],
    );
  }
}
