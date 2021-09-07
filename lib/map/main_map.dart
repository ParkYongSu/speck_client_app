import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speck_app/Map/place_photoview.dart';
import 'package:speck_app/Map/search_page.dart';
import 'package:speck_app/State/banner_state.dart';
import 'package:speck_app/State/recommend_state.dart';
import 'package:speck_app/State/searching_word_state.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/route/route_builder.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speck_app/util/util.dart';

class MainMap extends StatefulWidget {
  @override
  MainMapState createState() => MainMapState();
}

class MainMapState extends State<MainMap> {
  final UICriteria _uiCriteria = new UICriteria();
  CardTime _cardTime;
  RecommendBannerState _rbs;
  BannerState _bs;

  @override
  Widget build(BuildContext context) {
    _rbs = Provider.of<RecommendBannerState>(context, listen: false);
    _bs = Provider.of<BannerState>(context, listen: false);
    _uiCriteria.init(context);
    _cardTime = Provider.of<CardTime>(context, listen: false);
    // FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    List<Widget> _zoneList = [
      GestureDetector(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0186),
          decoration: BoxDecoration(
              color: (_commonClicked)?mainColor:Colors.white,
              border: (_commonClicked)?Border.all(color: greyD8D8D8, width: 0.5): Border.all(color: Colors.transparent),
              borderRadius:
              BorderRadius.all(Radius.circular(3.5))),
          child: AutoSizeText("일반 카페",
              maxLines: 1,
              style: TextStyle(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: (_commonClicked)?Colors.white:mainColor,
                  fontSize: _uiCriteria.textSize5
              )),
        ),
        onTap: (_commonClicked)?
            () {
          setState(() {
            var newSet = Set.from(_markers);
            List<Marker> newList = [];
            for (int i = 0; i < _tempMarkers.length; i++) {
              String type = _tempMarkers[i].markerId.substring(0, 1);
              if (type == "N") {
                // _commonCafeList.add(_tempMarkers[i]);
                newList.add(_tempMarkers[i]);
              }
            }
            newSet.addAll(Set.from(newList));
            _markers = List.from(newSet);
            _commonClicked = false;
          });
        }
            : () {
          setState(() {
            var markerSet = Set.from(_markers);
            List<Marker> newList = [];
            for (int i = 0; i < _tempMarkers.length; i++) {
              String type = _tempMarkers[i].markerId.substring(0, 1);
              if (type == "N") {
                // _commonCafeList.add(_tempMarkers[i]);
                newList.add(_tempMarkers[i]);
              }
            }
            _markers = List.from(markerSet.difference(Set.from(newList)));
            _commonClicked = true;
          });
        },
      ),
      SizedBox(
        width: _uiCriteria.screenWidth * 0.032,
      ),
      GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0186),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: (_studyClicked)
              ? mainColor
              : Colors.white,
              border: (_studyClicked)?Border.all(color: greyD8D8D8, width: 0.5): Border.all(color: Colors.transparent),
              borderRadius:
              BorderRadius.all(Radius.circular(3.5))),
          child: AutoSizeText("스터디 카페",
              maxLines: 1,
              style: TextStyle(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: (_studyClicked)? Colors.white : mainColor,
                  fontSize: _uiCriteria.textSize5
              )),
        ),
        onTap: (_studyClicked)?
            () {
              setState(() {
                var newSet = Set.from(_markers);
                List<Marker> newList = [];
                for (int i = 0; i < _tempMarkers.length; i++) {
                  String type = _tempMarkers[i].markerId.substring(0, 1);
                  if (type == "S") {
                    // _commonCafeList.add(_tempMarkers[i]);
                    newList.add(_tempMarkers[i]);
                  }
                }
                newSet.addAll(Set.from(newList));
                _markers = List.from(newSet);
                _studyClicked = false;
              });
        }
            :() {
          setState(() {
            var newSet = Set.from(_markers);
            List<Marker> newList = [];
            for (int i = 0; i < _tempMarkers.length; i++) {
              String type = _tempMarkers[i].markerId.substring(0, 1);
              if (type == "S") {
                // _commonCafeList.add(_tempMarkers[i]);
                newList.add(_tempMarkers[i]);
              }
            }
            _markers = List.from(newSet.difference(Set.from(newList)));
            _studyClicked = true;
          });
        },
      ),
      SizedBox(
        width: _uiCriteria.screenWidth * 0.032,
      ),
      GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0186),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: (_readingRoomClicked)
              ? mainColor
              : Colors.white,
              border: (_readingRoomClicked)?Border.all(color: greyD8D8D8, width: 0.5): Border.all(color: Colors.transparent),
              borderRadius:
              BorderRadius.all(Radius.circular(3.5))),

          child: AutoSizeText("독서실",
              maxLines: 1,
              style: TextStyle(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: (_readingRoomClicked)?Colors.white:mainColor,
                  fontSize: _uiCriteria.textSize5
              )),
        ),
        onTap: (_readingRoomClicked)?
            () {
          setState(() {
            var newSet = Set.from(_markers);
            List<Marker> newList = [];
            for (int i = 0; i < _tempMarkers.length; i++) {
              String type = _tempMarkers[i].markerId.substring(0, 1);
              if (type == "R") {
                // _commonCafeList.add(_tempMarkers[i]);
                newList.add(_tempMarkers[i]);
              }
            }
            newSet.addAll(Set.from(newList));
            _markers = List.from(newSet);
            _readingRoomClicked = false;
          });
        }
            :() {
          setState(() {
            setState(() {
              var newSet = Set.from(_markers);
              List<Marker> newList = [];
              for (int i = 0; i < _tempMarkers.length; i++) {
                String type = _tempMarkers[i].markerId.substring(0, 1);
                if (type == "R") {
                  // _commonCafeList.add(_tempMarkers[i]);
                  newList.add(_tempMarkers[i]);
                }
              }
              _markers = List.from(newSet.difference(Set.from(newList)));
              _readingRoomClicked = true;
            });
          });
        },
      ),
      SizedBox(
        width: _uiCriteria.screenWidth * 0.032,
      ),
      GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0186),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: (_libraryClicked)
              ? mainColor
              : Colors.white,
              border: (_libraryClicked)?Border.all(color: greyD8D8D8, width: 0.5): Border.all(color: Colors.transparent),
              borderRadius:
              BorderRadius.all(Radius.circular(3.5))),
          child: AutoSizeText("도서관",
              maxLines: 1,
              style: TextStyle(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: (_libraryClicked)?Colors.white:mainColor,
                  fontSize: _uiCriteria.textSize5
              )),
        ),
        onTap: (_libraryClicked)?
            () {
          setState(() {
            var newSet = Set.from(_markers);
            List<Marker> newList = [];
            for (int i = 0; i < _tempMarkers.length; i++) {
              String type = _tempMarkers[i].markerId.substring(0, 1);
              if (type == "L") {
                // _commonCafeList.add(_tempMarkers[i]);
                newList.add(_tempMarkers[i]);
              }
            }
            newSet.addAll(Set.from(newList));
            _markers = List.from(newSet);
            _libraryClicked = false;
          });
        }
            :() {
          setState(() {
            var newSet = Set.from(_markers);
            List<Marker> newList = [];
            for (int i = 0; i < _tempMarkers.length; i++) {
              String type = _tempMarkers[i].markerId.substring(0, 1);
              if (type == "L") {
                // _commonCafeList.add(_tempMarkers[i]);
                newList.add(_tempMarkers[i]);
              }
            }
            _markers = List.from(newSet.difference(Set.from(newList)));
            _libraryClicked = true;
          });
        },
      )
    ];


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "스펙존 지도",
      home: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                toolbarHeight: _uiCriteria.appBarHeight,
                elevation: 0,
                centerTitle: true,
                titleSpacing: 0,
                backwardsCompatibility: false,
                // brightness: Brightness.dark,
                systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: mainColor, statusBarBrightness: Brightness.dark),
                title: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: _uiCriteria.screenWidth * 0.008, right: _uiCriteria.horizontalPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.transparent),
                                  ),
                                  child: Icon(Icons.chevron_left_rounded,
                                      color: Colors.white, size: _uiCriteria.screenWidth * 0.1),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                }),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Icon(Icons.search, color: Colors.white, size: _uiCriteria.screenWidth * 0.07,),
                              // child: Image.asset("assets/png/search.png", height: _uiCriteria.textSize4,),
                              onTap: () async {
                                Navigator.of(context).push(createRoute2(SearchPage()))
                                    .then((value) { if (value != null) {
                                  placeLatLng = value;
                                  print("카메라 이동");
                                  _moveCamera(value);
                                }
                                });
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) => SearchPage()))
                                //     .then((value) {
                                //   if (value != null) {
                                //     placeLatLng = value;
                                //     print("카메라 이동");
                                //     _moveCamera(value);
                                //   }
                                // });
                              },
                            )
                          ],
                        ),
                      ),
                      Consumer<SearchingWordState> (
                        builder: (context, searchingWordState, child) {
                          return Text(
                            "${searchingWordState.getSearchingWord()}",
                            style: TextStyle(
                                letterSpacing: 0.8,
                                fontSize: _uiCriteria.textSize16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          );
                        },
                      ),
                    ]
                ),
                backgroundColor: mainColor,
              ),
              body: Stack(children: <Widget>[
                FutureBuilder(
                  future: _getCurrentLocation().whenComplete(() {
                    _showRecommendBanner("희망 스펙존 추천", "카페, 도서관, 독서실, 스터디카페 등", "집밖 학습공간", "ex) 서울 - 스펙카페 강남점");
                  }),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      _currentLocation = snapshot.data;
                      return _nm = NaverMap(
                        onMapTap: (LatLng latLag) {
                          if (_markerClicked) {
                            setState(() {
                              _markerClicked = false;
                            });
                          }
                        },
                        initLocationTrackingMode: LocationTrackingMode.Follow,
                        locationButtonEnable: true,
                        initialCameraPosition: CameraPosition(
                            target: snapshot.data, zoom: 17),
                        onMapCreated: _onMapCreated,
                        markers: _markers,
                      );
                    }
                    else {
                      return Container(
                        // decoration: BoxDecoration(
                        //   border: Border(top: BorderSide(color: Colors.black, width: 0.5)),
                        // ),
                          width: _uiCriteria.screenWidth * 0.065,
                          height: _uiCriteria.screenWidth * 0.065,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                mainColor),
                          )
                      );
                    }
                  }
                ),
                AspectRatio(
                  aspectRatio: 375/43.8,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraint) {
                      return Container(
                          width: _uiCriteria.screenWidth,
                          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding, vertical: constraint.maxHeight * 0.25),
                          decoration: BoxDecoration(
                              color: mainColor,
                              border:
                              Border(top: BorderSide(color: greyD8D8D8, width: 0.5),)),
                          // child: ListView.builder(
                          //   // physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          //   scrollDirection: Axis.horizontal,
                          //   itemCount: _zoneList.length,
                          //   itemBuilder: (BuildContext context, int index) {
                          //     return _zoneList[index];
                          //   },
                          // )
                          /// 배너 없어지면 수정
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: _zoneList,
                              ),
                              GestureDetector(
                                child: Hero(
                                  tag: "hi",
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.0186),
                                    decoration: BoxDecoration(
                                      color: greyB3B3BC,
                                      borderRadius: BorderRadius.circular(3.5),

                                    ),
                                    child: AutoSizeText("추천", maxLines: 1,style: TextStyle(fontSize: _uiCriteria.textSize5, letterSpacing: 0.5, color: Colors.white, fontWeight: FontWeight.bold),),
                                  ),
                                ),
                                onTap: () {
                                  _showDialog("희망 스펙존 추천", "카페, 도서관, 독서실, 스터디카페 등", "집밖 학습공간", "ex) 서울 - 스펙카페 강남점");
                                },
                              )
                            ],
                          ),
                      );
                    },
                  ),
                ),
                (_markerClicked)
                ?Align(
                  alignment: Alignment.bottomCenter,
                  child: _placeInfo())
                : Container(),
                (_markerClicked && _imagePath.isNotEmpty)
                ? Align(
                  alignment: Alignment.bottomRight,
                  child: AspectRatio(
                        aspectRatio: 375/315,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 375/63,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                                child: AspectRatio(
                                  aspectRatio: 1/1,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => PlacePhotoView(imagePath: _imagePath, placeName: _placeName, count: _count,)));
                                    },
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraint) {
                                          return Container(
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(3.5)
                                            ),
                                            child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                Image.network(
                                                  _imagePath[0],
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent ice) {
                                                    if (ice == null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      alignment: Alignment.center,
                                                      width: constraint.maxHeight,
                                                      height: constraint.maxHeight,
                                                      child: Container(
                                                        height: constraint.maxWidth * 0.06122,
                                                        width: constraint.maxWidth * 0.06122,
                                                        child: CircularProgressIndicator(
                                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF404040)),
                                                        ),
                                                      ),
                                                    );
                                                    }
                                                  ,),
                                                Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Color(0XFF404040).withOpacity(0.5)
                                                  ),
                                                  height: constraint.maxWidth * 0.06122,
                                                  width: constraint.maxWidth * 0.06122,
                                                  child: Text("$_count", style: TextStyle(fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, color: Colors.white),),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),

                                    ),
                                  )
                                ),
                              ),
                            ),
                            AspectRatio(aspectRatio: 375/252)
                          ]
                        ),
                      ),
                )
                : Container()
              ])),
    );
  }

  NaverMap _nm;
  // 마커를 담을 리스트 생성
  List<Marker> _markers;
  List<Marker> _tempMarkers;
  // 초기 지도 위치
  // 검색 후 카메라가 이동할 위치
  LatLng placeLatLng;
  Completer<NaverMapController> nmController = new Completer();
  double _clickedLat;
  double _clickedLng;
  String _clickedName;
  // 클릭한 장소 이미지 저장
  var _clickedPlaceImg;
  bool _markerClicked;
  bool _commonClicked;
  bool _studyClicked;
  bool _readingRoomClicked;
  bool _libraryClicked;
  DateTime _open;
  DateTime _close;
  String _placeName;
  String _zoneType;
  String _doroName;
  String _phoneNumber;
  List<String> _imagePath;
  List<Marker> _newList = <Marker>[];
  List<Marker> _commonCafeList = <Marker>[];
  List<Marker> _studyCafeList = <Marker>[];
  List<Marker> _libraryList = <Marker>[];
  List<Marker> _readingRoomList = <Marker>[];
  int _count;
  String _assetName;
  LatLng _currentLocation;
  int _todayVisitor;
  int _accVisitor;
  String _placeCode;
  String _monday;
  String _tuesday;
  String _wednesday;
  String _thursday;
  String _friday;
  String _saturday;
  String _sunday;
  ValueNotifier<bool> _recommendIsNotEmpty;
  final TextEditingController _mapRecommendController = new TextEditingController();
  @override
  void initState() {
    super.initState();

    _markers = <Marker>[];
    _tempMarkers = <Marker>[];
    _placeName = "";
    _doroName = "";
    _zoneType = "";
    _phoneNumber = "";
    _markerClicked = false;
    _commonClicked = false;
    _studyClicked = false;
    _readingRoomClicked =false;
    _libraryClicked = false;
    _count = 0;
    _assetName = "";
    _recommendIsNotEmpty = ValueNotifier<bool>(false);
  }


  @override
  void dispose() {
    super.dispose();
    if (_cardTime.seconds != null) {
      _cardTime.startTimer();
    }
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 사용가능한지 체
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // 위치 서비스 이용 불가능하면 위치 데이터 못받아옴
    if (!serviceEnabled) {
      print(1);
      return Future.error('Location services are disabled.');
    }

    // 위치 권한 허용 안했으면 못받

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    LatLng cLocation = new LatLng(position.latitude, position.longitude);
    return cLocation;
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition();

  }

  void _onMapCreated(NaverMapController controller) async {
    if (nmController.isCompleted) {
      nmController = Completer();
    }
    nmController.complete(controller);
    _getPlaceInfo();
   }

   // 스펙존 정보 패널
   Widget _placeInfo() {
    return BottomSheet(
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0))
        ),
        onDragStart: null,
        onDragEnd: null,
        onClosing: () {
          setState(() {
            _markerClicked = false;
          });
        },
        builder: (BuildContext context) {
          return AspectRatio(
            aspectRatio: 375/242,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: greyD8D8D8
                        ),
                        margin: EdgeInsets.only(top: constraint.maxHeight * 0.058),
                        width: constraint.maxWidth * (78 / 375),
                        height: 4,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: constraint.maxHeight * 0.095),
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                                children: <Widget>[
                                  Text(
                                    "$_placeName ",
                                    style: TextStyle(
                                        letterSpacing: 0.9,
                                        color: mainColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize:  _uiCriteria.textSize4),
                                  ),
                                  Text(
                                    "$_zoneType",
                                    style: TextStyle(
                                        letterSpacing: 0.6,
                                        color: greyAAAAAA,
                                        fontWeight: FontWeight.w700,
                                        fontSize: _uiCriteria.textSize3),
                                  ),
                                ]
                            ),
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Icon(Icons.star_border, color:greyB3B3BC),)
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: constraint.maxHeight * 0.049),
                        width: _uiCriteria.screenWidth,
                        height: 0.5,
                        color: greyD8D8D8.withOpacity(0.5),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: constraint.maxHeight * 0.0446,),
                                  Row(
                                    children: [
                                      Text(
                                        "매장정보",
                                        style: TextStyle(
                                            color: mainColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: _uiCriteria.textSize3,
                                            letterSpacing: 0.6
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_right, color: Colors.transparent, size: _uiCriteria.textSize16)
                                    ],
                                  ),
                                  SizedBox(
                                    height: constraint.maxHeight * 0.0413,
                                  ),
                                  AutoSizeText(
                                    "$_doroName",
                                    maxLines: 2,

                                    // overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: mainColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: _uiCriteria.textSize3,
                                        letterSpacing: -0.36
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: constraint.maxWidth * 0.032),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: constraint.maxHeight * 0.0446,),
                                  GestureDetector(
                                    onTap: () => _showOperTime(),
                                    child: Row(
                                        children: <Widget>[
                                          Text(
                                            "영업시간",
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: _uiCriteria.textSize3,
                                                letterSpacing: 0.6
                                            ),
                                          ),
                                          Icon(Icons.keyboard_arrow_right, color: greyD8D8D8, size: _uiCriteria.textSize16)
                                        ]
                                    )
                                  ),
                                  SizedBox(
                                    height: constraint.maxHeight * 0.0413,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text("방문자수", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6),),
                                      Text("   $_accVisitor명", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3, letterSpacing: -0.86))
                                    ],),
                                  SizedBox(
                                    height: constraint.maxHeight * 0.0413,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text("행성코드", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize3, letterSpacing: 0.6),),
                                      Text("   $_placeCode", style: TextStyle(color: mainColor, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize3, letterSpacing: -0.86))
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: constraint.maxHeight * 0.0950,
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: _uiCriteria.horizontalPadding),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3.5)
                                    ),
                                    height: constraint.maxHeight * 0.161,
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3.5)
                                      ),
                                      color: mainColor,
                                      elevation: 0,
                                      onPressed: () {
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) => CupertinoActionSheet(
                                              actions: [
                                                CupertinoActionSheetAction(
                                                  child: Text("네이버 지도", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w500),),
                                                  onPressed: () {
                                                    _naverFindRoute(_currentLocation);
                                                    // _nMapInstalled();
                                                  },
                                                ),
                                              ],
                                              cancelButton: CupertinoActionSheetAction(
                                                child: Text("취소", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize4,  fontWeight: FontWeight.w700),),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ));
                                      },
                                      child: Text(
                                        "길찾기",
                                        style: TextStyle(
                                            fontSize: _uiCriteria.textSize3,
                                            letterSpacing: 0.6,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
                              ),
                              SizedBox(width: constraint.maxWidth * 0.032),
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3.5)
                                    ),
                                    height: constraint.maxHeight * 0.161,
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3.5)
                                      ),
                                      elevation: 0,
                                      color: greyD8D8D8,
                                      onPressed: () {},
                                      child: Text(
                                        "쿠폰보기(준비중)",
                                        style: TextStyle(
                                            fontSize: _uiCriteria.textSize3,
                                            letterSpacing: 0.6,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
                              ),
                            ],
                          )
                      )
                      ]);
              },
            )
          );
        });
   }

   void _setPlaceInfo(String placeName, String zoneType, String doroName, String phoneNumber, List<String> imagePath, int count, int todayVisitor, int accVisitor,String placeCode,
     String monday, String tuesday, String wednesday, String thursday, String friday, String saturday, String sunday) {
      setState(() {
        this._placeName = placeName;
        this._zoneType = zoneType;
        this._doroName = doroName;
        this._phoneNumber = phoneNumber;
        this._imagePath = imagePath;
        this._count = count;
        this._todayVisitor = todayVisitor;
        this._accVisitor = accVisitor;
        this._placeCode = placeCode;
        this._monday = monday;
        this._tuesday = tuesday;
        this._wednesday = wednesday;
        this._thursday = thursday;
        this._friday = friday;
        this._saturday = saturday;
        this._sunday = sunday;
      });
   }

   /// todo. url 변경
  _getPlaceInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    print("장소 정보 가져오기");
    String email = sp.getString("email");
    // var url = Uri.parse("$speckUrl/map");
    var url = Uri.parse("$speckUrl/map");
    String body = '''{
      "email" : "$email"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    var decodeData = utf8.decode(response.bodyBytes);
    List<dynamic> result = jsonDecode(decodeData);
    print("result $result");
    if (result != null) {
      for (int i = 0; i < result.length; i++) {
        String zoneType;
        // 코드의 첫번째 문자에 따라 타입과 마설정
        switch (result[i]["code"].substring(0,1)) {
          case "N":
            setState(() {
              zoneType = "일반카페";
              _assetName = "assets/png/marker_normalcafe.png";
            });
            break;
          case "S":
            setState(() {
              zoneType = "스터디카페";
              _assetName = "assets/png/marker_studycafe.png";
            });
            break;
          case "R":
            setState(() {
              zoneType = "독서실";
              _assetName = "assets/png/marker_readingroom.png";
            });
            break;
          case "L":
            setState(() {
              zoneType = "도서관";
              _assetName = "assets/png/marker_lib.png";
            });
            break;
        }
        // 이미지 경로를 저장할 변수 선언
        List<String> imagePath = [];
        int count = 0;
        if (result[i]["placeImage"] != null) {
          for (int j = 0; j < result[i]["placeImage"].length; j++) {
            if (result[i]["placeImage"][j]["imagePath"] != null) {
              count++;
              imagePath.add(result[i]["placeImage"][j]["imagePath"]);
            }
          }
        }

        int todayVisitor = result[i]["todayVisitor"];
        int accVisitor = result[i]["num"];
        String placeCode = result[i]["code"];
        dynamic operationTime = result[i]["operationTime"];
        String monday = operationTime["monday"];
        String tuesday = operationTime["tuesday"];
        String wednesday = operationTime["wednesday"];
        String thursday = operationTime["thursday"];
        String friday = operationTime["friday"];
        String saturday = operationTime["saturday"];
        String sunday = operationTime["sunday"];

        await OverlayImage.fromAssetImage(assetName: _assetName, context: context)
            .then((image) {
          _markers.add(new Marker(
              captionText: result[i]["name"],
              captionTextSize: _uiCriteria.textSize5,
              iconTintColor: mainColor,
              icon: image,
              width: (_uiCriteria.screenWidth * 0.0928).toInt(),
              height: (_uiCriteria.screenWidth * 0.1234).toInt(),
              markerId: result[i]["code"],
              position: new LatLng(result[i]["lat"], result[i]["lng"]),
              onMarkerTab: (Marker marker, Map<String, int> map) {
                // 마커를 클릭하면 해당 데이터를 세팅함
                _setPlaceInfo(result[i]["name"], zoneType, result[i]["doroName"], result[i]["phoneNumber"], imagePath, count, todayVisitor, accVisitor,placeCode,
                monday, tuesday, wednesday, thursday, friday, saturday, sunday);
                setState(() {
                  _markerClicked = true;
                });
                _clickedLat = marker.position.latitude;
                _clickedLng = marker.position.longitude;
                _clickedName = result[i]["name"];
              }));
        });
        // todo.이미지 설정
      }
    }
    _tempMarkers = _markers;
  }

  /// 일단 안드로이드만
  /// 현위치에서 선택한 공간까지의 도보 길찾기 서비스

  // 네이버 길찾기
  void _naverFindRoute(LatLng latLng) async {
    String start;
    String end;
    // await Geocoder.local.findAddressesFromCoordinates(new Coordinates(latLng.latitude, latLng.longitude)).then((value) {print(value.first.featureName);start = Uri.encodeFull("${value.firs.featureName}");});
    start = Uri.encodeFull("현위치");
    end = Uri.encodeFull(_clickedName);
    String package; // 스토어 패키지
    String urlScheme; // 네이버 지도와 통신하기 위한 url scheme
    bool isInstalled; // 설치 여부 저장할 변수

    if (Platform.isAndroid) {
      print("플랫폼 안드로이드");
      package = "https://play.google.com/store/apps/details?id=com.nhn.android.nmap&hl=ko&gl=US";
      urlScheme = "nmap://route/walk?slat=${latLng.latitude}&slng=${latLng.longitude}&sname=$start&dlat=$_clickedLat&dlng=$_clickedLng&dname=$end&appname=com.example.speck_app";
    }
    else if (Platform.isIOS){
      print("플랫폼 IOS");
      package = "http://itunes.apple.com/app/id311867728?mt=8";
      urlScheme = "nmap://route/walk?slat=${latLng.latitude}&slng=${latLng.longitude}&sname=$start&dlat=$_clickedLat&dlng=$_clickedLng&dname=$end&appname=com.example.speckApp";
    }

    await canLaunch(urlScheme)
        .then((value) => isInstalled = value)
        .onError((error, stackTrace) {
          print("설치 여부 확인에서 에러 발생: $error");
          return false;
    });

    print("설치여부 $isInstalled");
    // 설치 되었다면
    if (isInstalled) {
      print("설치됨 네이버 맵으로 이동");
      try {
        await launch(urlScheme);
      }
      catch (e) {
        print(e);
      }
    }
    // 안되었다면
    else {
      print("설치 안됨 스토어로 이동");
      try {
        await launch(package);
      }
      catch (e) {
        print(e);
      }
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _moveCamera(LatLng latLng) async {
    final controller = await nmController.future;
    print("카메라 이동0");
    controller.moveCamera(CameraUpdate.scrollTo(latLng));
    print("카메라 이동1");
  }


  void _showOperTime() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _operTime();
        });
  }

  Widget _operTime() {
    AlertDialog dialog = new AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.5)
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.1666),
      content: AspectRatio(
        aspectRatio: 250/202,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.5)
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: constraint.maxWidth,
                    height: constraint.maxHeight * 0.197,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                    ),
                    child: Text("영업시간", style: TextStyle(color: mainColor, fontWeight: FontWeight.w700, fontSize: _uiCriteria.textSize2, letterSpacing: 0.7),),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.048),
                      child: Column(
                        children: <Widget>[
                          Spacer(flex: 23,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Spacer(flex: 2,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("월  $_monday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                  SizedBox(height: constraint.maxHeight * 0.015,),
                                  Text("화  $_tuesday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                  SizedBox(height: constraint.maxHeight * 0.015,),
                                  Text("수  $_wednesday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                  SizedBox(height: constraint.maxHeight * 0.015,),
                                  Text("목  $_thursday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                ],
                              ),
                              Spacer(flex: 1,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("금  $_friday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                  SizedBox(height: constraint.maxHeight * 0.015,),
                                  Text("토  $_saturday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                  SizedBox(height: constraint.maxHeight * 0.015,),
                                  Text("일  $_sunday", style: TextStyle(color: mainColor, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: -0.36),),
                                ],
                              ),
                              Spacer(flex: 2,),
                            ],
                          ),
                          Spacer(flex: 23,),
                          AspectRatio(
                            aspectRatio: 226/39,
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.5)
                              ),
                              onPressed: () {launch("tel://$_phoneNumber");},
                              elevation: 0,
                              color: mainColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.call, color: Colors.white, size: _uiCriteria.textSize16,),
                                  SizedBox(width: constraint.maxWidth * 0.048,),
                                  Text("$_phoneNumber", style: TextStyle(color: Colors.white, fontSize: _uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),)
                                ]
                              ),
                            ),
                          ),
                          Spacer(flex: 12,),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        )
      ),
    );
    return dialog;
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
                                                  controller: _mapRecommendController,
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
            }));
  }

  void _showRecommendBanner(String title, String example, String category, String hint) {
    if (_bs.getMapStatus() == 1 && _rbs.getMapBannerState() == 1) {
      _showDialog(title, example, category, hint);
      _rbs.setMapBannerState(0);
    }
  }

  void _transferData(String type) async {
    String data;
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/home/insert/map");
    String body;
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response;
    int status;
    _showLoader();
    // 처음 띄워지는데 닫기 눌렀을 때
    if (_bs.getMapStatus() == 1 && type == "close") {

      body = '''{
      "first" : ${_bs.getMapStatus()},
      "userEmail" : "${sp.getString("email")}",
      "value" : null
      }''';
      response = await http.post(url,body: body, headers: header);
      status = int.parse(response.body);
      if (status == 100) {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.pop(context);
        }).whenComplete(() {
          Navigator.pop(context);
          _bs.setMapStatus(0);
        });
      }
    }
    // 그 다음부터 닫기 누를 때
    else if (type == "close") {
      Future.delayed(Duration(microseconds: 1500), () {
        Navigator.pop(context);
      }).whenComplete(() => Navigator.pop(context));
    }
    // 데이터 전송
    else if (type == "transfer") {
      data = _mapRecommendController.text;
      body = '''{
      "first" : ${_bs.getMapStatus()},
      "userEmail" : "${sp.getString("email")}",
      "value" : "$data"
      }''';
      response = await http.post(url,body: body, headers: header);
      status = int.parse(response.body);
      if (status == 100) {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.pop(context);
        }).whenComplete(() {
          errorToast("입력되었습니다.");
          Navigator.pop(context);
          _bs.setMapStatus(0);
        });
      }
      else {
        Future.delayed(Duration(microseconds: 1500), () {
          Navigator.pop(context);
        }).whenComplete(() => errorToast("다시 시도해주세요."));
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
