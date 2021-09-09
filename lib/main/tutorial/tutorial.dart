import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/main/main_page.dart';
import 'package:speck_app/main/tutorial/tutorial_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';

class Tutorial extends StatefulWidget {
  final int route;

  const Tutorial({Key key, @required this.route}) : super(key: key);
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  PageController _pageController = new PageController(initialPage: 0);
  double _value;
  int _currentIndex;
  bool _arriveEnd;
  TutorialState _ts;
  bool _isStartTap;
  SharedPreferences _sp;

  @override
  void initState() {
    super.initState();
    _value = (100 / 6) / 100;
    _currentIndex = 0;
    _arriveEnd = false;
    _isStartTap = false;
  }

  @override
  Widget build(BuildContext context) {
    _ts = Provider.of<TutorialState>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: mainColor,
      body: Stack(
        children: <Widget>[
          _tutorial(),
          _progressBar(),
          (_isStartTap)
              ?Container()
              :_tutorialStart(),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: EdgeInsets.only(top: uiCriteria.totalHeight * 0.0677, left: uiCriteria.screenWidth * 0.0933, right: uiCriteria.screenWidth * 0.0933),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.9),
            child: LinearProgressIndicator(
              minHeight: uiCriteria.screenWidth * 0.0187,
              value: _value,
              backgroundColor: Color(0XFFacacac),
              color: Color(0XFFfcf3b2),
            ),
          ),
          Container(
            height: uiCriteria.screenWidth * 0.0746,
            width: uiCriteria.screenWidth * 0.0773,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: (_arriveEnd)?[BoxShadow(color: Color(0XFFfffad6).withOpacity(0.8), blurRadius: 12, spreadRadius: 0.5, offset: Offset(0,2))]:null,
              image: DecorationImage(
                image: (_arriveEnd)?AssetImage("assets/png/tutorial_end_color.png"):AssetImage("assets/png/tutorial_end_grey.png"),
                fit: BoxFit.fill
              )
            ),
          )
        ],
      ),
    );
  }
  
  Widget _tutorial() {
    List<Widget> pages = [
      _tutorial1(),
      _tutorial2(),
      _tutorial3(),
      _tutorial4(),
      _tutorial5(),
      _tutorial6(),
    ];

    return  PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: pages.length,
        itemBuilder: (BuildContext context, int index) {
          return pages[index];
        });
  }

  Widget _tutorial1() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          child: Image.asset("assets/png/tutorial_1.png", fit: BoxFit.fitHeight),
        ),
        Padding(
          padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.0933,bottom: uiCriteria.totalHeight * 0.0616),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("우주의 작은 먼지처럼", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize24, color: Colors.white),),
              SizedBox(height: uiCriteria.totalHeight * 0.0197,),
              Text("아무것도 이루지 못한 내 자신이", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),),
              SizedBox(height: uiCriteria.totalHeight * 0.0111,),
              Text("아무 존재가 아닌 것 같이 느껴질 때..", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),)
            ],
          ),
        )
      ],
    );
  }

  Widget _tutorial2() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          child: Image.asset("assets/png/tutorial_2.png", fit: BoxFit.fitHeight,),
        ),
        Padding(
          padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.0933,bottom: uiCriteria.totalHeight * 0.0616),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("작은 먼지도 결국 행성이 되듯", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize24, color: Colors.white),),
              SizedBox(height: uiCriteria.totalHeight * 0.0197,),
              Text("우주먼지가 여러공간을 이동하면서", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),),
              SizedBox(height: uiCriteria.totalHeight * 0.0111,),
              Text("서서히 몸집을 키워 행성이 되듯이", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),)
            ],
          ),
        )
      ],
    );
  }

  Widget _tutorial3() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          child: Image.asset("assets/png/tutorial_3.png", fit: BoxFit.fitHeight,),
        ),
        Padding(
          padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.0933,bottom: uiCriteria.totalHeight * 0.0616),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("우리도 우주먼지와 닮았어요", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize24, color: Colors.white),),
              SizedBox(height: uiCriteria.totalHeight * 0.0197,),
              Text("여러 집밖 학습공간을 돌아다니며 ", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),),
              SizedBox(height: uiCriteria.totalHeight * 0.0111,),
              Text("성장하는 모습이 우주먼지와 같아요", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),)
            ],
          ),
        )
      ],
    );
  }

  Widget _tutorial4() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          child: Image.asset("assets/png/tutorial_4.png", fit: BoxFit.fitHeight,),
        ),
        Padding(
          padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.0933,bottom: uiCriteria.totalHeight * 0.0616),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("자, 먼저 갤럭시를 선택해요!", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize24, color: Colors.white),),
              SizedBox(height: uiCriteria.totalHeight * 0.0197,),
              Text("갤럭시에 학습목표가 같은 먼지들끼리", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),),
              SizedBox(height: uiCriteria.totalHeight * 0.0111,),
              Text("모여 서로 출석과 자료를 공유해요", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),)
            ],
          ),
        )
      ],
    );
  }

  Widget _tutorial5() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          child: Image.asset("assets/png/tutorial_5.png", fit: BoxFit.fitHeight,),
        ),
        Padding(
          padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.0933,bottom: uiCriteria.totalHeight * 0.0616),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("다음, 탐험시간을 예약해요!", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize24, color: Colors.white),),
              SizedBox(height: uiCriteria.totalHeight * 0.0197,),
              Text("탐험시간이 같은 먼지들끼리 모여", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),),
              SizedBox(height: uiCriteria.totalHeight * 0.0111,),
              Text("각자 집 밖으로 탐험을 떠나요", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),)
            ],
          ),
        )
      ],
    );
  }

  Widget _tutorial6() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          child: Image.asset("assets/png/tutorial_6.png", fit: BoxFit.fitHeight,),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.12,bottom: uiCriteria.totalHeight * 0.0431),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("이제 집 밖을 나서볼까요?", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize24, color: Colors.white),),
                    SizedBox(height: uiCriteria.totalHeight * 0.0197,),
                    Text("집 밖을 탐험하며 얻는 먼지들로", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),),
                    SizedBox(height: uiCriteria.totalHeight * 0.0111,),
                    Text("몸을 키워 나만의 행성을 만들어봐요!", style: TextStyle(fontFamily: "NanumSquareRoundB", fontSize: uiCriteria.textSize17, color: Colors.white.withOpacity(0.75), letterSpacing: -0.17),)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: uiCriteria.horizontalPadding, right: uiCriteria.horizontalPadding, bottom: uiCriteria.totalHeight * 0.0394),
                child: AspectRatio(
                  aspectRatio: 343/46,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                    elevation: 0,
                    onPressed: _onPressedComplete,
                    color: Colors.white,
                    child: Text("우주 탐험 시작하기", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize15, fontWeight: FontWeight.bold, letterSpacing: 0.75),),
                  ),
                ),
              ),
            ],
          )
        ),
      ],
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndex < index) {
      _value += (100 / 6) / 100;
    }
    else {
      _value -= (100 / 6) / 100;
    }

    if (index == 5) {
      _arriveEnd = true;
    }
    else {
      _arriveEnd = false;
    }

    _currentIndex = index;
    setState(() {});
  }

  void _onPressedComplete() async {
    _sp = await SharedPreferences.getInstance();
    _ts.setTutorialState(-1);
    if (widget.route == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmailLoginPage()), (route) => false);
    }
    else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainNavigation()), (route) => false);
    }
    await _sp.setBool("tutorialStory4", true);
  }

  Widget _tutorialStart() {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails ded) {
        _startTap();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8)
        ),
        child: Column(
          children: <Widget>[
            Spacer(flex: 3172,),
            Image.asset("assets/png/tutorial_start.png"),
            Spacer(flex: 2680,)
          ],
        ),
      ),
    );
  }

  void _startTap() {
    _isStartTap = true;
    setState(() {});
  }
}
