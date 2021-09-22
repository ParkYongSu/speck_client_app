import 'package:flutter/material.dart';
import 'package:speck_app/event/event_detail.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  bool _currentTapped;

  @override
  void initState() {
    super.initState();
    _currentTapped = true;
  }

  @override
  Widget build(BuildContext context) {
    return _eventListPage();
  }
  
  Widget _eventListPage() {
    return Scaffold(
      appBar: appBar(context, "이벤트"),
      body: Column(
        children: <Widget>[
          _doubleButton(),
          greyBar(),
          (_currentTapped)
          ? _currentEventList()
          : _expiredEventList()
        ],
      ),
    );
  }

  Widget _doubleButton() {
    return AspectRatio(
      aspectRatio: 375/91,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFCACAD1), width: 0.5))
        ),
        padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
        child: Row(
          children: <Widget>[
            _button(mainColor, greyD8D8D8,Colors.white, mainColor, "진행중인 이벤트", _currentTap),
            SizedBox(width: 12,),
            _button(greyD8D8D8, mainColor,mainColor, Colors.white,"완료된 이벤트", _expiredTap)
          ],
        ),
      ),
    );
  }

  Widget _button(Color color1, Color color2, Color fontColor1, Color fontColor2, String title, void onPressed()) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 166/50,
        child: MaterialButton(
          elevation: 0,
          color: (_currentTapped)?color1:color2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.5)
          ),
          onPressed: onPressed,
          child: Text(title, style: TextStyle(fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w700, color: (_currentTapped)?fontColor1:fontColor2, letterSpacing: 0.7),),
        ),
      ),
    );
  }

  Widget _currentEventList() {
    List<Widget> eventList = [
      GestureDetector(
        child: AspectRatio(
          aspectRatio: 343/87,
          child: Image.asset("assets/png/speck_event_title.png", fit: BoxFit.fill,),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailPage()));
        },
      )
    ];
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: uiCriteria.totalHeight * 0.0246),
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
          itemCount: eventList.length,
          itemBuilder: (BuildContext context, int index) {
            return eventList[index];
          },
        ),
      ),
    );
  }

  Widget _expiredEventList() {
    List<Widget> eventList = [];

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: uiCriteria.totalHeight * 0.0246),
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
          itemCount: eventList.length,
          itemBuilder: (BuildContext context, int index) {
            return eventList[index];
          },
        ),
      ),
    );
  }

  void _currentTap() {
    _currentTapped = true;
    setState(() {});
  }

  void _expiredTap() {
    _currentTapped = false;
    setState(() {});
  }
}
