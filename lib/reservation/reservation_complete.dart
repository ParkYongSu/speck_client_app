import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/main.dart';
import 'package:speck_app/main/main_page.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';

class ReservationComplete extends StatelessWidget {
  final String schoolName; // 학교이름
  final String imagePath;
  final String time;
  final int type;
  final String canAuthTime;
  final int cnt;
  final DateTime startDate;
  final DateTime endDate;
  final String oneDayAmount;
  final String pay;
  final String account;
  final int payType;

  ReservationComplete({Key key,
    @required this.schoolName,
    @required this.imagePath,
    @required this.time,
    @required this.type,
    @required this.canAuthTime,
    @required this.cnt,
    @required this.startDate,
    @required this.endDate,
    @required this.oneDayAmount,
    @required this.pay, this.account,
    @required this.payType
  }) : super(key: key);

  final UICriteria _uiCriteria = new UICriteria();
  @override
  Widget build(BuildContext context) {
    print(startDate);
    print(endDate);
    _uiCriteria.init(context);
    return _reservationCompletePage(context);
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: mainColor,
      centerTitle: true,
      titleSpacing: 0,
      toolbarHeight: _uiCriteria.appBarHeight,
      backwardsCompatibility: false,
      // brightness: Brightness.dark,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
      title: Container(
          alignment: Alignment.center,
          width: _uiCriteria.screenWidth,
          child: Text("출석 예약 완료", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize16),)),
    );
  }

  Widget _reservationCompletePage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _borderLine(),
                  _reservationResult(),
                  _borderLine(),
                  _reservationInfo(),
                  _borderLine(),
                  _paymentInfo(),
                  _subWidget()
                ],
              ),
            ),
          ),
          _completeButton(context)
        ],
      ),
    );
  }

  Widget _reservationResult() {
    return AspectRatio(
      aspectRatio: 375/246,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
            ),
            padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding, right: _uiCriteria.horizontalPadding),
            child: Column(
              children: <Widget>[
                Spacer(flex: 24,),
                _checkMark(),
                Spacer(flex: 23,),
                _resultText(),
                Spacer(flex: 12,),
                _notice(),
                Spacer(flex: 24,),
                _selectButton(context, constraint),
                Spacer(flex: 12,),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _borderLine() {
    return AspectRatio(
      aspectRatio: 375/11.8,
      child: Container(
        decoration: BoxDecoration(
          color: greyF0F0F1
        ),
      ),
    );
  }

  Widget _checkMark() {
    return Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.screenWidth * 0.1493, );
  }

  Widget _resultText() {
    return Text("총 $cnt일 기간의 출석이 예약되었어요.", style: TextStyle(color: mainColor, letterSpacing: 0.9, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize4));
  }

  Widget _notice() {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text("- 예약 취소는 일정 시작 전날 자정까지만 가능한 점 유의 부탁드립니다.", style: TextStyle(fontSize: _uiCriteria.textSize5, letterSpacing: 0.5, fontWeight: FontWeight.w500, color: greyAAAAAA),));
  }

  Widget _selectButton(BuildContext context, BoxConstraints constraint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: constraint.maxWidth * 0.44,
          height: constraint.maxHeight * 0.2032,
          child: MaterialButton(
            elevation: 0,
            onPressed: () => inviteFriends(),
            child: Text("친구랑 같이하기", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.5)
            ),
            color: mainColor,

          ),
        ),
        Container(
          width: constraint.maxWidth * 0.44,
          height: constraint.maxHeight * 0.2032,
          child: MaterialButton(
              elevation: 0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
              },
              child: Text("다른 갤럭시 보기", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.5)
              ),
              color: greyD8D8D8,
            ),
        ),
      ],
    );
  }

  Widget _reservationInfo() {
    return AspectRatio(
      aspectRatio: 375/215,
      child: Column(
        children: <Widget>[
          _galaxyName(),
          _galaxyInfo(),
          _authTime()
        ],
      ),
    );
  }

  Widget _galaxyName() {
    return AspectRatio(
      aspectRatio: 375/39.8,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Text("공식 갤럭시", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
      ),
    );
  }

  Widget _galaxyInfo() {
    String start = "${startDate.toString().substring(0,4)}.${startDate.toString().substring(5,7)}.${startDate.toString().substring(8,10)}";
    String end = "${endDate.toString().substring(0,4)}.${endDate.toString().substring(5,7)}.${endDate.toString().substring(8,10)}";
    DateTime current = DateTime.now();
    int dDay = DateTime(startDate.year,startDate.month,startDate.day, 0, 0, 0, 0)
        .difference(DateTime(current.year, current.month, current.day, 0, 0, 0, 0)).inDays;

    return AspectRatio(
      aspectRatio: 3750/1208,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
            child: Column(
              children: [
                Spacer(flex: 1,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: constraint.maxWidth * 0.2106,
                      height: constraint.maxWidth * 0.2106,
                      decoration: BoxDecoration(
                        border: Border.all(color: greyD8D8D8, width: 0.5),
                        borderRadius: BorderRadius.circular(6.9),
                        image: DecorationImage(
                          image: NetworkImage(imagePath),
                          fit: BoxFit.fitHeight,
                        )
                      ),
                    ),
                    SizedBox(width: constraint.maxWidth * 0.0426,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.5),
                                color: Color(0XFFe7535c)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0226, vertical: constraint.maxHeight *0.0413 ),
                              child: Text("D-$dDay", style: TextStyle(color: Colors.white, letterSpacing: 0.5, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),),
                            ),
                            SizedBox(width: constraint.maxWidth * 0.016,),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.5),
                                  color: greyF5F5F6
                              ),
                              padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0226, vertical: constraint.maxHeight *0.0413 ),
                              child: Text("출석횟수 0회", style: TextStyle(color: greyB3B3BC, letterSpacing: 0.5, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),),
                            )
                          ],
                        ),
                        SizedBox(height: constraint.maxHeight * 0.0579,),
                        Text((type == 1)?"[공식] $schoolName($time)":"$schoolName($time)", style: TextStyle(color: mainColor, letterSpacing: 0.24,fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),),
                        SizedBox(height: constraint.maxHeight * 0.0579,),
                        Row(
                          children: <Widget>[
                            Text("예약 기간 ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.2),),
                            Text("$start ~ $end (총 $cnt일)", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize5, letterSpacing: 0.2),),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                Spacer(flex: 1,),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _authTime() {
    return AspectRatio(
      aspectRatio: 375/42,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: greyF5F5F6
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7, color: mainColor),
            children: <TextSpan>[
              TextSpan(text: "인증 가능한 시간은 "),
              TextSpan(text: canAuthTime, style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: " 입니다.")
            ]
          ),
        ),
      ),
    );
  }

  Widget _paymentInfo() {
    return Column(
      children: <Widget>[
        _paymentTitle(),
        _paymentContent(),
        _totalAmount()
      ],
    );
  }

  Widget _paymentTitle() {
    return AspectRatio(
      aspectRatio: 375/39.8,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Text("결제 정보", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
      ),
    );
  }

  Widget _paymentContent() {
    String startWeekday = _getWeekdayName(startDate.weekday);
    String endWeekday = _getWeekdayName(endDate.weekday);
    String startMonth = startDate.month.toString();
    String startDay = startDate.day.toString();
    String endMonth = endDate.month.toString();
    String endDay = endDate.day.toString();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.verticalPadding),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("예약 기간", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
              Row(
                children: <Widget>[
                  Text("$startMonth월 $startDay일($startWeekday) ~ $endMonth월 $endDay일($endWeekday)",
                    style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3),),
                  Text(" 총 $cnt일", style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)
                ],
              )
            ],
          ),
          SizedBox(height: _uiCriteria.totalHeight * 0.0123,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("하루 보증금", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
              Text(" ${oneDayAmount.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)
            ],
          ),
          SizedBox(height: _uiCriteria.totalHeight * 0.0123,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("결제 수단", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
              Text(pay,style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: _uiCriteria.textSize3, letterSpacing: 0.5),),
            ],
          ),
          (payType == 3)
              ? Align(
            alignment: Alignment.centerRight,
            child: Column(
              children: [
                SizedBox(height: _uiCriteria.totalHeight * 0.0073),
                Text(account, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
              ],
            ),
          )
              : Container(),
        ],
      ),
    );
  }

  Widget _totalAmount() {
    int oneDay = int.parse(oneDayAmount);
    String totalPayment = (oneDay * cnt).toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return AspectRatio(
      aspectRatio: 375/36.8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("총 결제금액", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
            Text("$totalPayment원",  style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)
          ],
        ),
      ),
    );
  }

  // 밑에 받침
  Widget _subWidget() {
    return AspectRatio(
      aspectRatio: 375/104,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return "월";
      case 2:
        return "화";
      case 3:
        return "수";
      case 4:
        return "목";
      case 5:
        return "금";
      case 6:
        return "토";
      case 7:
        return "일";
    }
    return "";
  }

  Widget _completeButton(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375/92,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, spreadRadius: 0, offset: Offset(0, -8))]
        ),
        child: Column(
          children: <Widget>[
            Spacer(flex: 10,),
            AspectRatio(
              aspectRatio: 343/50,
              child: MaterialButton(
                elevation: 0,
                onPressed: () => _onPressed(context),
                color: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.5)
                ),
                child: Text("확인", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
              ),
            ),
            Spacer(flex: 32,),
          ],
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
  }
}
