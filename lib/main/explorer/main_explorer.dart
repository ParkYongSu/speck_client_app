import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/State/explorer_state.dart';
import 'package:speck_app/State/explorer_tab_state.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/main/explorer/explorer.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/widget/public_widget.dart';

class MainExplorer extends StatefulWidget {
  @override
  _MainExplorerState createState() => _MainExplorerState();
}

class _MainExplorerState extends State<MainExplorer> {
  UICriteria _uiCriteria = new UICriteria();
  List<Widget> _galaxyList = [];
  ExplorerState _es;
  int _route = 1;
  ExplorerTabState _ets;
  @override
  Widget build(BuildContext context) {
    _ets = Provider.of<ExplorerTabState>(context);
    _uiCriteria.init(context);
    _es = Provider.of<ExplorerState>(context, listen: false);

    return FutureBuilder(
        future: _getExplorerList(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == true) {

            return snapshot.data;
          }
          else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white
              ),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                width: _uiCriteria.screenWidth * 0.0666,
                height: _uiCriteria.screenWidth * 0.0666,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                )
              ),
            );
          }
        }
      );
  }

  Future<dynamic> _requestExplorer(String userEmail) async {
    var url = Uri.parse("http://$speckUrl/explorer");
    String body = ''' 
      {
        "userEmail" : "$userEmail"
      }
    ''';
    print("body $body");
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(url,body: body, headers: header);
    
    dynamic result = jsonDecode(utf8.decode(response.bodyBytes));
    print("탐험단 $result");
    return Future(() {
      return result;
    });
  }

  Future<Widget> _getExplorerList(BuildContext context) async {// SharedPreferences sp = await SharedPreferences.getInstance();
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userEmail = sp.getString("email");
    var result;
    Future future = _requestExplorer(userEmail);
    await future.then((value) => result = value).onError((error, stackTrace) => print(error));

    List<dynamic> explorerList = result;
    if (explorerList.isEmpty) {
      return _noGalaxy();
    }
    else {
      return _existGalaxy(context, explorerList);
    }

  }

  Widget _existGalaxy(BuildContext context, List<dynamic> explorerList) {
    List<Widget> list = [
      title(context, "다가오는 탐험단"),
      _todayGalaxy(context, explorerList),
      greyBar(),
      _myTitle(context, "나의 갤럭시 총", _galaxyList.length),
      _myGalaxy(),
      _whiteBar()
    ];

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return list[index];
      },
    );
  }

  void _sort(List<dynamic> list) {
    for (int i = 0; i < list.length - 1; i++) {
      int min = i;
      for (int j = i + 1; j < list.length; j++) {
        if (DateTime.parse(list[min]["nextReserveTime"]).isAfter(DateTime.parse(list[j]["nextReserveTime"]))) {
          min = j;
        }
      }
      dynamic temp = list[i];
      list[i] = list[min];
      list[min] = temp;
    }
  }

  Widget _todayGalaxy(BuildContext context, List<dynamic> explorerList) {
    Widget result;

    _sort(explorerList);
    for (int i = 0; i < explorerList.length; i++) {
      dynamic data = explorerList[i];
      int official = data["official"];
      String galaxyName = data["galaxyName"];
      String nickname = data["nickName"];
      String imgUrl = data["imgUrl"];
      int galaxyNum = data["galaxyNum"];
      int todayReserve = data["todayReserve"];
      int avgAtt = data["avgAtt"];
      int avgAttRank = data["avgAttranking"];
      int bookInfo = data["bookinfo"];
      List<dynamic> timeList = data["timeNumList"];
      String bookStartDate = data["bookStartDate"];
      String bookEndDate = data["bookEndDate"];
      int attendCount = data["attendCount"];
      int timeNum = data["timeNum"];
      List<dynamic> hts = data["hashTags"];
      String message = data["message"];
      String nextReserveTime = data["nextReserveTime"];
      List<Widget> hashTags = generateHashTags(context, hts);

      /// 크게 표시될 갤럭시
      if (result == null && (DateTime.now().isBefore(DateTime.parse(nextReserveTime + " " + getAuthTime(timeNum))))) {
          result = _nextGalaxy(timeNum, official, galaxyName, todayReserve, message, imgUrl, galaxyNum,
              hashTags, avgAtt, avgAttRank, timeList, bookInfo, bookStartDate, bookEndDate);
      }

      /// 여기서 나의 갤럭시 리스트에도 추가
      if (_galaxyList.length < explorerList.length) {
        _galaxyList.add(
            _gridElement(official, nickname, galaxyName, todayReserve, message, imgUrl, galaxyNum,
                hashTags, avgAtt, avgAttRank, timeList, bookStartDate, bookEndDate, attendCount, timeNum, bookInfo));
      }
    }

    return result??Container();
  }

  Widget _gridElement(int official, String nickname, String galaxyName, int todayReserve,
      String message, String imgUrl, int galaxyNum, List<Widget> hashTags, int avgAtt, int avgAttRank,
      List<dynamic> timeList, String bookStartDate, String bookEndDate, int attendCount, int timeNum, int bookInfo) {
    DateTime current = DateTime.now();
    String status;
    Color statusColor;
    if (current.isAfter(DateTime.parse(bookStartDate)) && current.isBefore(DateTime.parse(bookEndDate + " " + getAuthTime(timeNum)))) {
      status = "진행중";
      statusColor = Color(0XFF404040);
    }
    else if (current.isAfter(DateTime.parse(bookEndDate + " " + getAuthTime(timeNum)))) {
      status = "완료됨";
      statusColor = greyD8D8D8;
    }
    else {
      DateTime start = DateTime.parse(bookStartDate);
      int dDay = DateTime(start.year,start.month,start.day, 0, 0, 0, 0)
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
    // if (current.isAfter(DateTime.parse(bookStartDate)) && current.isBefore(DateTime.parse(bookEndDate))) {
    //   status = "진행중";
    //   statusColor = Color(0XFF404040);
    // }
    // else {
    //   DateTime start = DateTime.parse(bookStartDate);
    //   int dDay = DateTime(start.year,start.month,start.day, 0, 0, 0, 0)
    //       .difference(DateTime(current.year, current.month, current.day, 0, 0, 0, 0)).inDays;
    //   if (dDay == 0) {
    //     status = "진행중";
    //     statusColor = Color(0XFF404040);
    //   }
    //   else {
    //     status = "D-"+ dDay.toString();
    //     statusColor = Color(0XFFE7535C);
    //   }
    // }
    return GestureDetector(
      onTap: () {
        _navigateExplorer(official, galaxyName, todayReserve, message, imgUrl, galaxyNum, hashTags, avgAtt, avgAttRank, timeList, timeNum, bookInfo);
      },
      child: AspectRatio(
        aspectRatio: 166/240,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                          height: constraint.maxHeight * 0.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.9),
                              image: DecorationImage(
                                // image: NetworkImage(imgUrl,),
                                  image: NetworkImage(imgUrl),
                                  fit: BoxFit.cover
                              )
                          )
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: constraint.maxHeight * 0.0188, horizontal: constraint.maxWidth * 0.0421),
                          margin: EdgeInsets.only(top: constraint.maxHeight * 0.0283, right: constraint.maxWidth * 0.036),
                          decoration: BoxDecoration(
                              color: (official == 1)?mainColor.withOpacity(0.9):greyD8D8D8.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(3.5)
                          ),
                          child: Text((official == 1)?"자유 장소":"지정 장소", maxLines: 1,style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w700),)
                      )
                    ],
                  ),
                  Spacer(flex: 13),
                  (official == 1)
                      ? Row(
                    children: <Widget>[
                      Image.asset("assets/png/speck_public.png", height: _uiCriteria.screenWidth * 0.0346,),
                      Text(" $nickname", style: TextStyle(letterSpacing: 0.5, fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500),)
                    ],
                  )
                  //todo. 비공식
                      : Row(
                      children: <Widget>[

                      ]
                  ),
                  Spacer(flex: 5),
                  AutoSizeText((official == 1)?"[공식] $galaxyName": galaxyName, style: TextStyle(letterSpacing: 0.24, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),),
                  Spacer(flex: 7),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, color: mainColor),
                          children: <TextSpan>[
                            TextSpan(text: "오늘 예약자"),
                            TextSpan(text: " $todayReserve명", style: TextStyle(fontWeight: FontWeight.w700))
                          ]
                      )
                  ),
                  Spacer(flex: 3),
                  Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("가입한 탐험단", style: TextStyle(fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, color: mainColor),),
                          Text(" ${getAuthTime(timeNum)}", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize5, color: mainColor))
                        ],
                      ),
                    ],
                  ),
                  Spacer(flex: 12),
                  Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.5),
                          color: statusColor
                        ),
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0662, vertical: constraint.maxHeight * 0.0208),
                        child: Text(status, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
                      ),
                      SizedBox(width: constraint.maxWidth * 0.025),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.5),
                            color: greyF5F5F6
                        ),
                        padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0331, vertical: constraint.maxHeight * 0.0208 ),
                        child: Text("출석횟수 $attendCount회"  , style: TextStyle(color: greyB3B3BC, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _noGalaxy() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color:  greyF0F0F1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Spacer(flex: 202,),
          Container(
            margin: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.084),
            child: Image.asset("assets/png/ssugi_line.png")),
          Spacer(flex: 39,),
          Text("아직 가입한 탐험단이 없어요.", style: TextStyle(color: greyAAAAAA, fontWeight: FontWeight.w700, letterSpacing: 0.7, fontSize: _uiCriteria.textSize2),),
          Spacer(flex: 209,)
        ],
      ),
    );
  }

  Widget _myGalaxy() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, ),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.0268),
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 166/240,
            mainAxisSpacing: _uiCriteria.verticalPadding,
            crossAxisSpacing: _uiCriteria.screenWidth * 0.0293,
          ),
          itemCount: _galaxyList.length,
          itemBuilder: (BuildContext context, int index) {

            return _galaxyList[index];
          }
      ),
    );
  }

  Widget _whiteBar() {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        width: double.infinity,
        height: _uiCriteria.totalHeight * 0.0268,
    );
  }

  Widget _myTitle(BuildContext context, String title, int galaxyCount) {
    uiInit(context);
    return AspectRatio(
      aspectRatio: 375/39.8,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
        ),
        child: Row(
          children: [
            Text(title, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
            Text(" $galaxyCount개", style: TextStyle(color: Color(0XFFE7535C), fontSize: uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
          ],
        ),
      ),
    );
  }

  Widget _nextGalaxy(int timeNum, int official, String galaxyName, int todayReserve, String message, String imgUrl, int galaxyNum,
      List<Widget> hashTags, int avgAtt, int avgAttRank, List<dynamic> timeList, int bookInfo, String bookStartDate, String bookEndDate) {
    String time = getAuthTime(timeNum);
    DateTime current = DateTime.now();
    String status;
    Color statusColor;
    if (current.isAfter(DateTime.parse(bookStartDate)) && current.isBefore(DateTime.parse(bookEndDate + " " + time))) {
      status = "진행중";
      statusColor = Color(0XFF404040);
    }
    else if (current.isAfter(DateTime.parse(bookEndDate + " " + time))) {
      status = "완료됨";
      statusColor = greyD8D8D8;
    }
    else {
      DateTime start = DateTime.parse(bookStartDate);
      int dDay = DateTime(start.year,start.month,start.day, 0, 0, 0, 0)
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
    // if (current.isAfter(DateTime.parse(bookStartDate)) && current.isBefore(DateTime.parse(bookEndDate))) {
    //   status = "진행중";
    //   statusColor = Color(0XFF404040);
    // }
    // else {
    //   DateTime start = DateTime.parse(bookStartDate);
    //   int dDay = DateTime(start.year,start.month,start.day, 0, 0, 0, 0)
    //       .difference(DateTime(current.year, current.month, current.day, 0, 0, 0, 0)).inDays;
    //   if (dDay == 0) {
    //     status = "진행중";
    //     statusColor = Color(0XFF404040);
    //   }
    //   else {
    //     status = "D-"+ dDay.toString();
    //     statusColor = Color(0XFFE7535C);
    //   }
    // }

    return GestureDetector(
      onTap: () => _navigateExplorer(official, galaxyName, todayReserve, message, imgUrl, galaxyNum, hashTags, avgAtt, avgAttRank, timeList, timeNum, bookInfo),
      child: AspectRatio(
        aspectRatio: 375 / 391,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
              horizontal: _uiCriteria.horizontalPadding,),
          child: AspectRatio(
            aspectRatio: 343/343,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.9),
                      image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.fitHeight
                      )
                  ),
                  padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0466, vertical: constraint.maxHeight * 0.0437),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("${(official == 1)?"[공식] $galaxyName": galaxyName}", style: TextStyle(fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize6, letterSpacing: 0.4, color: Colors.white),),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.5),
                                color: statusColor
                            ),
                            padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0247, vertical: constraint.maxHeight * 0.01457),
                            child: Text(status, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5, letterSpacing: 0.5),),
                          ),
                        ],
                      ),
                      Spacer(flex: 11,),
                      Row(
                        children: <Widget>[
                          Text("오늘 예약자 ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),),
                          Text("$todayReserve명", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize5),),
                        ],
                      ),
                      Spacer(flex: 4,),
                      Row(
                        children: <Widget>[
                          Text("출석 예약시간 ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),),
                          Text(time, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),),
                        ],
                      ),
                      Spacer(flex: 265,)
                    ],
                  ),
                );
              },
            )
          ),
        ),
      ),
    );
  }


  void _navigateExplorer(int official, String galaxyName, int todayReserve, String message,
      String imgUrl, int galaxyNum, List<Widget> hashTags, int avgAtt, int avgAttRank,
      List<dynamic> timeList, int timeNum, int bookInfo) {
    _ets.setTabIndex1(1);
    String selectedDate = DateTime.now().toString().substring(0, 10);
    _es.setGalaxyName(galaxyName);
    _es.setGalaxyNum(galaxyNum);
    _es.setImagePath(imgUrl);
    _es.setOfficial(official);
    _es.setRoute(_route);
    _es.setSelectedDate(selectedDate);
    _es.setSelectedDateWeekdayText("오늘");
    _es.setTimeList(timeList);
    _es.setTimeNum(timeNum);
    _es.setBookInfo(bookInfo);
    // _es.setSumPerson(_accumAtt);
    // _es.setTotalPayment(_accumDepo);
    Navigator.push(context, MaterialPageRoute(builder: (context)
    => Explorer(
        galaxyName: galaxyName,
        imageUrl: imgUrl,
        galaxyNum: galaxyNum,
        official: official,
        timeNum: timeNum)));
  }
}
