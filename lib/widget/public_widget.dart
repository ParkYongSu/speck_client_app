import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';


UICriteria uiCriteria = new UICriteria();

void uiInit(BuildContext context) {
  uiCriteria.init(context);
}

Widget greyBar() {
  return AspectRatio(
    aspectRatio: 375/11.8,
    child: Container(
      decoration: BoxDecoration(
        color: greyF0F0F1
      ),
    ),
  );
}


Widget title(BuildContext context, String title) {
  uiInit(context);
  return AspectRatio(
    aspectRatio: 375/39.8,
    child: Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
      ),
      child: Text(title, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
    ),
  );
}

Widget reservedGalaxyInfo(BuildContext context, DateTime startDate, DateTime endDate, String schoolName, int type, int cnt, int attCount, int timeNum, String imagePath) {
  uiInit(context);

  String start = "${startDate.toString().substring(0,4)}.${startDate.toString().substring(5,7)}.${startDate.toString().substring(8,10)}";
  String end = "${endDate.toString().substring(0,4)}.${endDate.toString().substring(5,7)}.${endDate.toString().substring(8,10)}";
  DateTime current = DateTime.now();
  String status;
  Color statusColor;
  if (type != -1) { /// 입금대기 상태가 아니
    if (current.isAfter(startDate) && current.isBefore(endDate)) {
      status = "진행중";
      statusColor = Color(0XFF404040);
    }
    else if (current.isAfter(DateTime.parse(endDate.toString().substring(0, 10)  + " " + getAuthTime(timeNum)))) {
      status = "완료됨";
      statusColor = greyD8D8D8;
    }
    else {
      int dDay = DateTime(startDate.year,startDate.month,startDate.day, 0, 0, 0, 0)
          .difference(DateTime(current.year, current.month, current.day, 0, 0, 0, 0)).inDays;
      if (dDay == 0) {
        status = "진행중";
        statusColor = Color(0XFF404040);
      }
      else {
        status = "D-"+ dDay.toString();
        statusColor = Color(0XFFE7535C);
      }
    }
  }
  else {
    status = "입금대기";
    statusColor = mainColor;
  }
  return AspectRatio(
    aspectRatio: 3750/1208,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
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
                          // image: NetworkImage(imagePath)
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
                                color: statusColor
                            ),
                            padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0226, vertical: constraint.maxHeight *0.0413 ),
                            child: Text(status, style: TextStyle(color: Colors.white, letterSpacing: 0.5, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5),),
                          ),
                          SizedBox(width: constraint.maxWidth * 0.016,),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.5),
                                color: greyF5F5F6
                            ),
                            padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0226, vertical: constraint.maxHeight *0.0413 ),
                            child: Text("출석횟수 $attCount회", style: TextStyle(color: greyB3B3BC, letterSpacing: 0.5, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5),),
                          )
                        ],
                      ),
                      SizedBox(height: constraint.maxHeight * 0.0579,),
                      Text((type == 1)?"[공식] $schoolName":"$schoolName", style: TextStyle(color: mainColor, letterSpacing: 0.24,fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w700),),
                      SizedBox(height: constraint.maxHeight * 0.0579,),
                      Row(
                        children: <Widget>[
                          Text("예약 기간 ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize5, letterSpacing: 0.2),),
                          Text("$start ~ $end (총 $cnt일)", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize5, letterSpacing: 0.2),),
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

Widget authTime(BuildContext context, String canAuthTime) {
  uiInit(context);
  return AspectRatio(
    aspectRatio: 375/42,
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: greyF5F5F6
      ),
      child: RichText(
        text: TextSpan(
            style: TextStyle(fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w500, letterSpacing: 0.7, color: mainColor),
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

Widget rule(BuildContext context) {
  uiInit(context);

  return AspectRatio(
    aspectRatio: 375/269,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
        return Container(
            decoration: BoxDecoration(
                color: greyF5F5F6,
                border: Border(
                    bottom: BorderSide(
                        color: greyD8D8D8.withOpacity(0.5), width: 0.5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 23,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.096),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/png/dust_won_fill.png",
                          height: uiCriteria.textSize1,
                        ),
                        Text(
                          "상금 계산은 하루를 기준으로 이루어져요!",
                          style: TextStyle(
                              letterSpacing: 0.7,
                              color: mainColor,
                              fontSize: uiCriteria.textSize2,
                              fontWeight: FontWeight.bold),
                        ),
                        Image.asset(
                          "assets/png/dust_won_fill.png",
                          height: uiCriteria.textSize1,
                        ),
                      ]),
                ),
                Spacer(flex: 36,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Spacer(flex: 576,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Image.asset("assets/png/arrow_up_draw.png", width: constraint.maxWidth * 0.0661, height: constraint.maxHeight * 0.1379, fit: BoxFit.fill,),
                        SizedBox(width: constraint.maxWidth * 0.0061,),
                        Image.asset("assets/png/arrow_up_draw.png", width: constraint.maxWidth * 0.0461, height: constraint.maxHeight * 0.0966, fit: BoxFit.fill,),
                      ],
                    ),
                    Spacer(flex: 269,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0405, vertical: constraint.maxHeight * 0.0542),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: Row(
                        children: <Widget>[
                          Image.asset("assets/png/dust_won_fill.png", width: constraint.maxWidth * 0.0938, height: constraint.maxWidth * 0.0938, fit: BoxFit.fill,),
                          SizedBox(width: constraint.maxWidth * 0.0293),
                          Image.asset("assets/png/circuit_draw.png", width: constraint.maxWidth * 0.0698, height: constraint.maxWidth * 0.0698, fit: BoxFit.fill,),
                          SizedBox(width: constraint.maxWidth * 0.0293),
                          Image.asset("assets/png/dust_money.png", width: constraint.maxWidth * 0.0938, height: constraint.maxWidth * 0.0938, fit: BoxFit.fill,)
                        ],
                      ),
                    ),
                    Spacer(flex: 269,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Image.asset("assets/png/arrow_up_draw.png", color: Color(0XFFFCCF97), width: constraint.maxWidth * 0.0461, height: constraint.maxHeight * 0.0966, fit: BoxFit.fill),
                        SizedBox(width: constraint.maxWidth * 0.0061,),
                        Image.asset("assets/png/arrow_up_draw.png", color: Color(0XFFFCCF97), width: constraint.maxWidth * 0.0661, height: constraint.maxHeight * 0.1379, fit: BoxFit.fill,),
                      ],
                    ),
                    Spacer(flex: 576,),
                  ],
                ),
                Spacer(flex: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("상금을 보증금 비율에 맞게 분배하기 때문에,",
                      style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: uiCriteria.textSize5,),),
                    Text(" 보증금이 클수록 상금도 커져요!",
                      style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: uiCriteria.textSize5,
                          decoration: TextDecoration.lineThrough, decorationColor: Color(0XFFfcf3b2).withOpacity(0.3), decorationStyle: TextDecorationStyle.solid, decorationThickness: uiCriteria.textSize3),),

                  ],
                ),
                Spacer(flex: 23,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("출석 성공",style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3)),
                          SizedBox(width: constraint.maxWidth * 0.032,),
                          Text("보증금 페이백 + 상금",style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: uiCriteria.textSize3))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text("출석 성공" ,style: TextStyle(color: Colors.transparent, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3),),
                          SizedBox(width: constraint.maxWidth * 0.032,),
                          Text("보증금은 일정 마지막 날 한 번에 지급되고, 상금은 매일 지급돼요.",
                            style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: uiCriteria.textSize5),),
                        ],
                      )
                    ],
                  ),
                ),
                Spacer(flex: 11,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("출석 실패",style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, letterSpacing: 0.6, fontSize: uiCriteria.textSize3)),
                      SizedBox(width: constraint.maxWidth * 0.032,),
                      Text("출석을 실패한 날의 보증금은 상금으로 들어가요.",style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: uiCriteria.textSize3))
                    ],
                  ),
                ),
                Spacer(flex: 23,),
              ],
            ));
      },
    ),
  );
}

Widget paymentTitle(BuildContext context) {
  uiInit(context);

  return AspectRatio(
    aspectRatio: 375/39.8,
    child: Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
      ),
      child: Text("결제 정보", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
    ),
  );
}

Widget paymentContent(BuildContext context, DateTime startDate, DateTime endDate, int oneDayAmount, int cnt, int paymentId) {
  uiInit(context);
  String startWeekday = getWeekdayName(startDate.weekday);
  String endWeekday = getWeekdayName(endDate.weekday);
  String startMonth = startDate.month.toString();
  String startDay = startDate.day.toString();
  String endMonth = endDate.month.toString();
  String endDay = endDate.day.toString();

  return Container(
    padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding, vertical: uiCriteria.verticalPadding),
    decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
    ),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("예약 기간", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
            Row(
              children: <Widget>[
                Text("$startMonth월 $startDay일($startWeekday) ~ $endMonth월 $endDay일($endWeekday)",
                  style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w500, fontSize: uiCriteria.textSize3),),
                Text(" 총 $cnt일", style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3),)
              ],
            )
          ],
        ),
        SizedBox(height: uiCriteria.totalHeight * 0.0123,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("하루 보증금", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
            Text(" ${oneDayAmount.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
              style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3),)
          ],
        ),
        SizedBox(height: uiCriteria.totalHeight * 0.0123,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("결제 수단", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
            Text((paymentId == 3)?"계좌이체":"스펙 캐시", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: uiCriteria.textSize3, letterSpacing: 0.5),)

          ],
        ),
        (paymentId == 3)
            ? Align(
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              SizedBox(height: uiCriteria.totalHeight * 0.0073),
              Text("하나 748-911346-03807 노지훈(파이다고고스)", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: uiCriteria.textSize5, letterSpacing: 0.5),),
            ],
          ),
        )
            : Container(),
      ],
    ),
  );
}

Widget totalAmount(BuildContext context, int totalPaid) {
  uiInit(context);

  return AspectRatio(
    aspectRatio: 375/36.8,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("총 결제금액", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
          Text("${totalPaid.toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",  style: TextStyle(color: mainColor, letterSpacing: 0.6, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize3),)
        ],
      ),
    ),
  );
}

String getWeekdayName(int weekday) {
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

Widget appBar(BuildContext context, String title) {
  uiInit(context);
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    backgroundColor: mainColor,
    centerTitle: true,
    titleSpacing: 0,
    toolbarHeight: uiCriteria.appBarHeight,
    backwardsCompatibility: false,
    // brightness: Brightness.dark,
    systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
    title: Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            width: uiCriteria.screenWidth,
            child: Text(title, style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize1),)),
        GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Icon(Icons.chevron_left_rounded,
                  color: Colors.white, size: uiCriteria.screenWidth * 0.1),
            ),
            onTap: () {
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

Widget loader(BuildContext context, int index) {
  uiInit(context);
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: (index == 0)?Colors.white:mainColor,
    ),
    width: uiCriteria.screenWidth,
    height: uiCriteria.totalHeight,
    child: Container(
      width: uiCriteria.screenWidth * 0.0666,
      height: uiCriteria.screenWidth * 0.0666,
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>((index == 0)?mainColor:Colors.white)
      ),
    ),
  );
}

Widget loaderDialog() {
  AlertDialog dialog = new AlertDialog(
    insetPadding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.152),
    contentPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
    ),
    content: AspectRatio(
        aspectRatio: 260/135,
        child: Column(
          children: [
            Expanded(
                flex: 30,
                child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.transparent
                      ),
                      width: uiCriteria.screenWidth,
                      height: uiCriteria.totalHeight,
                      child: Container(
                        alignment: Alignment.center,
                        width: uiCriteria.screenWidth * 0.0666,
                        height: uiCriteria.screenWidth * 0.0666,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(mainColor)
                        ),
                      ),
                    ))),
            Expanded(
                flex: 13,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                    ),
                    alignment: Alignment.center,
                    child: Text("잠시만 기다려주세요", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: uiCriteria.textSize2, letterSpacing: 0.6),))),
          ],
        )
    ),
  );

  return dialog;
}

List<Widget> generateHashTags(BuildContext context, List<dynamic> hts, int index) {
  uiInit(context);
  List<Widget> hashTags = <Widget>[];
  if (hts.isNotEmpty) {
    for (int j = 0; j < hts.length; j++) {
      String text = hts[j]["hashTag"];
      hashTags.add(
          Container(
              margin: (index == 0)?EdgeInsets.zero:EdgeInsets.only(right:uiCriteria.screenWidth * 0.016),
              padding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.016, vertical: uiCriteria.screenWidth * 0.0106),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.5),
                  color: greyF5F5F6
              ),
              child: Text("#$text", maxLines: 1, style: TextStyle(letterSpacing: 0.5, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500, color: greyB3B3BC),)
          )
      );

    }
  }
  return hashTags;
}

void errorToast(String title) {
  Fluttertoast.showToast(msg: title, gravity: ToastGravity.CENTER, fontSize: uiCriteria.textSize2);
}
