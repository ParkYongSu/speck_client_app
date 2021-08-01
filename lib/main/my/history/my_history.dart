import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/main/my/history/history_info.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/widget/public_widget.dart';

class MyHistory extends StatefulWidget {
  @override
  _MyHistoryState createState() => _MyHistoryState();
}

class _MyHistoryState extends State<MyHistory> with TickerProviderStateMixin {
  UICriteria _uiCriteria = new UICriteria();
  TabController _controller;
  int _tabIndex;
  List<Widget> _publicList;
  List<Widget> _ingGalaxy;
  List<Widget> _expireGalaxy;

  @override
  void initState() {
    super.initState();
    _tabIndex = 0;
    _controller = new TabController(length: 2, vsync: this, initialIndex: _tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return Scaffold(
        appBar: appBar(context, "나의 갤럭시 전체보기"),
        body: FutureBuilder(
          future: _getMyHistory(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              print("스냅샷 데이터 ${snapshot.data}");
              List<dynamic> ing = snapshot.data["myGalaxy"];
              List<dynamic> expire = snapshot.data["expireGalaxy"];
              _sort(ing);
              _sort(expire);
              _ingGalaxy = _getGalaxy(ing);
              _expireGalaxy = _getGalaxy(expire);
              return  Container(
                decoration: BoxDecoration(
                    color: Colors.white
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
                      ),
                      child: TabBar(
                        controller: _controller,
                        indicatorColor: Colors.black,
                        indicatorWeight: 3,
                        tabs: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            height: _uiCriteria.totalHeight * 0.049,
                            child: Text("탐험중인 갤럭시", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: _uiCriteria.totalHeight * 0.049,
                            child: Text("완료한 갤럭시",  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _controller,
                        children: <Widget>[
                          _tab(context, _ingGalaxy),
                          _tab(context, _expireGalaxy)
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
            else {
              return loader(context, 0);
            }
          },
        )
    );
  }

  Widget _publicGalaxyTitle(BuildContext context, List<Widget> list) {
    return AspectRatio(
      aspectRatio: 375/39.8,
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0XFFCACAD1), width: 0.5))
        ),
        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("공식 갤럭시", style: TextStyle(fontSize: _uiCriteria.textSize2, color: Colors.black, fontWeight: FontWeight.w700),),
            RichText(
              text: TextSpan(
                  style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: "총 "),
                    TextSpan(text: "${list.length}", style: TextStyle(color: Color(0XFFe7535c))),
                    TextSpan(text: "개"),
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> _request() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userEmail = sp.getString("email");
    Uri url = Uri.parse("http://13.209.138.39:8080/mypage/mygalaxy");
    String body = '''{
      "userEmail" : "$userEmail" 
    }''';

    Map<String, String> header = {"Content-Type":"application/json"};


    var response = await http.post(url, body: body, headers: header);
    print(response);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("내 갤럭시: $result");
    return Future(() {
      return result;
    });
  }

  Future<dynamic> _getMyHistory() async  {
    Future future = _request();
    var result;
    await future.then((value) => result = value).onError((error, stackTrace) => print(error));
    print("************* $result");
    return result;
  }

  List<Widget> _getGalaxy(List<dynamic> galaxy) {
  List<Widget> result = <Widget>[];
  
    for (int i = 0; i < galaxy.length; i++) {
      dynamic info = galaxy[i];
      int official = info["official"];
      String time = getAuthTime(info["timeNum"]);
      int attendCount = info["attendCount"];
      int totalCount = info["totalCount"];
      int bookInfo = info["bookinfo"];
      String startDate = info["startdate"];
      String endDate = info["enddate"];
      DateTime current = DateTime.now();
      String galaxyName = info["galaxyName"];
      String start = "${startDate.toString().substring(0,4)}.${startDate.toString().substring(5,7)}.${startDate.toString().substring(8,10)}";
      String end = "${endDate.toString().substring(0,4)}.${endDate.toString().substring(5,7)}.${endDate.toString().substring(8,10)}";
      String status;
      Color statusColor;
      int index;

      if (current.isAfter(DateTime.parse(startDate)) && current.isBefore(DateTime.parse(endDate + " " + time))) {
        status = "진행중";
        statusColor = Color(0XFF404040);
        index = 1;
      }
      else if (current.isAfter(DateTime.parse(endDate + " " + time))) {
        status = "완료됨";
        statusColor = greyD8D8D8;
        index = 1;
      }
      else {
        DateTime start = DateTime.parse(startDate);
        int dDay = DateTime(start.year,start.month,start.day, 0, 0, 0, 0)
            .difference(DateTime(current.year, current.month, current.day, 0, 0, 0, 0)).inDays;
        if (dDay == 0) {
          status = "진행중";
          statusColor = Color(0XFF404040);
          index = 1;
        }
        else {
          status = "D-"+ dDay.toString();
          statusColor = Color(0XFFE7535C);
          index = 0;
        }
      }

      result.add(
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent
            ),
            child: AspectRatio(
                aspectRatio: 375/103,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraint) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.1165),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: constraint.maxWidth * 0.2107,
                            height: constraint.maxWidth * 0.2107,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0XFFd8d8d8)),
                                borderRadius: BorderRadius.circular(6.9),
                                image: DecorationImage(
                                  image: AssetImage("assets/png/example.png",),
                                  fit: BoxFit.fitHeight
                                )
                            ),
                          ),
                          SizedBox(
                            width: _uiCriteria.horizontalPadding,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.016, vertical: constraint.maxHeight * 0.0388),
                                    decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(3.5)
                                    ),
                                    child: Text(
                                      status, style: TextStyle(fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: constraint.maxWidth * 0.016,),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.016, vertical: constraint.maxHeight * 0.0388),
                                    decoration: BoxDecoration(
                                        color: Color(0XFFf5f5f6),
                                        borderRadius: BorderRadius.circular(3.5)
                                    ),
                                    child: Text(
                                      "출석횟수 $attendCount회", style: TextStyle(fontSize: _uiCriteria.textSize3, color: Color(0XFFd8d8d8), fontWeight: FontWeight.w500,),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: constraint.maxHeight * 0.068,
                              ),
                              Text("${(official == 0)?"[공식] ":""}$galaxyName($time)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3),),
                              SizedBox(
                                height: constraint.maxHeight * 0.068,
                              ),
                              RichText(
                                text: TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize5),
                                    children: <TextSpan>[
                                      TextSpan(text: "예약 기간"),
                                      TextSpan(text: " $start ~ $end (총 $totalCount일)", style: TextStyle(fontWeight: FontWeight.w700))
                                    ]
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                )
            ),
          ),
          onTap: () => _navigateHistoryInfo(index, bookInfo),
        ),
      );
    }
    return result;
  }


  Widget _galaxyList(BuildContext context, List<Widget> list) {
    return  Container(
      padding: EdgeInsets.symmetric(vertical: _uiCriteria.totalHeight * 0.0148),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return list[index];
          }),
    );
  }

  Widget _tab(BuildContext context, List<Widget> list) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _publicGalaxyTitle(context, list),
          _galaxyList(context, list)
        ]
      ),
    );
  }


  void _navigateHistoryInfo(int type, int bookInfo) {
    print(type);
    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryInfo(type: type, bookInfo: bookInfo,)));
  }

  void _sort(List<dynamic> list) {
    for (int i = 0; i < list.length - 1; i++) {
      int min = i;
      for (int j = i + 1; j < list.length; j++) {
        if (DateTime.parse(list[min]["startdate"]).isAfter(DateTime.parse(list[j]["startdate"]))) {
          min = j;
        }
      }
      dynamic temp = list[i];
      list[i] = list[min];
      list[min] = temp;
    }
  }

}
