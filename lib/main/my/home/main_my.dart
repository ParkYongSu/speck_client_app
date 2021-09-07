import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Main/my/benefit/benefit_info.dart';
import 'package:speck_app/Main/my/my_background.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/Main/my/history/my_history.dart';
import 'package:speck_app/Main/my/setting/setting_all_info.dart';
import 'package:speck_app/Main/my/speckcash/cash_info.dart';
import 'package:speck_app/main/my/history/history_info.dart';
import 'package:speck_app/main/my/home/mypage_event.dart';
import 'package:speck_app/main/my/ticket/ticket_info.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMyPage extends StatefulWidget {
  @override
  _MainMyPageState createState() => _MainMyPageState();
}

class _MainMyPageState extends State<MainMyPage> with TickerProviderStateMixin{
  UICriteria _uiCriteria = new UICriteria();
  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    /// 일단 ui 구현한 후 서버 통신 이루어지면 FutureBuilder에 삽입
    return FutureBuilder(
      future: _getMyData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _setData(snapshot.data);
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 375/139,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraint) {
                        return Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Stack(
                                alignment: Alignment.topCenter,
                                children: <Widget>[
                                  CustomPaint(
                                    size: MediaQuery.of(context).size,
                                    painter: MyBackground(),
                                  ),
                                  Image.asset("assets/png/my_background.png",fit: BoxFit.fill,)
                                ]
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Transform.rotate(
                                  angle: -0.35,
                                  child: Container(
                                    margin: EdgeInsets.only(right: constraint.maxWidth * 0.1533, bottom: constraint.maxHeight * 0.4),
                                    height: constraint.maxHeight * 0.4820,
                                    width:constraint.maxHeight * 0.5036,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(getCharacter(_character)),
                                        fit: BoxFit.fill
                                      ),
                                      boxShadow: [BoxShadow(color: shadowColor(_character), blurRadius: 26, spreadRadius: 0, offset: Offset(-4, 0))]
                                    ),
                                  ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.only(left: _uiCriteria.horizontalPadding),
                              height: constraint.maxWidth * 0.192,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(_uiCriteria.screenWidth * 0.008),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle
                                    ),
                                    child: Container(
                                      width: constraint.maxWidth * 0.192,
                                      height: constraint.maxWidth * 0.192,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 26, spreadRadius: 0, offset: Offset(-4, 0))],
                                          image: DecorationImage(
                                            image: (_profile == "N")?AssetImage(getCharacter(_character)):NetworkImage(_profile),
                                            fit: BoxFit.fill
                                          )
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: constraint.maxWidth * 0.032,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            (_bookInfoList.isEmpty)
                                            ? Text("갤럭시에 가입해주세요", style: TextStyle(letterSpacing: 0.7,color: Colors.white, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500))
                                            :  Text("$_galaxyName의", style: TextStyle(letterSpacing: 0.7,color: Colors.white, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500)),
                                            SizedBox(
                                              height: constraint.maxHeight * 0.04317,
                                            ),
                                            Text(_nickname, style: TextStyle(letterSpacing: 1.12, color: Colors.white, fontSize: _uiCriteria.textSize16, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileInfo())),
                                        child: Row(
                                          children: <Widget>[
                                            Text("프로필 편집  ", style: TextStyle(letterSpacing: 0.7, color: greyAAAAAA, fontSize: _uiCriteria.textSize5),),
                                            Icon(Icons.arrow_forward_ios_rounded, color: greyB3B3BC, size: _uiCriteria.textSize5,)
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  AspectRatio(
                      aspectRatio: 375/143.8,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraint) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, constraint.maxHeight * 0.1292, _uiCriteria.horizontalPadding, constraint.maxHeight * 0.1537),
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                            ),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.9),
                                    color: Colors.white,
                                    boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))]
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.032),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Image.asset("assets/png/dust_cash.png", height:  _uiCriteria.screenWidth * 0.0346,),
                                                  SizedBox(width: constraint.maxWidth * 0.0213),
                                                  Text("스펙 캐시", style: TextStyle(fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3),)
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text("${_myCash.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원  ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3,),),
                                                  Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize3, color: greyB3B3BC,)
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () => _navigateSpeckCash(context, _myCash),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.032),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Image.asset("assets/png/dust_won.png", height:  _uiCriteria.screenWidth * 0.0346,),
                                                  SizedBox(width: constraint.maxWidth * 0.0213),
                                                  Text("나의 상금", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3),)
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text("${_myPoint.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원  ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3,),),
                                                  Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize3, color: greyB3B3BC,)
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BenefitInfo(benefit: _myPoint))),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: _uiCriteria.screenWidth,
                                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.032),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Image.asset("assets/png/dust_percent.png", height: _uiCriteria.screenWidth * 0.0346,),
                                                SizedBox(width: constraint.maxWidth * 0.0213),
                                                Text("출석률", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3),)
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text("$_attRate% ", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                                                Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize3, color: Colors.transparent,)
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          );
                        },
                      )
                  ),
                  AspectRatio(
                      aspectRatio: 375/11.8,
                      child: Container(
                          decoration: BoxDecoration(
                              color: greyF0F0F1
                          )
                      )
                  ),
                  AspectRatio(
                    aspectRatio: 375/49,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraint) {
                        return TabBar(
                            onTap: (int index) {
                              setState(() {
                                _tabIndex = index;
                              });
                            },
                            controller: _controller,
                            indicatorColor: mainColor,
                            tabs: <Widget>[
                              Container(
                                  padding: EdgeInsets.only(top: constraint.maxHeight * 0.2245),
                                  child: Text("${_bookInfoList.isEmpty?"예약":"예약(${_bookInfoList.length})"}", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),)),
                              Container(
                                  padding: EdgeInsets.only(top: constraint.maxHeight * 0.2245),
                                  child: Text("${(_authInfoList.isEmpty)?"인증":"인증($_authCount)"}", style: TextStyle(letterSpacing: 0.6,color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),))
                            ]);
                      },
                    ),
                  ),
                  (_tabIndex == 0)
                      ?Container(
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                    ),
                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0295),
                    child: Column(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0283),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.9),
                                color: Colors.white,
                                boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))]
                            ),
                            child: _getCalendar(context, _bookInfoList)
                        ),
                        ValueListenableBuilder<List<Event>>(
                            valueListenable: _selectedEvents = new ValueNotifier(_getEventsForDay(_selectedDay, _bookInfoList, _tabIndex)),
                            builder: (context, value, _) {
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: value.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryInfo(bookInfo: value[index].bookInfo))),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0147),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6.9),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), spreadRadius: 0, blurRadius: 6, offset: Offset(0, 3))]
                                      ),
                                      child: AspectRatio(
                                          aspectRatio: 343/61,
                                          child: LayoutBuilder(
                                            builder: (BuildContext context, BoxConstraints constraint) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0349),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Spacer(),
                                                    Text("${value[index].dateTime.month}월 ${value[index].dateTime.day}일 인증예정", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.4),),
                                                    Spacer(),
                                                    Text("${(value[index].official == 1)?"[공식] ":""}${value[index].galaxyName} - ${value[index].time} 탐험단", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),),
                                                    Spacer(),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                      ),
                                    ),
                                  );
                                },
                              );
                            })
                      ],
                    ),
                  )
                      :Container(
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                    ),
                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: _uiCriteria.totalHeight * 0.0295),
                    child: Column(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0283),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.9),
                                color: Colors.white,
                                boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))]
                            ),
                            child: _getCalendar(context, _authInfoList)
                        ),
                        ValueListenableBuilder<List<Event>>(
                            valueListenable: _selectedEvents = new ValueNotifier(_getEventsForDay(_selectedDay, _authInfoList, _tabIndex)),
                            builder: (context, value, _) {
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: value.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0147),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(3.5),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), spreadRadius: 0, blurRadius: 6, offset: Offset(0, 3))]
                                      ),
                                      child: AspectRatio(
                                          aspectRatio: 343/61,
                                          child: LayoutBuilder(
                                            builder: (BuildContext context, BoxConstraints constraint) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0349),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Spacer(),
                                                    Text("${value[index].dateTime.month}월 ${value[index].dateTime.day}일 ${(value[index].attendValue == 1)?"인증성공":"인증실패"}", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.4),),
                                                    Spacer(),
                                                    Row(
                                                      children: [
                                                        Text("${(value[index].official == 1)?"[공식] ":""}${value[index].galaxyName} - ${value[index].time} 탐험단 ", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: _uiCriteria.textSize3),),
                                                        (value[index].attendValue == 1)
                                                        ? Icon(Icons.check_circle, color: mainColor, size: _uiCriteria.textSize16,)
                                                        : Icon(Icons.cancel, color: greyD8D8D8, size: _uiCriteria.textSize16,)
                                                      ],
                                                    ),
                                                    Spacer(),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                      ),
                                    ),
                                    onTap: (value[index].attendValue == 1)
                                        ? () => _navigateTicketInfo(
                                        value[index].placeName,
                                        value[index].attendCount,
                                        value[index].totalCount,
                                        value[index].attRate,
                                        value[index].totalDeposit,
                                        value[index].myDeposit,
                                        value[index].totalDust,
                                        value[index].accumPrize,
                                        value[index].estimatePrize,
                                        value[index].attendTime,
                                        value[index].timeNum,
                                        value[index].galaxyName,
                                        value[index].mannerTime
                                    )
                                        : null,
                                  );
                                },
                              );
                            })

                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 375/11.8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: greyF0F0F1
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: AspectRatio(
                      aspectRatio: 375/39.8,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset("assets/png/my_galaxy.png",height: _uiCriteria.screenWidth * 0.0301,),
                                SizedBox(width: _uiCriteria.screenWidth * 0.026),
                                Text("나의 갤럭시 전체보기", style: TextStyle(letterSpacing: 0.28, color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2),)
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHistory()));
                    },
                  ),
                  GestureDetector(
                    child: AspectRatio(
                      aspectRatio: 375/39.8,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset("assets/png/add_friends2.png", height: _uiCriteria.screenWidth * 0.0333,),
                                SizedBox(width: _uiCriteria.screenWidth * 0.029),
                                Text("친구 초대하기", style: TextStyle(letterSpacing: 0.28, color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2),)
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      inviteFriends();
                    },
                  ),
                  GestureDetector(
                    child: AspectRatio(
                      aspectRatio: 375/39.8,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset("assets/png/my_notice.png", height: _uiCriteria.screenWidth * 0.0333,),
                                SizedBox(width: _uiCriteria.screenWidth * 0.02930,),
                                Text("공지사항", style: TextStyle(letterSpacing: 0.28, color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2),)
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                          ],
                        ),
                      ),
                    ),
                    onTap: () => _connectNotion("https://www.notion.so/2b420bf39421428a8f95be498ddad1af"),
                  ),
                  GestureDetector(
                    child: AspectRatio(
                      aspectRatio: 375/39.8,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset("assets/png/my_customer.png", height: _uiCriteria.screenWidth * 0.0333,),
                                SizedBox(width: _uiCriteria.screenWidth * 0.02930,),
                                Text("자주 묻는 질문", style: TextStyle(letterSpacing: 0.28, color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2),)
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: _uiCriteria.textSize2, color: greyB3B3BC,)
                          ],
                        ),
                      ),
                    ),
                    onTap: () => _connectNotion("https://www.notion.so/c5f48c902c374c22b45d6e73c4418266"),
                  ),
                ],
              ),
            ),
          );
        }
        else {
          return Container(
            width: _uiCriteria.screenWidth,
            height: _uiCriteria.totalHeight,
            alignment: Alignment.center,
            child: Container(
                width: _uiCriteria.screenWidth * 0.065,
                height: _uiCriteria.screenWidth * 0.065,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                )
            ),
          );
        }
      },
    );
  }

  dynamic _getMyData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _profile = sp.getString("profile");
    String userEmail = sp.getString("email");
    _character = sp.getInt("characterIndex");
    _nickname = sp.getString("nickname");
    Uri url = Uri.parse("$speckUrl/mypage/");
    String body = """ {
      "userEmail":"$userEmail"
    } """;
    print(body);
    Map<String, String> header = {
      "Content-Type":"application/json"
    };

    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print(result);
    return result;
  }

  void _setData(dynamic result) {
    _myPoint = result["myPoint"].toString();
    _myCash = result["myCash"].toString();
    _planetLevel = result["planetLevel"].toString();
    _attRate = result["attRate"];
    _bookInfoList = result["bookCalendar"];
    _authInfoList = result["authCalendar"];
    _galaxyName = result["galaxyName"];
    int authCount = 0;
    for (int i = 0; i < _authInfoList.length; i++) {
      if (_authInfoList[i]["calendar"]["attendvalue"] == 1) {
        authCount++;
      }
    }
    _authCount = authCount;
  }

  List<Event> _getEventsForDay(DateTime day, List<dynamic> infoList, int index) {
    return getEvents(infoList, index)[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, List<dynamic> infoList, int index) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStartDay = null;
        _rangeEndDay = null;
      });
    }
    _selectedEvents.value = _getEventsForDay(selectedDay, infoList, index);
  }

  int _weekday;
  String _myPoint;
  String _myCash;
  String _planetLevel;
  int _attRate;
  String _attImage;
  String _nickname = "";
  // String _nickname;


  DateTime _firstDay;
  DateTime _lastDay;
  DateTime _focusedDay;
  RangeSelectionMode _rangeSelectionMode;
  DateTime _rangeStartDay;
  DateTime _rangeEndDay;
  DateTime _selectedDay;
  int _tabIndex;
  ValueNotifier<List<Event>> _selectedEvents;
  int _attendValue;
  TabController _controller;
  List<dynamic> _bookInfoList = [];
  List<dynamic> _authInfoList = [];
  int _character;
  String _profile;
  String _galaxyName;
  int _authCount;

  @override
  void initState() {
    super.initState();
    _tabIndex = 0;
    _attendValue = 0;
    _controller = new TabController(length: 2, vsync: this, initialIndex: _tabIndex);
    switch (DateTime.now().weekday) {
      case 1:
        _weekday = 1;
        break;
      case 2:
        _weekday = 2;
        break;
      case 3:
        _weekday = 4;
        break;
      case 4:
        _weekday = 8;
        break;
      case 5:
        _weekday = 16;
        break;
      case 6:
        _weekday = 32;
        break;
      case 7:
        _weekday = 64;
        break;
    }
    _focusedDay = DateTime.now();
    _firstDay = DateTime(_focusedDay.year - 1, _focusedDay.month);
    _lastDay = DateTime(_focusedDay.year + 1, DateTime.now().month + 1,0);
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
  }

  @override
  void dispose() {
    super.dispose();
    _selectedEvents.dispose();
  }

  Widget _getCalendar(BuildContext context, List<dynamic> infoList) {
    _uiCriteria.init(context);
    return TableCalendar<Event>(
        availableGestures: AvailableGestures.horizontalSwipe,
        locale: 'ko_KR',
        lastDay: _lastDay,
        focusedDay: _focusedDay,
        firstDay:  _firstDay,
        eventLoader: (DateTime dateTime) {
          return _getEventsForDay(dateTime, infoList, _tabIndex);
        },
        rangeStartDay: _rangeStartDay,
        rangeEndDay: _rangeEndDay,
        rowHeight: _uiCriteria.screenWidth * 0.1307,
        calendarFormat: CalendarFormat.month,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (BuildContext context, DateTime one, List<Event> event) {
            for (int i = 0; i < event.length; i++) {
              return Container(
                width: _uiCriteria.calendarMarkerSize,
                height: _uiCriteria.calendarMarkerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_tabIndex == 0)?Color(0XFFE7535C):(event[i].color)
                ),
              );
            }
            return null;
          },
          selectedBuilder: (BuildContext context, DateTime one, DateTime two) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.transparent
              ),
              child: Container(
                alignment: Alignment.center,
                width: _uiCriteria.screenWidth * 0.064,
                height: _uiCriteria.screenWidth * 0.064,
                decoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                    "${one.day}",
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: _uiCriteria.textSize3)
                ),
              ),
            );
          },
          todayBuilder: (BuildContext context, DateTime one, DateTime two) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent
              ),
              child: Container(
                alignment: Alignment.center,
                width: _uiCriteria.screenWidth * 0.064,
                height: _uiCriteria.screenWidth * 0.064,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: mainColor.withOpacity(0.1), width: 0.2),
                  boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), spreadRadius: 1, blurRadius: 6, offset: Offset(0,0))],
                ),
                child: Text(
                    "${one.day}",
                    style: TextStyle(fontWeight: FontWeight.w700, color: mainColor, fontSize: _uiCriteria.textSize3)
                ),
              ),
            );
          }
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle:  TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          weekendTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          disabledTextStyle: TextStyle(color: greyAAAAAA, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mainColor,
          ),
          markerSize: _uiCriteria.calendarMarkerSize,
          todayTextStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          rangeStartTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          rangeEndTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          selectedTextStyle: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(_uiCriteria.screenWidth * 0.01067),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
          ),
          weekdayStyle: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),
          weekendStyle: TextStyle(color: const Color(0XFFE7535C), fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),
        ),
        daysOfWeekHeight: _uiCriteria.totalHeight * 0.0431,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(letterSpacing: 0.6, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),
          headerMargin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.01379),
          headerPadding: EdgeInsets.zero,
          leftChevronMargin: EdgeInsets.zero,
          rightChevronMargin: EdgeInsets.only(right: _uiCriteria.horizontalPadding),
          leftChevronPadding: EdgeInsets.only(left: _uiCriteria.horizontalPadding),
          rightChevronPadding: EdgeInsets.zero,
          leftChevronIcon:  Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent)
              ),
              child: Icon(Icons.chevron_left_sharp, color: mainColor, size: _uiCriteria.textSize4,)),
          rightChevronIcon: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent)
              ),
              child: Icon(Icons.chevron_right_sharp, color: mainColor, size: _uiCriteria.textSize4,)),
        ),
        rangeSelectionMode: _rangeSelectionMode,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
          _onDaySelected(selectedDay, focusedDay, infoList, _tabIndex);
        },
    );
  }

  void _navigateSpeckCash(BuildContext context, String amount) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CashInfo(cashAmount: amount,)));
  }

  void _connectNotion(String url) async{
    await launch(url);
  }

  void _navigateTicketInfo(String placeName, int attCount, int totalCount, int attRate,
      int totalDeposit, int myDeposit, int totalDust, int accumPrize, int estimatePrize, String attendTime, int timeNum, String galaxyName, int mannerTime) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TicketInfo(
      placeName: placeName,
      attCount:  attCount,
      totalCount: totalCount,
      attRate: attRate,
      totalDeposit: totalDeposit,
      myDeposit: myDeposit,
      totalDust: totalDust,
      accumPrize: accumPrize,
      estimatePrize: estimatePrize,
      attendTime: attendTime,
      timeNum: timeNum,
      galaxyName: galaxyName,
      mannerTime: mannerTime,
    )));
  }


}
