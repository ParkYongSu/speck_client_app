import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/main/explorer/chat_user_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final int galaxyNum;
  final String token;
  final int id;
  final String email;

  const ChatPage({Key key, this.galaxyNum, this.token, this.id, this.email}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Widget> _chatElements = [];
  TextEditingController _chatController = new TextEditingController();
  FocusNode _focusNode = new FocusNode();
  ScrollController _scrollController = new ScrollController();
  DateTime _now = DateTime.now();
  GlobalKey _chatAreaKey = new GlobalKey();
  RenderBox _viewBox;
  bool _isRender = false;
  double _chatBoxMaxHeight;
  StompClient _stompClient;
  final String _socketUrl = "wss://api.speck.kr/websocket";
  // SharedPreferences _sp;
  List<Widget> _myList = [];
  List<dynamic> _chatData;
  List<List<dynamic>> _chatGroup = [];
  List<dynamic> _chatMessageNumList;
  int _isJoin;
  int _chatRoomId;
  ChatUserState _cus;

  @override
  void initState() {
    super.initState();
    _getChatAreaSize();
    _connectChat();
  }

  @override
  void dispose() {
    super.dispose();
    _stompClient.deactivate();
  }

  void _createStomp() {
    _stompClient = new StompClient(
     config: StompConfig(
        url: _socketUrl,
        onConnect: _onConnectCallback,
    ));
  }

  void _connectChat() async {
    // _sp = await SharedPreferences.getInstance();
    _createStomp();
    _stompClient.activate();
    _enter();
  }

  void _onConnectCallback(StompFrame stompFrame) {
    print("연결 성공");
    print(_stompClient.connected);
    _stompClient.subscribe(
        destination: "/topic/galaxy/${widget.galaxyNum}",
        callback: _messageCallback
    );
  }

  void _messageCallback(StompFrame frame) {
    setState(() {});
  }

  void _enter() {
    _stompClient.send(
      destination: "/app/chat.register",
      body: """{
        "email" : "${widget.email}"
      }"""
    );
  }

  void _sendMessage(String content) {
    String body = """{
           "galaxyNum" : ${widget.galaxyNum},
           "roomId" : $_chatRoomId,
           "email" : "${widget.email}",
           "content" : "$content",
           "userId" : ${widget.id}
        }""";
    _stompClient.send(
        destination: "/app/chat.send",
        body: body
    );
    print(body);
  }

  @override
  Widget build(BuildContext context) {
    _cus = Provider.of<ChatUserState>(context, listen: false);
    return _chatPage();
  }

  Widget _chatPage() {
    return FutureBuilder(
      future: _getChatRecord(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _scrollToBottom();
          _setChatData(snapshot.data);
          return Container(
            decoration: BoxDecoration(
                color: Colors.white
            ),
            child: Column(
              children: [
                Expanded(
                  key: _chatAreaKey,
                  child: GestureDetector(
                    onTap: _initFocus,
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: _chatElements.length,
                      itemBuilder: _itemBuilder,
                    ),
                  ),
                ),
                _chatField()
              ],
            ),
          );
        }
        return Container(
            key: _chatAreaKey,
            child: loader(context, 0));
      },
    );
  }

  Future<dynamic> _getChatRecord() async {
    var url = Uri.parse("$speckUrl/chat/chatroom/${widget.galaxyNum}");
    print(url.toString());
    Map<String,String> header = {
      "Content-Type" : "application/json",
      "Authorization" : "${widget.token}"
    };
    var response = await http.post(url, headers: header);
    dynamic result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return Future(() {
      return result;
    });
  }

  void _setChatData(dynamic data) {
    _isJoin = data["enter"];
    _chatRoomId = data["chatroomId"];
    _cus.setCount(data["userCount"]);
    _chatData = data["chatMessageDVOs"];
    _chatMessageNumList = data["chatMessageNumList"];

    _chatElements.clear();
    int k = 0;
    String tempEmail;
    String tempTime;
    List<int> timeAlgo = [];
    for (int i = 0; i < _chatData.length - 1; i ++) {
      if (_chatData[i]["email"] == _chatData[i+1]["email"]
          && "${DateTime.parse(_chatData[i]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[i]["sendTime"]).minute.toString().padLeft(2, "0")}"
              == "${DateTime.parse(_chatData[i+1]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[i+1]["sendTime"]).minute.toString().padLeft(2, "0")}") {
        timeAlgo.add(0);
      }
      else {
        timeAlgo.add(1);
      }
    }
    timeAlgo.add(1);

    for (int j = 0; j < _chatMessageNumList.length; j++) {
      Map date = _chatMessageNumList[j];
      _chatElements.add(_date(date.keys.elementAt(0).toString()));
      List<Widget> bubbles = [];
      int bubbleIndex;
      for (int m = k; m < k + _chatMessageNumList[j]["${date.keys.elementAt(0)}"]; m++) {
        if (_chatData[m]["email"] == widget.email) {
          bubbles = [];
          _chatElements.add(_mySpeechBubble(_chatData[m]["content"], "${DateTime.parse(_chatData[m]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[m]["sendTime"]).minute.toString().padLeft(2, "0")}", timeAlgo[m]));
        }
        else {
          if (m > 0 && _chatData[m]["email"] == _chatData[m-1]["email"]) {
            _chatElements.removeAt(_chatElements.length - 1);
            bubbles.add(_userSpeechBubble(_chatData[m]["content"], "${DateTime.parse(_chatData[m]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[m]["sendTime"]).minute.toString().padLeft(2, "0")}", timeAlgo[m]));
            _chatElements.add(_user(_chatData[m]["profileImg"], _chatData[m]["nickname"], _chatData[m]["content"], _chatData[m]["characterIndex"],
                "${DateTime.parse(_chatData[m]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[m]["sendTime"]).minute.toString().padLeft(2, "0")}", timeAlgo[m], bubbles));
          }
          else {
            bubbles = [];
            bubbles.add(_userSpeechBubble(_chatData[m]["content"], "${DateTime.parse(_chatData[m]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[m]["sendTime"]).minute.toString().padLeft(2, "0")}", timeAlgo[m]));
            _chatElements.add(_user(_chatData[m]["profileImg"], _chatData[m]["nickname"], _chatData[m]["content"], _chatData[m]["characterIndex"],
                "${DateTime.parse(_chatData[m]["sendTime"]).hour.toString().padLeft(2, "0")}:${DateTime.parse(_chatData[m]["sendTime"]).minute.toString().padLeft(2, "0")}", timeAlgo[m], bubbles));
          }
        }
      }
      k = _chatMessageNumList[j]["${date.keys.elementAt(0)}"];
    }
  }

  void _initFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Widget _itemBuilder(BuildContext context, int itemCount) {
    return _chatElements[itemCount];
  }

  Widget _chatField() {
    return Container(
      decoration: BoxDecoration(
        color: (_isJoin == 0)?Color(0XFF404040).withOpacity(0.5):Colors.white
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, spreadRadius: 0, offset: Offset(0, -8))]
              ),
              child: _textField(),
            ),
            (_isJoin == 0)
            ? _block()
            : Container()
          ],
        ),
      ),
    );
  }

  Widget _block() {
    return AspectRatio(
      aspectRatio: 375/50,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0XFF404040).withOpacity(0.5)
        ),
        child: Text("가입하지 않은 탐험단에서는 채팅을 주고받을 수 없어요.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5, letterSpacing: 0.5),),
      ),
    );
  }

  Widget _textField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: uiCriteria.textSize2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3183,
            child: TextField(
              // onTap: _scrollToBottom,
              maxLines: 4,
              minLines: 1,
              focusNode: _focusNode,
              style: TextStyle(height: 1.5, color: mainColor, fontSize: uiCriteria.textSize3, letterSpacing: 0.48, fontWeight: FontWeight.w500),
              controller: _chatController,
              cursorColor: mainColor,
              decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.only(right: uiCriteria.horizontalPadding),
                  hintText: "메시지를 입력하세요.",
                  hintStyle: TextStyle(color: greyB3B3BC, fontSize: uiCriteria.textSize3, letterSpacing: 0.48, fontWeight: FontWeight.w500),
                  border: InputBorder.none
              ),
            ),
          ),
          Expanded(
            flex: 247,
            child: GestureDetector(
              onTap: () => (_chatController.text.trim().isEmpty)?null:_transfer(_chatController.text),
              child: Image.asset("assets/png/transfer_icon.png", fit: BoxFit.fill, color: mainColor,),
            ),
          )
        ],
      ),
    );
  }

  Widget _time(String sendTime) {
    return Text(sendTime, style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5),);
  }

  /// 내 말풍선
  Widget _mySpeechBubble(String text, String sendTime, int index) {
    return  Container(
      padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
      margin: EdgeInsets.only(bottom: uiCriteria.screenWidth * 0.0148),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            (index == 0)
            ? Container()
            : Text(sendTime + "  ", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5),),
            Container(
              constraints: BoxConstraints(
                  maxWidth: uiCriteria.screenWidth * 0.5947,
                  maxHeight: 200
              ),
              padding: EdgeInsets.all(uiCriteria.textSize5),
              decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(3.5)
              ),
              child: Text(text,style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userSpeechBubble(String text, String sendTime, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: uiCriteria.screenWidth * 0.0148),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: uiCriteria.screenWidth * 0.5947
              ),
              padding: EdgeInsets.all(uiCriteria.textSize5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: greyB3B3BC, width: 0.5),
                  borderRadius: BorderRadius.circular(3.5)
              ),
              child: Text(text, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
            ),
            (index == 0)
            ? Container()
            : Text("  " + sendTime, style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5),),
          ],
        ),
      ),
    );
  }

  Widget _user(String imagePath, String nickname, String text, int characterIndex, String sendTime, int index, List<Widget> userBubbles) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding, vertical: uiCriteria.totalHeight * 0.0074),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: uiCriteria.screenWidth * 0.0987,
            height: uiCriteria.screenWidth * 0.0987,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: (imagePath == null || imagePath == "N")
                        ?AssetImage(getCharacter(characterIndex))
                        :NetworkImage(imagePath),
                    fit: BoxFit.fill
                )
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.032),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: uiCriteria.screenWidth * 0.0148),
                  child: Text(nickname, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5),),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: userBubbles,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 날짜 표시
  Widget _date(String strDate) {
    DateTime dt = DateTime.parse(strDate);
    String date = "${dt.year}년 ${dt.month}월 ${dt.day}일";
    return Padding(
      padding: EdgeInsets.symmetric(vertical: uiCriteria.totalHeight * 0.0222),
      child: Row(
        children: <Widget>[
          Expanded(child: Container(height: 0.5 ,decoration: BoxDecoration(color: greyAAAAAA.withOpacity(0.5)),),),
          Container(
            padding: EdgeInsets.symmetric(horizontal: uiCriteria.textSize3),
            child: Text(date, style: TextStyle(fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500, color: greyAAAAAA, letterSpacing: 0.6),)),
          Expanded(child: Container(height: 0.5 ,decoration: BoxDecoration(color: greyAAAAAA.withOpacity(0.5)),),),
        ],
      ),
    );
  }

  void _transfer(String text) {
    _sendMessage(text);
    _chatController.clear();
    _scrollToBottom();
  }

  /// 가장 밑으로 스크롤
  void _scrollToBottom() {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent);
          // duration: const Duration(milliseconds: 100),
          // curve: Curves.fastOutSlowIn);
    });
  }

  void _getChatAreaSize() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isRender) {
        _viewBox = _chatAreaKey.currentContext.findRenderObject();
        _isRender = true;
        _chatBoxMaxHeight = _viewBox.size.height * 0.9002;
      }
    });
  }
}
