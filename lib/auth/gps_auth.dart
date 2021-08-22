import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speck_app/main.dart';
import 'package:speck_app/main/main_page.dart';
import 'package:speck_app/main/my/ticket/ticket_ui.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:http/http.dart' as http;
import 'package:speck_app/util/util.dart';

class GpsAuth extends StatefulWidget {
  @override
  _GpsAuthState createState() => _GpsAuthState();
}

class _GpsAuthState extends State<GpsAuth> with TickerProviderStateMixin, WidgetsBindingObserver {
  List<Marker> _markers = [];
  List<Position> _positions = [];
  List<CircleOverlay> _circles = [];
  LatLng _currentPosition;
  Completer<NaverMapController> nmController = new Completer();
  double _lat;
  double _lng;
  double _radius = 100;
  NaverMap _nm;
  StreamSubscription<Position> _positionSubscription;
  Timer _checkTimer;
  Timer _currentTimer;
  Timer _delayTimer;
  int _checkTime = 5;
  Color _circleColor = Color(0XFF2880eb).withOpacity(0.5);
  bool _isNoticeTapped = false;
  bool _isStarted = false;
  bool _isStartTapped = false;
  bool _noticeTextFloated = false;
  Widget _status = new Text("GPS 측정 시작", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700));

  AnimationController _manualController;
  Animation<Offset> _manualAnimation;
  AnimationController _noticeController;
  Animation<Offset> _noticeAnimation;
  String _placeName;
  int _attCount;
  int _totalCount;
  int _attRate;
  int _totalDeposit;
  int _myDeposit;
  int _totalDust;
  int _accumPrize;
  int _estimatePrize;
  String _attendTime;
  String _galaxyName;
  int _timeNum;
  int _mannerTime;
  String _assetName = "";
  LocationTrackingMode _locationTrackingMode;
  int _noticeMark = 0;

  @override
  void initState() {
    super.initState();
    _setPermission();
    _manualController = AnimationController(
      // duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true, period: Duration(milliseconds: 1000)).timeout(Duration(seconds: 6),onTimeout: () {
      if (_manualController.isAnimating) {
        setState(() {
          _isStartTapped = true;
        });
        _manualController.dispose();
      }
    });
    _manualAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.03),
    ).animate(CurvedAnimation(
      parent: _manualController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    if (_positionSubscription != null && _positionSubscription.isPaused) {
      _positionSubscription.cancel();
    }

    if (_checkTimer != null && _checkTimer.isActive) {
      _checkTimer.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: Scaffold(
        appBar: _appBar(context),
        body: FutureBuilder(
          future: _getCurrentPosition(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _currentPosition = snapshot.data;
              return Stack(
                alignment: Alignment.center,
                children: [
                  _nm = new NaverMap(
                    markers: _markers,
                    circles: _circles,
                    locationButtonEnable: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(zoom: 15, target: _currentPosition),
                    initLocationTrackingMode: _locationTrackingMode,
                    useSurface: true,
                  ),
                  (_isStartTapped)
                  ? Container()
                  : _manualText(),
                  (_noticeTextFloated)
                  ? _noticeText()
                  : Container(),
                  (_isNoticeTapped)
                  ? _notice()
                  : Container(),
                  _mapElement(),
                ],
              );
            }
            else {
              return loader(context, 0);
            }
          },
        ),
      ),
    );
  }

  Widget _manualText() {
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: _manualAnimation,
        child: Container(
          margin: EdgeInsets.only(top: uiCriteria.totalHeight * 0.34),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 0, offset: Offset(-4, 0))]
          ),
          child: Text("시작을 누르고 집 밖으로 이동해주세요", style: TextStyle(fontSize: uiCriteria.textSize1, fontWeight: FontWeight.bold, color: mainColor, letterSpacing: 0.8),),
        ),
      ),
    );
  }

  Widget _noticeText() {
    if (_noticeMark == 0) {
      _noticeController = AnimationController(
        // duration: const Duration(seconds: 1),
        vsync: this,
      )..repeat(reverse: true, period: Duration(milliseconds: 1000)).timeout(Duration(seconds: 6),onTimeout: () {
        if (_noticeController.isAnimating) {
          setState(() {
            _noticeTextFloated = false;
          });
          _noticeController.dispose();
        }
      });
      _noticeAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, 0.03),
      ).animate(CurvedAnimation(
        parent: _noticeController,
        curve: Curves.elasticIn,
      ));
    }
    _noticeMark = 1;
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: _noticeAnimation,
        child: Container(
          margin: EdgeInsets.only(top: uiCriteria.totalHeight * 0.34),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 0, offset: Offset(-4, 0))]
          ),
          child: Text("왼쪽 하단의 내 위치 버튼을 활성화해주세요", style: TextStyle(fontSize: uiCriteria.textSize1, fontWeight: FontWeight.bold, color: mainColor, letterSpacing: 0.8),),
        ),
      ),
    );
  }



  Widget _appBar(BuildContext context) {
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
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              width: uiCriteria.screenWidth,
              child: Text("GPS 출석 인증", style: TextStyle(letterSpacing: 0.8, color: Colors.white, fontWeight: FontWeight.w700, fontSize: uiCriteria.textSize1),)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Icon(Icons.chevron_left_rounded,
                        color: Colors.white, size: uiCriteria.screenWidth * 0.1),
                  ),
                  onTap: (_isStarted)
                    ? () {
                    if (_currentTimer != null) {
                      _currentTimer.cancel();
                      _delayTimer.cancel();
                    }

                    if (_positionSubscription != null) {
                      _positionSubscription.pause();
                    }

                    if (_checkTimer != null) {
                      _checkTimer.cancel();
                    }
                      _showExitDialog();
                    }
                    : () {
                    Navigator.pop(context);
                    if (_manualController.isAnimating) {
                      _manualController.dispose();
                    }

                    if (_noticeController != null && _noticeController.isAnimating) {
                      _noticeController.dispose();
                    }
                  }),
              Padding(
                padding: EdgeInsets.only(right: uiCriteria.horizontalPadding),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isNoticeTapped = !_isNoticeTapped;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Text("유의사항 ", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                      Container(
                        padding: EdgeInsets.all(uiCriteria.screenWidth * 0.011),
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle
                        ),
                        child: Text("?", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _notice() {
    return Padding(
      padding: EdgeInsets.only(top: uiCriteria.totalHeight * 0.015),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
          child: SpeechBubble(
            borderRadius: 3.5,
            color: mainColor,
            nipLocation: NipLocation.TOP_RIGHT,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: uiCriteria.screenWidth * 0.01,
                  vertical: uiCriteria.screenWidth * 0.011),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("유의사항", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),),
                      SizedBox(height: uiCriteria.totalHeight * 0.0114,),
                      Text("1. 앱 종료 시엔 측정이 초기화되니 유의 부탁드립니다.", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                      SizedBox(height: uiCriteria.totalHeight * 0.0045,),
                      Text("2. 시작 시 현 위치를 중심으로 반경 100m의 원이 생깁니다.", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                      SizedBox(height: uiCriteria.totalHeight * 0.0045,),
                      Text("3. 100m 반경 밖에서 5초가 지나면 출석이 인증됩니다.", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w500, letterSpacing: 0.6),),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapElement() {
    return Padding(
      padding: EdgeInsets.only(bottom: uiCriteria.totalHeight * 0.0394),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: uiCriteria.totalHeight * 0.0061),
              child: GestureDetector(
                  onTap: () {
                    if (_currentTimer != null) {
                      _currentTimer.cancel();
                      _delayTimer.cancel();
                    }

                    if (_positionSubscription != null) {
                      _positionSubscription.cancel();
                    }

                    if (_checkTimer != null) {
                      _checkTimer.cancel();
                    }
                    setState(() {
                      _noticeMark = 0;
                      _isStarted = false;
                      _noticeTextFloated = false;
                      _circles.clear();
                      _status = Text("GPS 측정 시작", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700));
                    });
                  },
                  child: Text("측정 취소", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize3, fontWeight: FontWeight.w700, letterSpacing: 0.6),)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.2933),
              child: GestureDetector(
                onTap: (_isStarted)
                ? null
                : _start,
                child: AspectRatio(
                  aspectRatio: 156/66,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 6, spreadRadius: 0, offset: Offset(0,3))],
                        color: mainColor,
                        borderRadius: BorderRadius.circular(33)
                    ),
                    // child: Text(_status, style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),),
                    child: _status,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(NaverMapController controller) async {
    print("맵");
    if (nmController.isCompleted) {
      nmController = Completer();
    }
    nmController.complete(controller);
    _getSpeckZone();
    _locationTrackingMode = LocationTrackingMode.Follow;
  }

  void _getSpeckZone() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/map");
    String body = ''' {
      "email" : "${sp.getString("email")}"  
    } ''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, headers: header, body: body);
    List<dynamic> result = jsonDecode(utf8.decode(response.bodyBytes));

    if (result != null) {
      for (int i = 0; i < result.length; i++) {
        // 코드의 첫번째 문자에 따라 타입과 마설정
        switch (result[i]["code"].substring(0,1)) {
          case "N":
            setState(() {
              _assetName = "assets/png/marker_normalcafe.png";
            });
            break;
          case "S":
            setState(() {
              _assetName = "assets/png/marker_studycafe.png";
            });
            break;
          case "R":
            setState(() {
              _assetName = "assets/png/marker_readingroom.png";
            });
            break;
          case "L":
            setState(() {
              _assetName = "assets/png/marker_lib.png";
            });
            break;
        }
        // 이미지 경로를 저장할 변수 선언

        await OverlayImage.fromAssetImage(assetName: _assetName, context: context)
            .then((image) {
          _markers.add(new Marker(
              captionText: result[i]["name"],
              captionTextSize: uiCriteria.textSize5,
              iconTintColor: mainColor,
              icon: image,
              width: (uiCriteria.screenWidth * 0.0618).toInt(),
              height: (uiCriteria.screenWidth * 0.0822).toInt(),
              markerId: result[i]["code"],
              position: new LatLng(result[i]["lat"], result[i]["lng"]),
            ));
        });
        // todo.이미지 설정
      }
    }
  }

  void _setPermission() async {
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
  }

  Future<LatLng> _getCurrentPosition() async {
    Position _result;
    await Geolocator.getCurrentPosition().then((Position position) {
      _result = position;
    });
    return new LatLng(_result.latitude, _result.longitude);
  }

  void _start() async {
    setState(() {
      _status = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("GPS 측정중", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),),
          Stack(
            children: [
              Text("..", style: TextStyle(color: Colors.transparent, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),),
              AnimatedTextKit(
                pause: Duration.zero,
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                      "..",
                      textStyle: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),
                      speed: Duration(milliseconds: 500))
                ],
              ),
            ],
          ),
        ],
      );
      if (_manualController.isAnimating) {
        _manualController.dispose();
      }
      _isStarted = true;
      _isStartTapped = true;
    });
    /// 데이터 초기화
    _lat = 0;
    _lng = 0;
    _positions.clear();
    _getCenterData();
  }

  void _generateCircle() {
    _delayTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      for (int i = 0; i < _positions.length; i++) {
        _lat += _positions[i].latitude;
        _lng += _positions[i].longitude;
      }
      _lat = _lat / 5;
      _lng = _lng / 5;
      print("lat $_lat");
      print("lng $_lng");
      _circles.add(CircleOverlay(overlayId: "test", center: LatLng(_lat, _lng), radius: _radius, color: _circleColor, outlineWidth: 1, outlineColor: greyB3B3BC));
      _status = Text("원을 벗어나세요", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700));
      _noticeTextFloated = true;
      setState(() {
      });
      _getLocationData();
      _delayTimer.cancel();
    });
  }

  void _getCenterData() async {
    _currentTimer = Timer.periodic(Duration(milliseconds: 360), (timer) async {
      await Geolocator.getCurrentPosition().then((Position position) {
        if (_positions.length != 5) {
          _positions.add(position);
          print(_positions);
        }
        else {
          _currentTimer.cancel();
        }
      });
    });
    _generateCircle();
  }

  void _getLocationData() async {
    _checkTime = 5;
    _positionSubscription = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best).listen((Position position) {
      print("position1 $position-----------------------");
      print("distance  ${Geolocator.distanceBetween(_lat, _lng, position.latitude, position.longitude)}");
      if (Geolocator.distanceBetween(_lat, _lng, position.latitude, position.longitude) > _radius) {

        if (_checkTimer == null || !_checkTimer.isActive) {
          _checkTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            print("checkTime $_checkTime");
            _circles[0].color = Color(0XFFfcf3b2).withOpacity(0.5);
            if (_checkTime != 0) {
              // _status = Text("인증까지 $_checkTime초..", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700));
              _status = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text( "인증까지 $_checkTime초",  style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),),
                  Stack(
                    children: [
                      Text( "..",  style: TextStyle(color: Colors.transparent, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),),
                      AnimatedTextKit(
                        repeatForever: true,
                        pause: Duration.zero,
                        animatedTexts: [
                          TyperAnimatedText(
                              "..",
                              textStyle: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700),
                              speed: Duration(milliseconds: 500))
                        ],
                      ),
                    ],
                  )
                ],
              );
              _checkTime--;
            }
            else {
              _positionSubscription.cancel();
              _checkTimer.cancel();
              _action();
            }
            setState(() {});
          });
        }
      }
      else {
        if (_checkTimer != null) {
          _checkTimer.cancel();
          _checkTime = 5;
          setState(() {
            _status = Text("원을 벗어나세요", style: TextStyle(color: Colors.white, fontSize: uiCriteria.textSize1, fontWeight: FontWeight.w700));
            _circles[0].color = Color(0XFF2880eb).withOpacity(0.5);
          });
        }
      }
      setState(() {});
    });
  }

  /// 클래스에 몰아넣기
  void _showTicket(BuildContext context, String placeName, int attCount, int totalCount, int attRate,
      int totalDeposit, int myDeposit, int totalDust, int accumPrize, int estimatePrize, String attendTime) {
    AlertDialog dialog = new AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: uiCriteria.horizontalPadding),
        content: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ticket(context, placeName, attCount, totalCount, attRate, totalDeposit, myDeposit, totalDust, accumPrize, estimatePrize, attendTime,_timeNum, _galaxyName, _mannerTime))
    );

    showAnimatedDialog(
        animationType: DialogTransitionType.slideFromBottom,
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: true,
        duration: Duration(seconds: 1),
        context: context,
        builder: (BuildContext context) {
          return dialog;
        }
    );
  }

  Widget _exitDialog() {
    return new AlertDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.162),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      content: AspectRatio(
        aspectRatio: 260/105,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 65,
              child: Container(
                  alignment: Alignment.center,
                  child: Text("GPS 인증을 종료하시겠습니까?", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),))
            ),
            Expanded(
              flex: 39,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: greyD8D8D8, width: 1))
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: greyD8D8D8, width: 1))
                          ),
                          child: Text("취소", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),)),
                        onTap: () {
                          if (_positionSubscription != null) {
                            _positionSubscription.resume();
                          }
                          else {
                            if (!_currentTimer.isActive) {
                              print("hi");
                              _getCenterData();
                            }
                          }
                          Navigator.pop(context);
                        },
                        ),
                      ),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                            alignment: Alignment.center,
                            child: Text("나가기", style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, fontWeight: FontWeight.w700, letterSpacing: 0.7),)),
                        onTap: () {
                          if (_noticeController != null && _noticeController.isAnimating) {
                            _noticeController.dispose();

                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
  
  void _showExitDialog() {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return _exitDialog();
      },
    );
  }

  Future<dynamic> _authenticate() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var url = Uri.parse("$speckUrl/certify/auth");
    int bookInfo = sp.getInt("bookInfo");
    String email = sp.getString("email");
    String body = ''' {
      "status" : 200,
      "placeCode" : "GPS05",
      "hashCode" : null,
      "userEmail" : "$email",
      "bookInfo" : $bookInfo
    } ''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    dynamic result = jsonDecode(utf8.decode(response.bodyBytes));

    return Future(() {
      return result;
    });
  }

  void _showLoader() {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return loaderDialog();
        });
  }

  void _action() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    dynamic result;
    Future future = _authenticate();
    await future.then((value) => result = value);
    int statusCode = result["defaultRes"]["statusCode"];
    dynamic ticketData = result["ticket"];
    _showLoader();
    switch (statusCode) {
      case 220:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          sp.remove("bookInfo");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _setTicketData(ticketData);
          _showTicket(context, _placeName, _attCount, _totalCount, _attRate, _totalDeposit, _myDeposit,
              _totalDust, _accumPrize, _estimatePrize, _attendTime);
        });
        break;
      case 320:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "출석 인증 가능 시간이 아니에요.");
        });
        break;
      case 321:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "오늘 예약한 탐험단이 없어요.");
        });
        break;
      case 322:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "출석이 완료된 탐험단이에요.");
        });
        break;
      case 411:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "GPS 인증에 실패했어요.");
        });
        break;
      case 412:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "GPS 인증에 실패했어요.");
        });
        break;
      case 420:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "GPS 인증에 실패했어요.");
        });
        break;
      case 421:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "GPS 인증에 실패했어요.");
        });
        break;
      case 422:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "GPS 인증에 실패했어요.");
        });
        break;
      case 423:
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        }).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SpeckApp()), (route) => false);
          _showResult(context, "GPS 인증에 실패했어요.");
        });
        break;
    }
  }

  void _showResult(BuildContext context, String message) {
    AlertDialog dialog = new AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.9)
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.1653),
      content: AspectRatio(
        aspectRatio: 251/164,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraint) {
            return Column(
              children: <Widget>[
                Spacer(),
                Icon(Icons.error_rounded, color: mainColor, size: constraint.maxWidth * 0.3027,),
                Spacer(),
                Text(message, style: TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, letterSpacing: 0.7, fontWeight: FontWeight.w700),),
                Spacer(),
              ],
            );
          },
        ),
      ),
    );

    showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void _setTicketData(dynamic ticket) {
    _placeName = ticket["placeName"];
    _attCount = ticket["attendCount"];
    _totalCount = ticket["totalCount"];
    _attRate = ticket["attRate"];
    _totalDeposit = ticket["totalDeposit"];
    _myDeposit = ticket["myDeposit"];
    _totalDust = ticket["totalDust"];
    _accumPrize = ticket["accumPrize"];
    _estimatePrize = ticket["estimatePrize"];
    _attendTime = ticket["attendTime"];
    _galaxyName = ticket["galaxyName"];
    _timeNum = ticket["timeNum"];
    _mannerTime = ticket["mannerTime"];
  }
}
