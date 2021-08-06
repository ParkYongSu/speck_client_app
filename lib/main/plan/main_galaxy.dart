import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/Login/Todo/state_time_sort.dart';
import 'package:speck_app/State/banner_state.dart';
import 'package:speck_app/State/recommend_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';
import 'galaxy_detail_form.dart';

class MainPlan extends StatefulWidget {
  @override
  _MainPlanState createState() => _MainPlanState();
}

class _MainPlanState extends State<MainPlan> {
  int _selectedIndex;

  final UICriteria _uiCriteria = new UICriteria();
  final TextEditingController _galaxyRecommendController = new TextEditingController();
  ValueNotifier<bool> _recommendIsNotEmpty;
  int _galaxyState;
  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _recommendIsNotEmpty = new ValueNotifier<bool>(false);
    _galaxyState = 0;
  }
  RecommendBannerState _rbs;
  BannerState _bs;

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _rbs = Provider.of<RecommendBannerState>(context, listen: false);
    _bs = Provider.of<BannerState>(context, listen: false);

    List<Widget> _items = [
      _category("assets/png/galaxy_category_all.png", "전체", 0),
      _category("assets/png/galaxy_category_officer.png", "공무원", 1),
      _category("assets/png/galaxy_category_employment.png", "취업", 2),
      _category("assets/png/galaxy_category_license.png", "자격증", 3),
      _category("assets/png/galaxy_category_language.png", "어학", 4),
      _category("assets/png/galaxy_category_university.png", "대학교", 5),
      _category("assets/png/galaxy_category_secondary.png", "중고등학교", 6),
      _category("assets/png/galaxy_category_others.png", "기타", 7),

    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 375/95,
                  child: Container(
                        // padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.116),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5)),
                        ),
                        child: ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _items[index];
                          },
                          scrollDirection: Axis.horizontal,
                        ),
                      )
                ),
                AspectRatio(
                  aspectRatio: 375/11.8,
                  child: Container(
                    color: greyF0F0F1,
                  )
                ),
                Expanded(
                  child:  Container(
                    child: FutureBuilder(
                        future: _getGalaxyList(context, _selectedIndex).whenComplete(() {
                          // _showRecommendBanner("희망 갤럭시 추천", "토익, 한국사, 자격증, 대기업면접 등", "학습목표", "ex) 컴활 1급, 공무원 시험 등");
                          _showRecommendBanner("희망 갤럭시 추천", "토익, 한국사, 자격증, 대기업면접 등", "학습목표", "ex) 컴활 1급, 공무원 시험 등");
                        }),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          print("snapshot: ${snapshot.data}");
                          print(snapshot.data.runtimeType);
                          if (snapshot.hasData == true) {
                            // List<Widget> info = snapshot.data;
                            return snapshot.data;
                            // return RefreshIndicator(
                            //   // child: SingleChildScrollView(
                            //   //     child: Column(
                            //   //       children: info,
                            //   //     )
                            //   // ),
                            //   child: ListView.builder(
                            //       shrinkWrap: true,
                            //       scrollDirection: Axis.vertical,
                            //       itemCount: info.length,
                            //       itemBuilder: (BuildContext context, int index) {
                            //         return info[index];
                            //       }),
                            //   color: Color(0XFF404040),
                            //   onRefresh: () async {
                            //     Future future = _todoPlan.getGalaxyList(context, _selectedIndex, _weekday);
                            //     await future.then((value) {
                            //       setState(() {
                            //         info = value;
                            //       });
                            //     },
                            //         onError: (e) => print(e));
                            //   },
                            //
                            // );
                          }
                          else {
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      width: _uiCriteria.screenWidth * 0.0666,
                                      height: _uiCriteria.screenWidth * 0.0666,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                                      ))
                                ]
                            );
                          }
                        }),
                  ),
                )
              ]
          ),
      ),
    );
  }

  Widget _category(String imagePath, String title, int index) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              alignment: Alignment.center,
              padding: (index == 0)? EdgeInsets.only(left: _uiCriteria.horizontalPadding, top: constraint.maxHeight * 0.116, bottom: constraint.maxHeight * 0.116) : EdgeInsets.only( top: constraint.maxHeight * 0.116, bottom: constraint.maxHeight * 0.116),
              margin: EdgeInsets.only(right: _uiCriteria.screenWidth * 0.064),
              child :Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: _uiCriteria.screenWidth * 0.1333,
                      height: _uiCriteria.screenWidth * 0.1333,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: (_selectedIndex != index)?[BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0,1))]:null,
                          color: (_selectedIndex == index)?mainColor:Colors.white
                      ),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraint) {
                          return Container(
                              padding: EdgeInsets.all(constraint.maxWidth * 0.28),
                              child: Image.asset(imagePath, height: _uiCriteria.totalHeight  * 0.035, color: (_selectedIndex == index)?Colors.white:mainColor,)
                          );
                        },
                      ),
                    ),
                    Text(title, style: TextStyle(letterSpacing: 0.6,fontWeight: FontWeight.w700,color: mainColor, fontSize: _uiCriteria.textSize3))
                  ]
              ),
            );
          },
        )
    );
  }

  Future<dynamic> _getGalaxyInfo(int categoryId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString("email");
    var url = Uri.parse("http://$speckUrl/galaxy");
    print("카테고리 $categoryId");
    String body = '''{
      "userEmail" : "$email",
      "category_id":$categoryId
    }''';
    Map<String, String> header = {
      "Content-Type":"application/json"
    };
    print("39483204");
    var response = await http.post(url, headers: header, body: body);
    var utf = utf8.decode(response.bodyBytes);
    var result = jsonDecode(utf);
    print("갤럭시 : $result");
    return Future(() {
      return result;
    });
  }


  Future<Widget> _getGalaxyList(BuildContext context, int categoryId) async {
    _uiCriteria.init(context);
    Future future = _getGalaxyInfo(categoryId);
    dynamic result;
    List<dynamic> galaxy;
    List<Widget> widgets = []; // 갤럭시들의 정보를 담은 위젯의 리스트
    await future.then((value) => result = value, onError: (e) => print(e));
    galaxy = result["galaxyList"];// 서버에서 갤럭시 정보를 가져와서 리스트에 저장
    int count = galaxy.length;// 총 갤럭시 수
    print(count);

    for (int i = 0; i < count; i++) {
      dynamic info = galaxy[i];
      String galaxyName = info["galaxyName"]; // 학교이름
      String message = info["message"]; // 리더의 한마디
      int galaxyNum = info["galaxyNum"];
      int official = info["official"];
      String nickname = info["nickName"];
      int todayReserve = info["todayReserve"];
      List<dynamic> hts = info["hashTags"];
      String imgUrl = info["imgUrl"];
      List<dynamic> timeList = info["timeList"];

      List<Widget> hashTags = generateHashTags(context, hts);

      widgets.add(
          GestureDetector(
            onTap: () {
              TimeSort timeSort = Provider.of<TimeSort>(context, listen: false);
              timeSort.setSortName("예약자순");
              Navigator.push(context, MaterialPageRoute(builder: (context) => GalaxyDetailForm(
                galaxyName: galaxyName,
                message: message,
                imagePath: imgUrl,
                galaxyNum: galaxyNum,
                official: official,
                // timeList: timeList,
                route: 0,
              )));
              // Navigator.push(context, MaterialPageRoute(builder: (context) => GalaxyDetail(
              //     galaxyName: galaxyName,
              //     message: message,
              //     imagePath: imagePath,
              //     galaxyNum: galaxyNum,
              //     type: official,
              //     avgAtt: avgAtt,
              //     avgAttRank: avgAttrangking,
              //     hashTags: hashTags,
              //     timeList: timeList
              // )));
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
                                          // image: NetworkImage(imagePath,),
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
                            SizedBox(
                              height: constraint.maxHeight * 0.0542,
                            ),
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
                            SizedBox(height: constraint.maxHeight * 0.0208,),
                            AutoSizeText((official == 1)?"[공식] $galaxyName": galaxyName, style: TextStyle(letterSpacing: 0.24, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700),),
                            SizedBox(
                              height: constraint.maxHeight * 0.0292,
                            ),
                            RichText(
                                text: TextSpan(
                                    style: TextStyle(fontSize: _uiCriteria.textSize5, fontWeight: FontWeight.w500, color: mainColor),
                                    children: <TextSpan>[
                                      TextSpan(text: "오늘 예약자"),
                                      TextSpan(text: " $todayReserve명", style: TextStyle(fontWeight: FontWeight.w700))
                                    ]
                                )
                            ),
                            SizedBox(
                              height: constraint.maxHeight * 0.05,
                            ),
                            Wrap(
                              runSpacing: constraint.maxHeight * 0.004,
                              children: hashTags,
                            )
                          ],
                        )
                    );
                  },
                )
            ),
          )
      );
    }

    return Future(() {
      return Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 375/39.8,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                        style: TextStyle(fontSize: _uiCriteria.textSize2, fontWeight: FontWeight.w700, color: mainColor),
                        children: <TextSpan>[
                          TextSpan(text: "총 갤럭시 "),
                          TextSpan(text: "$count개", style: TextStyle(color: Color(0XFFE7535C))),
                        ]
                    ),
                  ),
                  GestureDetector(
                    child: Hero(
                      tag: "hi",
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0213, vertical: _uiCriteria.screenWidth * 0.0156),
                        decoration: BoxDecoration(
                          color: greyB3B3BC,
                          borderRadius: BorderRadius.circular(3.5),

                        ),
                        child: Text("추천", style: TextStyle(fontSize: _uiCriteria.textSize5, letterSpacing: 0.5, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ),
                    onTap: () {
                      _showDialog("희망 갤럭시 추천", "토익, 한국사, 자격증, 대기업면접 등", "학습목표", "ex) 컴활 1급, 공무원 시험 등");
                    },
                  )
                  // GestureDetector(
                  //   onTap: () => _sortList(context),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.transparent)
                  //     ),
                  //     child: Row(
                  //       children: <Widget>[
                  //         Consumer<GalaxySortName>(
                  //           builder: (BuildContext context, GalaxySortName galaxySortName, Widget child) {
                  //             return Text(galaxySortName.getSortName(), style: TextStyle(fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),);
                  //           },
                  //         ),
                  //         Icon(Icons.keyboard_arrow_down, color: greyD8D8D8,)
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          // AspectRatio(aspectRatio: 375/21.8),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, ),
              child: RefreshIndicator(
                onRefresh: () {
                  return
                    _getGalaxyList(context, _selectedIndex);
                },
                color: mainColor,
                child: GridView.builder(
                    padding: EdgeInsets.only(top: _uiCriteria.totalHeight * 0.0268),
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 166/240,
                      mainAxisSpacing: _uiCriteria.verticalPadding,
                      crossAxisSpacing: _uiCriteria.screenWidth * 0.0293,
                    ),
                    itemCount: widgets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widgets[index];
                    }),
              ),
            ),
          )
        ],
      );
    });
  }

  /// 배너 없어지면 삭제
  Widget _recommendBanner(String title, String example, String category, String hint) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.1653),
          child: Hero(
            tag: "hi",
            child: AspectRatio(
              aspectRatio: 250/194,
              child: Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3.5))),
                  color: Colors.white,
                  elevation: 3,
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraint) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 250/39.8,
                              child: Container(
                                alignment: Alignment.center,
                                height: constraint.maxWidth * 0.1,
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: mainColor, fontSize: uiCriteria.textSize2, letterSpacing: 0.7),),
                                    GestureDetector(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: constraint.maxWidth * 0.045),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.transparent)
                                              ),
                                              child: Icon(Icons.close, color: greyD8D8D8, size: _uiCriteria.textSize6,)),
                                        ),
                                      ),
                                      onTap: () => _transferData("close"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            AspectRatio(
                              aspectRatio: 250/153.8,
                              child: LayoutBuilder(
                                builder: (BuildContext context, BoxConstraints constraint) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.048),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(height: constraint.maxHeight * 0.0702,),
                                          Text(example, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                          SizedBox(height: constraint.maxHeight * 0.0702,),
                                          RichText(
                                            text: TextSpan(
                                                style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                                                children: <TextSpan>[
                                                  TextSpan(text: "원하시는 "),
                                                  TextSpan(text: category, style: TextStyle(fontWeight: FontWeight.bold)),
                                                  TextSpan(text: "를 입력창에 적어주시면")
                                                ]
                                            ),
                                          ),
                                          SizedBox(height: constraint.maxHeight * 0.03,),
                                          Text("빠른 시일 내에 추가할 수 있도록 노력하겠습니다!", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5),),
                                          SizedBox(height: constraint.maxHeight * 0.07,),
                                          Text("(스펙은 지금 열심히 성장 중입니다 :>)", style: TextStyle(color: greyAAAAAA, fontSize: uiCriteria.textSize5, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                                          SizedBox(height: constraint.maxHeight * 0.078,),
                                          AspectRatio(
                                            aspectRatio: 226/39,
                                            child: LayoutBuilder(
                                              builder: (BuildContext context, BoxConstraints constraint) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.048),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: greyB3B3BC, width: 0.5),
                                                      borderRadius: BorderRadius.circular(3.5)
                                                  ),
                                                  child: TextField(
                                                    controller: _galaxyRecommendController,
                                                    style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),
                                                    cursorColor: mainColor,
                                                    onChanged: (String value) {
                                                      if (value.isEmpty) {
                                                        _recommendIsNotEmpty.value = false;
                                                      }
                                                      else {
                                                        _recommendIsNotEmpty.value = true;
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        hintText: hint,
                                                        suffixIconConstraints: BoxConstraints(maxHeight: constraint.maxHeight * 0.333, maxWidth: constraint.maxWidth * 0.0690),
                                                        suffixIcon: ValueListenableBuilder(
                                                          valueListenable: _recommendIsNotEmpty,
                                                          builder: (BuildContext context, bool value, Widget child) {
                                                            return GestureDetector(
                                                                onTap: value
                                                                    ? () => _transferData("transfer")
                                                                    : null,
                                                                child: Image.asset("assets/png/transfer_icon.png", color: value?mainColor:greyD8D8D8));
                                                          },
                                                        ),
                                                        hintStyle: TextStyle(color: greyB3B3BC, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),
                                                        border: InputBorder.none
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(String title, String example, String category, String hint) {
    Navigator.push(context,
        PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            transitionDuration: Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 300),
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
              return child;
            },
            pageBuilder: (BuildContext context, Animation<double> first, Animation<double> second) {
              return _recommendBanner(title, example, category, hint);
            }
        )
    );
  }

  void _showRecommendBanner(String title, String example, String category, String hint) {
    if (_bs.getGalaxyStatus() == 1 && _rbs.getGalaxyBannerState() == 1) {
      _showDialog(title, example, category, hint);
      _rbs.setGalaxyBannerState(0);
      print(_galaxyState);
    }
  }
  
  void _transferData(String type) async {
    String data;
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("http://$speckUrl/home/insert/galaxy");
    String body;
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response;
    int status;

    // 처음 띄워지는데 닫기 눌렀을 때
   if (_bs.getGalaxyStatus() == 1 && type == "close") {

      body = '''{
      "first" : ${_bs.getGalaxyStatus()},
      "userEmail" : "${sp.getString("email")}",
      "value" : null
      }''';

      response = await http.post(url,body: body, headers: header);
      status = int.parse(response.body);
      if (status == 100) {
        Navigator.pop(context);
        _bs.setGalaxyStatus(0);
      }
   }
    // 그 다음부터 닫기 누를 때
    else if (type == "close") {
      Navigator.pop(context);
    }
    // 데이터 전송
    else if (type == "transfer") {
      data = _galaxyRecommendController.text;
      body = '''{
      "first" : ${_bs.getGalaxyStatus()},
      "userEmail" : "${sp.getString("email")}",
      "value" : "$data"
      }''';
      _showLoader();
      response = await http.post(url,body: body, headers: header);
      status = int.parse(response.body);
      if (status == 100) {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.pop(context);
        }).whenComplete(() {
          errorToast("입력되었습니다.");
          Navigator.pop(context);
          _bs.setGalaxyStatus(0);
        });
      }
      else {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.pop(context);
        }).whenComplete(() =>  errorToast("다시 시도해주세요."));
      }
    }
  }

  void _showLoader() {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return _loader();
        });
  }

  Widget _loader() {
    AlertDialog dialog = new AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
      ),
      content: AspectRatio(
          aspectRatio: 260/135,
          child: Column(
            children: [
              Expanded(
                  flex: 3,
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
                          width: uiCriteria.screenWidth * 0.0666,
                          height: uiCriteria.screenWidth * 0.0666,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(mainColor)
                          ),
                        ),
                      ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                      ),
                      alignment: Alignment.center,
                      child: Text("잠시만 기다려주세요", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: _uiCriteria.textSize2, letterSpacing: 0.6),))),
            ],
          )
      ),
    );

    return dialog;
  }
}
