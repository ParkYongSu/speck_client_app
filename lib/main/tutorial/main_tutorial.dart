import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/auth/select_auth_method.dart';
import 'package:speck_app/main/home/page_state.dart';
import 'package:speck_app/main/tutorial/tutorial_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';

class MainTutorial extends StatefulWidget {
  final RenderBox renderBox;

  const MainTutorial({Key key, this.renderBox}) : super(key: key);


  @override
  _MainTutorialState createState() => _MainTutorialState();
}

class _MainTutorialState extends State<MainTutorial> {
  TutorialState _ts;
  CardTime _cardTime;
  Offset _offset;
  @override
  Widget build(BuildContext context) {
    print(widget.renderBox.size.height);
    _cardTime = Provider.of<CardTime>(context, listen: false);
    _ts = Provider.of<TutorialState>(context, listen: false);
    _offset = widget.renderBox.localToGlobal(Offset.zero);
    return _mainTutorial();
  }

  Widget _mainTutorial() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: uiCriteria.appBarHeight,
        elevation: 0,
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        backwardsCompatibility: false,
        // brightness: Brightness.dark,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
        title: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: uiCriteria.horizontalPadding),
            child: GestureDetector(
              child: Icon(Icons.cancel_outlined, size: uiCriteria.screenWidth * 0.0693,),
              onTap: _pressCancel,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: AspectRatio(
            aspectRatio: 375/60,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.00666, vertical: constraint.maxHeight * 0.175),
                );
              },
            )
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: uiCriteria.screenWidth * 0.05),
        child: Container(
          width: uiCriteria.screenWidth * 0.1365,
          height: uiCriteria.screenWidth * 0.1365,
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
                width: uiCriteria.screenWidth * 0.1186,
                height: uiCriteria.screenWidth * 0.1186,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: mainColor, width: 2)
                ),
              ),
            ),
            onPressed: () async {
              _cardTime.stopTimer();
              _ts.setTutorialState(2);
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => AuthMethod()));
              // SharedPreferences sp = await SharedPreferences.getInstance();
              // sp.setBool("tutorial", true);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: <Widget>[
                Container(
                  transform: Matrix4.translationValues(0, _offset.dy - uiCriteria.statusBarHeight + widget.renderBox.size.height * 0.245, 0),
                  child: Padding(
                    padding: EdgeInsets.only(left: uiCriteria.screenWidth * 0.24, right: uiCriteria.screenWidth * 0.24),
                    child: GestureDetector(
                      onTap: _pressTop,
                      child: AspectRatio(
                          aspectRatio: 194/220,
                          child: Image.asset("assets/png/main_tutorial_top.png", fit: BoxFit.fill,))),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.2653),
              child: AspectRatio(
                  aspectRatio: 175.9/105.4,
                  child: Image.asset("assets/png/main_tutorial_bottom.png", fit: BoxFit.fill,)),
            ),
          ],
        ),
      ),
    );
  }

  void _pressCancel() async {
    _ts.setTutorialState(0);
    Navigator.pop(context);
  }

  void _pressTop() async {
    _ts.setTutorialState(1);
    print("tutorialState : ${_ts.getTutorialState()}");
    Navigator.pop(context);
  }
}
