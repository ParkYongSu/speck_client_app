import 'package:flutter/material.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({Key key}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    return _eventDetailPage();
  }

  Widget _eventDetailPage() {
    return Scaffold(
      appBar: appBar(context, "이벤트"),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: <Widget>[
              _title(),
              _eventDetail()
            ],
          ),
          _joinButton()
        ],
      ),
    );
  }

  Widget _title() {
    return AspectRatio(
      aspectRatio: 375/86,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(flex: 28,),
            Text("스펙 리뉴얼 이벤트!", style: TextStyle(fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize21, letterSpacing: 1.05, color: mainColor),),
            Spacer(flex: 8,),
            Text("*기한 : 상품 소진시까지 선착순 마감", style: TextStyle(fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize11, letterSpacing: 0.55, color: mainColor),),
            Spacer(flex: 15,)
          ],
        ),
      ),
    );
  }

  Widget _eventDetail() {
    List<Widget> details = [
      _detail("assets/png/speck_event_1.png"),
      _detail("assets/png/speck_event_2.png"),
      _detail("assets/png/speck_event_3.png"),
      _detail("assets/png/speck_event_4.png"),
      _detail("assets/png/speck_event_5.png"),
      _detail("assets/png/speck_event_6.png"),
      _detail("assets/png/speck_event_7.png"),
      _detail("assets/png/speck_event_8.png"),
    ];
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return details[index];
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.white,
                    height: uiCriteria.verticalPadding,
                  );
                },
                itemCount: details.length),
          ),
          AspectRatio(aspectRatio: 375/92)
        ],
      )
    );
  }

  Widget _detail(String path) {
    return AspectRatio(
      aspectRatio: 1/1,
      child: Image.asset(path, fit: BoxFit.fill,),
    );
  }
  
  Widget _joinButton() {
    return AspectRatio(
      aspectRatio: 375/92,
      child: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Colors.white
        ),
        padding: EdgeInsets.only(left: uiCriteria.horizontalPadding, right: uiCriteria.horizontalPadding, top: uiCriteria.totalHeight * 0.0185),
        child: AspectRatio(
          aspectRatio: 343/50,
          child: MaterialButton(
            color: mainColor,
            onPressed: _joinTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            elevation: 0,
            child: Text("이벤트 참여하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize2, letterSpacing: 0.7),),
          ),
        ),
      ),
    );
  }
  
  void _joinTap() {
    launch("http://pf.kakao.com/_IxoAjs");
  }
}
