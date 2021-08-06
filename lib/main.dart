import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:speck_app/Login/Todo/state_galaxy_sort.dart';
import 'package:speck_app/Login/Todo/state_time_sort.dart';
import 'package:speck_app/Main/home/main_home.dart';
import 'package:speck_app/Main/home/page_state.dart';
import 'package:speck_app/Main/main_page.dart';
import 'package:speck_app/Map/search_page.dart';
import 'package:speck_app/State/account_state.dart';
import 'package:speck_app/State/auth_status.dart';
import 'package:speck_app/State/banner_state.dart';
import 'package:speck_app/State/explorer_state.dart';
import 'package:speck_app/State/explorer_tab_state.dart';
import 'package:speck_app/State/page_navi_state.dart';
import 'package:speck_app/State/plan_info.dart';
import 'package:speck_app/State/recommend_state.dart';
import 'package:speck_app/State/register_state.dart';
import 'package:speck_app/State/searching_word_state.dart';
import 'package:speck_app/State/setting_state.dart';
import 'package:speck_app/Time/auth_timer.dart';
import 'package:speck_app/Time/card_time.dart';
import 'package:speck_app/Time/myInfo_timer.dart';
import 'package:speck_app/error/network_check.dart';
import 'package:speck_app/kakao/kakao_share.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'Login/Email/email_login_page.dart';
import 'State/notice.dart';
import 'package:speck_app/Time/stopwatch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'State/find_state.dart';
import "package:http/http.dart" as http;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoContext.clientId = "73f39efa3b70764d2db33838d3d8afb7";
  KakaoContext.javascriptClientId = "92c297bce9437e32308dead29e3b1806";
  KakaoShareManager manager = new KakaoShareManager();
  manager.initializeKakaoSDK();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_messageHandler);
  initializeDateFormatting().then((_) => runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => PageNaviState()),
      ChangeNotifierProvider(create: (context) => FindState()),
      ChangeNotifierProvider(create: (context) => RegisterState()),
      ChangeNotifierProvider(create: (context) => AboutTime()),
      ChangeNotifierProvider(create: (context) => AuthTimer()),
      ChangeNotifierProvider(create: (context) => PlanInfo()),
      ChangeNotifierProvider(create: (context) => SearchingWordState()),
      ChangeNotifierProvider(create: (context) => Notice()),
      ChangeNotifierProvider(create: (context) => GalaxySortName(),), // 갤럭시 분류
      ChangeNotifierProvider(create: (context) => TimeSort()),
      ChangeNotifierProvider(create: (context) => PageState()),
      ChangeNotifierProvider(create: (context) => CardTime()),
      ChangeNotifierProvider(create: (context) => BannerState()),
      ChangeNotifierProvider(create: (context) => AuthStatus()),
      ChangeNotifierProvider(create: (context) => ExplorerTabState()),
      ChangeNotifierProvider(create: (context) => ExplorerState()),
      ChangeNotifierProvider(create: (context) => SettingState()),
      ChangeNotifierProvider(create: (context) => MyInfoTimer(),),
      ChangeNotifierProvider(create: (context) => AccountState()),
      ChangeNotifierProvider(create: (context) => RecommendBannerState()),
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SpeckApp()),
  )));
}

/// 주석제거
// Future<void> _messageHandler(RemoteMessage message) async {
//   print(message.notification.body);
// }

class SpeckApp extends StatefulWidget {
  @override
  State createState() {
    return SpeckAppState();
  }
}

class SpeckAppState extends State<SpeckApp> {
  int _connectionState;
  final UICriteria _uiCriteria = new UICriteria();
  SharedPreferences _sp;
  BannerState _bs;
  // FirebaseMessaging _firebaseMessaging; /// 주석제거

  @override
  void initState() {
    super.initState();
    /// 주석제거
    // _firebaseMessaging = FirebaseMessaging.instance;
    // _firebaseMessaging.getToken().then((value) =>
    //   print("토큰 $value")
    // );
    // _firebaseMessaging.requestPermission();
    // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //   print("message recieved");
    //   print(event.notification.body);
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('Message clicked!');
    // });
  }

  @override
  Widget build(BuildContext context) {
    _bs = Provider.of<BannerState>(context, listen: false);
    return FutureBuilder(
        future: _splashAction(context),
        builder: (context, AsyncSnapshot snapshot) {
          _uiCriteria.init(context);
          _checkNetworkState();

          if (_connectionState == 0) {
            return Container(
              decoration: BoxDecoration(
                  color: mainColor
              ),
              child: _networkErrorDialog(context),
            );
          }
          else {
            print("스냅샷 데이터 있나 ${snapshot.hasData}");
            // 데이터를 아직 불러오지 못했을 때 리턴하는 위젯
            if (snapshot.hasData == false) {
              return Scaffold(
                body: loader(context, 1),
              );
            }
            // 데이터를 불러왔을 때 리턴하는 위젯
            else {
              return snapshot.data;
            }
          }
        }
    );
  }

  /// 네트워크 오류 다이얼로그
  Widget _networkErrorDialog(BuildContext context) {
    TextStyle style = TextStyle(color: mainColor, fontSize: _uiCriteria.textSize2, letterSpacing: 0.6, fontWeight: FontWeight.w700);

    AlertDialog alertDialog = new AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.152),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        content: AspectRatio(
          aspectRatio: 260/120,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 619,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: greyD8D8D8, width: 0.5))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(flex: 3,),
                        Text("네트워크 오류가 발생했습니다.", style: style),
                        Spacer(flex: 1,),
                        Text("잠시 후 다시 시도해주세요.", style: style),
                        Spacer(flex: 3,),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 371,
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        main();
                      },
                      child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text("다시 시도", style: style,))
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
    return alertDialog;
  }

  void _checkNetworkState() async {
    /// 네트워크 연결확인
    Connect connect = new Connect(); // Connect 인스턴스 생성
    // 커넥션 상태 값 받아오기
    Future future = connect.getConnectionState();
    await future.then((value) => _connectionState = value, onError: (e) => print(e));
  }

  Future<dynamic>_bannerData() async {
    var url = Uri.parse("http://13.209.138.39:8080/home");
    String body = '''{
      "userEmail" : "${_sp.getString("email")}"
    }''';
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };
    var response = await http.post(url, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    return result;
  }

  void _checkBanner() async {
    Future future = _bannerData();
    dynamic data;
    await future.then((value) => data = value).onError((error, stackTrace) => print(error));
    print("배너 데이터 $data");
    if (_bs.getEventStatus() == null) {
      _bs.setEventStatus(data["value"]);
    }

    if (_bs.getGalaxyStatus() == null) {
      _bs.setGalaxyStatus(data["galaxy"]);
    }

    if (_bs.getMapStatus() == null) {
      _bs.setMapStatus(data["map"]);
    }
  }

  Future<Widget> _splashAction(BuildContext context) async {
    _sp = await SharedPreferences.getInstance();
    String email = _sp.getString("email");
    String token = _sp.getString("token");
    // 최근 토큰 갱신 날짜를 가져옴
    String tokenUpdateDate = _sp.getString("tokenUpdateDate");
    print(email);
    print("쿠키에 저장된 이메일: ${_sp.getString("email")}");
    print("token ${_sp.getString("token")}");

    /// 지도에서 최근 검색어 목록을 가져옴
    if (_sp.getStringList("mapPostWordList") == null) {
      SearchPageState.postWordList = [];
    }
    else {
      SearchPageState.postWordList = _sp.getStringList("mapPostWordList");
    }
    /// 실시간 집중모드 사용인원 표시를 위한 웹소켓 통신에 사용될 닉네임 저장
    if (email != null) {
      MainHome.email = email;
    }
    // 현재 시간
    DateTime current = DateTime.now();

    print("tokenUpdateDate: $tokenUpdateDate");
    // 토큰이 있을 때
    if (token != null) {
      if (DateTime.now().difference(DateTime.parse(tokenUpdateDate)).inDays >= 21) {
        // 토큰 갱신
        var tokenUpdateUrl = Uri.parse("http://icnogari96.cafe24.com:8080/token/get.do?subject=$email");
        var response = await http.get(tokenUpdateUrl);
        var newToken = response.body;
        print("newToken: $newToken");
        await _sp.setString("token", newToken); // 새로운 토큰 저장
        await _sp.setString("tokenUpdateDate", current.toString()); // 토큰 갱신날짜 update
        /// 웹소켓 연결
        _checkBanner();
        return Future<Widget>(() {
          return MainNavigation();
        });
      }
      else {
        var checkInOutUrl = Uri.parse("http://icnogari96.cafe24.com:8080/members/check/auto/login");
        String body = "token=${token.substring(1,token.length - 1)}";
        print(body);
        Map<String, String > header = {
          "Content-Type" : "application/x-www-form-urlencoded"
        };

        var response = await http.post(checkInOutUrl, body: body, headers: header).onError((error, stackTrace) {
          print(error.toString());
          return;
        });
        var tf = response.body;
        if (tf == "true") {
          /// 웹소켓 연결
          _checkBanner();
          return Future<Widget>(() {
            return MainNavigation();
          });
        }
        else {
          return Future<Widget>(() {
            return EmailLoginPage();
          });
        }
      }
    }
    // 토큰이 없으면 로그인 페이지로
    return Future(() {
      return EmailLoginPage();
    });
  }
}

