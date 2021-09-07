import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:speck_app/Map/main_map.dart';
import 'package:speck_app/State/searching_word_state.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';

class SearchPage extends StatefulWidget {

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = new TextEditingController();
  List<Widget> postTileList;
  // 최근 검색어 목록
  static List<String> postWordList;
  List<Widget> _autoTileList;
  List<dynamic> _autoWordList;
  // 검색어 포함 리스트
  List<dynamic> _containedWordList;
  final UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    _initPostSearchList(context); // 최근검색어 초기화
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "지도 검색 페이지",
      home: Scaffold(
              appBar: AppBar(
                elevation: 0,
                toolbarHeight: _uiCriteria.appBarHeight,
                centerTitle: true,
                titleSpacing: 0,
                backwardsCompatibility: false,
                // brightness: Brightness.dark,
                systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
                title: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.008),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                              child: Icon(Icons.chevron_left_rounded,
                                  color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                              onTap: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.0713, right: _uiCriteria.horizontalPadding),
                      child: TextField(
                        style: TextStyle(letterSpacing: 0.8,fontSize: _uiCriteria.textSize16, color: Colors.white,),
                        cursorColor: Colors.white,
                        controller: _searchController,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: "주소 또는 건물명 검색",
                            hintStyle: TextStyle(letterSpacing: 0.8,fontSize: _uiCriteria.textSize16, color: greyB3B3BC, height: 1.5),
                            suffixIconConstraints: BoxConstraints(maxWidth: _uiCriteria.textSize4),
                            suffixIcon: Icon(Icons.search, color: Colors.white, size: _uiCriteria.screenWidth * 0.07,)
                         ),
                        onChanged: (String value) async {
                          // 검색창이 비어있지 않으면
                          if (value.length > 0) {
                            print(5);
                            _isSearchBarNotEmpty = true;
                            Future future = _getAutoWordList(value);
                            await future.then((value) => _containedWordList = value);

                            if (_containedWordList.isEmpty) {
                              _isContains = false;
                            }
                            else {
                              _isContains = true;
                              _autoTileList = _createAutoTileList(_containedWordList);
                            }

                            print("containedWordList $_containedWordList");
                            print(_isContains);
                          }
                          // 비어있으면
                          else {
                            _isSearchBarNotEmpty = false;
                          }
                          setState((){});
                        },
                        textInputAction: TextInputAction.search,
                        // onSubmitted: (_searchController.text.length > 0)?(String value) {
                        //   addPostWord(value);
                        // }:(String value) {},
                      ),
                    )
                  ]
              ),
                backgroundColor: mainColor,
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                child: _isSearchBarNotEmpty?
                Container(
                    alignment: Alignment.center,
                    width: _uiCriteria.screenWidth,
                    height: _uiCriteria.totalHeight,
                    // padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: greyD8D8D8, width: 0.5)),
                        color: greyF0F0F1
                    ),
                    child:  !_isContains?
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              AspectRatio(
                                  aspectRatio: 375/133.42,
                                  child: Image.asset("assets/png/ggomi_line.png")),
                              AspectRatio(aspectRatio: 375/31.4,),
                              Text("'${_searchController.text}'", style: TextStyle(
                                letterSpacing: 0.9,
                                color: mainColor, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w700,)),
                              AspectRatio(aspectRatio: 375/9,),
                              Text("검색결과가 없어요.", style: TextStyle(
                                  letterSpacing: 0.9,
                                  color: mainColor, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w500)),

                            ],
                          ),
                        ]
                    )
                        :Container(
                        child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return _autoTileList[index];
                            },
                            itemCount: _autoTileList.length)
                    )
                )
                    :
                Container(
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0XFFCACAD1), width: 0.5)),
                      color: Colors.white
                  ),
                  child: Column(children: <Widget>[
                    AspectRatio(
                        aspectRatio: 375/43.8,
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraint) {
                            return Container(
                                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.25),
                                decoration: BoxDecoration(
                                    color: mainColor
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0186),
                                            decoration: BoxDecoration(
                                                color: (_recentSearch)?Colors.white:mainColor,
                                                border: (_recentSearch)
                                                    ? Border.all(color: greyD8D8D8, width: 0.5)
                                                    : Border.all(color: Colors.transparent),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(3.5))),
                                            child: AutoSizeText(
                                                "최근 검색어",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    letterSpacing: 0.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: (_recentSearch)?mainColor:Colors.white,
                                                    fontSize: _uiCriteria.screenWidth * 0.027
                                                )),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _recentSearch = true;
                                            });
                                            if (_bookmark) {
                                              setState(() {
                                                _bookmark = false;
                                              });
                                            }
                                          }
                                      ),
                                      SizedBox(width: _uiCriteria.screenWidth * 0.032),
                                    ]
                                )
                            );
                          },
                        )
                    ),
                    _recentSearch
                        ? _recentSearchList(context)
                        : _bookmarkList(context)

                  ]
                  ),
                ),
              ),
          ),
    );
  }

  bool _isSearchBarNotEmpty;
  bool _isContains;
  bool _recentSearch;
  bool _bookmark;

  @override
  void initState() {
    super.initState();
    _isSearchBarNotEmpty = false;
    _isContains = false;
    _autoTileList = [];
    _recentSearch = true;
    _bookmark = false;
  }

  ///자동완성 리스트를 서버로부터 가져옴
  Future<List<dynamic>> _getAutoWordList(String word) async {
    var url = Uri.parse("$speckUrl/auto/complete");
    SharedPreferences sp = await SharedPreferences.getInstance();
    // Map<String, String> header = {
    //   "member-token" : "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkeWR0bjM1MTBAbmF2ZXIuY29tIiwiZXhwIjoxNjMxODIxMDY3fQ.Q7z0m0Sp45If8CNfcbJsGTUL1Xh6jnH3qlZDIjK2cVw",
    //   "member-email" : "dydtn3510@naver.com"
    // };
    String body = """{
      "word" : "$word"
    }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var utf = utf8.decode(response.bodyBytes);
    List<dynamic> result = jsonDecode(utf)["words"];
    print("result: $result");
    return Future(() {
      return result;
    });
  }

  Widget _recentSearchList(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 375/36.8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("최근 검색어",
                        style: TextStyle(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w500,
                          color: greyAAAAAA,
                          fontSize: _uiCriteria.textSize3,
                        )),
                    InkWell(
                      child: Text("전체 삭제",
                          style: TextStyle(
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                            color: greyAAAAAA,
                            fontSize: _uiCriteria.textSize3,
                          )),
                      onTap: () async {
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        postWordList.clear();
                        setState(() {
                          postTileList.clear();
                        });
                        await sp.setStringList("mapPostWordList", postWordList);
                      },
                    )
                  ]),
            ),
          ),
          Container(
              width: _uiCriteria.screenWidth,
              height: 0.5,
              color: greyD8D8D8.withOpacity(0.5)
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: postTileList.length,
              itemBuilder: (BuildContext context, int index) {
                return postTileList[postTileList.length - (index + 1)];
              },
            ),
          ),
        ]
      ),
    );
  }

  Widget _bookmarkList(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 375/36.8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("즐겨찾기",
                        style: TextStyle(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w500,
                          color: greyAAAAAA,
                          fontSize: _uiCriteria.textSize3,
                        )),
                    InkWell(
                      child: Text("전체 삭제",
                          style: TextStyle(
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                            color: greyAAAAAA,
                            fontSize: _uiCriteria.textSize3,
                          )),
                      onTap: () {
                      },
                    )
                  ]),
            ),
          ),
          Container(
              width: _uiCriteria.screenWidth,
              height: 0.5,
              color: greyAAAAAA.withOpacity(0.5)
          ),
        ]
      ),
    );
  }

  void _initPostSearchList(BuildContext context) {
    if (postWordList != null) {
      postTileList = [];
      for (int i = 0; i < postWordList.length; i++) {
        postTileList.add(
            GestureDetector(
              onTap: () async {
                SearchingWordState searchingWordState = Provider.of<SearchingWordState>(context, listen: false);
                searchingWordState.setSearchingWord(postWordList[i]);
                Future future = _changeCoordinates(postWordList[i]);
                // 지도 페이지에 검색한 주소의 경위도 전달
                LatLng latLng;
                await future.then((value) => latLng = value, onError: (e) => print(e));
                Navigator.pop(context, latLng);
                // 검색어 목록 순서 재배열
                String temp = postWordList[i];
                postWordList.remove(postWordList[i]);
                postWordList.insert(postWordList.length, temp);
                SharedPreferences sp = await SharedPreferences.getInstance();
                await sp.setStringList("mapPostWordList", postWordList);
              },
              child: AspectRatio(
                aspectRatio: 375/36.8,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraint) {
                    return Container(
                      padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.034, right: _uiCriteria.horizontalPadding),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: greyD8D8D8.withOpacity(0.5), width: 0.5))
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(Icons.location_on, size: constraint.maxHeight * 0.4347,),
                                      SizedBox(width: _uiCriteria.screenWidth * 0.0339),
                                      Text(postWordList[i], style: TextStyle(
                                          letterSpacing: 0.54,
                                          fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                    ]
                                )
                            ),
                            GestureDetector(
                                child: Icon(Icons.close, size: constraint.maxHeight * 0.3533),
                                onTap: () async {
                                  int index = postWordList.indexOf(postWordList[i]);
                                  setState(() {
                                    postTileList.removeAt(index);
                                  });
                                  postWordList.remove(postWordList[i]);
                                  SharedPreferences sp = await SharedPreferences.getInstance();
                                  await sp.setStringList("mapPostWordList", postWordList);
                                }
                            ),
                          ]
                      ),
                    );
                  },
                ),
              ),
            )
        );
      }
    }
    else {
      postTileList = [];
    }
  }
  /// 최근 검색 리스트에 추가
 void addPostWord(String word) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (postWordList.contains(word)) {
      SearchingWordState searchingWordState = Provider.of<SearchingWordState>(context, listen: false);
      searchingWordState.setSearchingWord(word);
      Future future = _changeCoordinates(word);
      // 지도 페이지에 검색한 주소의 경위도 전달
      LatLng latLng;
      await future.then((value) => latLng = value, onError: (e) => print(e));
      Navigator.pop(context, latLng);
      // 검색어 목록 순서 재배열
      String temp = word;
      postWordList.remove(word);
      postWordList.insert(postWordList.length, temp);
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setStringList("mapPostWordList", postWordList);
    }
    else {
      // 검색 리스트에 검색어 추가
      postWordList.add(word);
      postTileList.add(
          GestureDetector(
            onTap: () async {
              SearchingWordState searchingWordState = Provider.of<SearchingWordState>(context, listen: false);
              searchingWordState.setSearchingWord(word);
              Future future = _changeCoordinates(word);
              // 지도 페이지에 검색한 주소의 경위도 전달
              LatLng latLng;
              await future.then((value) => latLng = value, onError: (e) => print(e));
              Navigator.pop(context, latLng);
              // 검색어 목록 순서 재배열
              postWordList.remove(word);
              postWordList.insert(postWordList.length, word);
              SharedPreferences sp = await SharedPreferences.getInstance();
              await sp.setStringList("mapPostWordList", postWordList);
            },
            child: AspectRatio(
              aspectRatio: 375/36.8,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return  Container(
                    padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.034, right: _uiCriteria.horizontalPadding),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyAAAAAA.withOpacity(0.5), width: 0.5))
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.location_on, size: constraint.maxHeight * 0.4347,),
                                    SizedBox(width: _uiCriteria.screenWidth * 0.0339),
                                    Text(word, style: TextStyle(
                                        letterSpacing: 0.54,
                                        fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),),
                                  ]
                              )
                          ),
                          GestureDetector(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.transparent)
                                  ),
                                  child: Icon(Icons.close, size: constraint.maxHeight * 0.3533)),
                              onTap: () async {
                                int index = postWordList.indexOf(word);
                                setState(() {
                                  postTileList.removeAt(index);
                                });
                                postWordList.remove(word);
                                await sp.setStringList("mapPostWordList", postWordList);
                              }
                          ),
                        ]
                    ),
                  );
                },
              ),
            ),
          )
      );
      // SharedPreferences에 검색 리스트 저장
      await sp.setStringList("mapPostWordList", postWordList);
      SearchingWordState searchingWordState = Provider.of<SearchingWordState>(context, listen: false);
      searchingWordState.setSearchingWord(word);
      Future future = _changeCoordinates(word);
      // 지도 페이지에 검색한 주소의 경위도 전달
      LatLng latLng;
      await future.then((value) => latLng = value, onError: (e) => print(e));
      Navigator.pop(context, latLng);
      setState((){});
    }
  }

  /// 검색 내용을 경위도로 바꿔 return
  Future<LatLng> _changeCoordinates(String query) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    print(addresses);
    var first = addresses.first;
    return Future(() {
      return LatLng(first.coordinates.latitude, first.coordinates.longitude);
    });
  }

  List<String> _getContainedWord(String value) {
    // 검색어를 포함하는 리스트 생성
    List<String> contain = [];
    for (int i = 0; i < _autoWordList.length; i++) {
      if (_autoWordList[i].contains(value)) {
        contain.add(_autoWordList[i]);
        setState(() {
          _isContains = true;
        });
      }
    }
    print(_isContains);
    return contain;
  }

  List<Widget> _createAutoTileList(List<dynamic> list) {
    List<Widget> examList = [];
    // 포함하는 문자열 리스트 기반으로 자동완성 위젯 생성
    for (int i = 0; i < list.length; i++) {
      examList.add(
          GestureDetector(
            onTap: () async {
              SearchingWordState searchingWordState = Provider.of<SearchingWordState>(context, listen: false);
              searchingWordState.setSearchingWord(list[i]);
              Future future = _changeCoordinates(list[i]);
              // 지도 페이지에 검색한 주소의 경위도 전달
              LatLng latLng;
              await future.then((value) => latLng = value, onError: (e) => print(e));
              Navigator.pop(context, latLng);
              // 검색어 목록 순서 재배열
              postWordList.remove(list[i]);
              postWordList.insert(postWordList.length, list[i]);
              SharedPreferences sp = await SharedPreferences.getInstance();
              await sp.setStringList("mapPostWordList", postWordList);
            },
            child: AspectRatio(
              aspectRatio: 375/36.8,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return Container(
                    padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.034, right: _uiCriteria.horizontalPadding),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyAAAAAA.withOpacity(0.5), width: 0.5))
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.location_on, size: constraint.maxHeight * 0.4347,),
                          SizedBox(width: _uiCriteria.screenWidth * 0.0339),
                          Text("${list[i]}", style: TextStyle(
                              letterSpacing: 0.54,
                              fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500),)
                        ]
                    ),
                  );
                }
              ),
            ),
          )
      );
    }
    print(examList.length);
    return examList;
  }
}
