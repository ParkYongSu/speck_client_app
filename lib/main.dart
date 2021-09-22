import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:package_info/package_info.dart';
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
import 'package:speck_app/error/network_error_page.dart';
import 'package:speck_app/firebase/check_token.dart';
import 'package:speck_app/firebase/firebase_init.dart';
import 'package:speck_app/firebase/token_init_state.dart';
import 'package:speck_app/kakao/kakao_share.dart';
import 'package:speck_app/main/explorer/chat_user_state.dart';
import 'package:speck_app/main/notify/notification_state.dart';
import 'package:speck_app/main/tutorial/tutorial.dart';
import 'package:speck_app/main/tutorial/tutorial_state.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/util/util.dart';
import 'package:speck_app/version/version_error_page.dart';
import 'package:speck_app/version/version_management.dart';
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
  await Firebase.initializeApp();
  firebaseSettings();
  FirebaseMessaging.onBackgroundMessage(showNotification);
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
      ChangeNotifierProvider(create: (context) => CardTime()),
      ChangeNotifierProvider(create: (context) => BannerState()),
      ChangeNotifierProvider(create: (context) => AuthStatus()),
      ChangeNotifierProvider(create: (context) => ExplorerState()),
      ChangeNotifierProvider(create: (context) => SettingState()),
      ChangeNotifierProvider(create: (context) => MyInfoTimer(),),
      ChangeNotifierProvider(create: (context) => AccountState()),
      ChangeNotifierProvider(create: (context) => RecommendBannerState()),
      ChangeNotifierProvider(create: (context) => TokenInitState()),
      ChangeNotifierProvider(create: (context) => NotificationState()),
      ChangeNotifierProvider(create: (context) => PageState()),
      ChangeNotifierProvider(create: (context) => TutorialState()),
      ChangeNotifierProvider(create: (context) => ChatUserState(),)
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SpeckApp()),
  )));
}

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

  @override
  Widget build(BuildContext context) {
    _bs = Provider.of<BannerState>(context, listen: false);
    return FutureBuilder(
        future: _checkIsNewVersion(),
        builder: (context, AsyncSnapshot snapshot) {
          _uiCriteria.init(context);
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
    );
  }

  void _checkNetworkState() async {
    /// 네트워크 연결확인
    Connect connect = new Connect(); // Connect 인스턴스 생성
    // 커넥션 상태 값 받아오기
    Future future = connect.getConnectionState();
    await future.then((value) => _connectionState = value, onError: (e) => print(e));
  }

  Future<dynamic> _bannerData() async {
    var url = Uri.parse("$speckUrl/home");
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

  Future<Widget> _checkIsNewVersion() async {
    _sp = await SharedPreferences.getInstance();
    Future grc = getRemoteConfig();
    RemoteConfig remoteConfig;
    await grc.then((value) => remoteConfig = value);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    String updateVersion = (Platform.isAndroid)?remoteConfig.getString("update_version_android"):remoteConfig.getString("update_version_ios");
    print("currentVersion $currentVersion");
    print("updateVersion $updateVersion");
    List<String> cList = currentVersion.split(".");
    List<String> uList = updateVersion.split(".");

    for (int i = 0; i < 3; i++) {
      int currentNum = int.parse(cList[i]);
      int updateNum = int.parse(uList[i]);
      print(currentNum);
      print(updateNum);
      if (currentNum < updateNum) {
        return VersionErrorPage();
      }
    }
    return _splashAction();
  }


  Future<dynamic> _initToken(String email) async {
    var tokenUpdateUrl = Uri.parse("$speckUrl/user/retoken");
    String body = """{
          "userEmail" : "$email"
        }""";
    Map<String, String> header = {
      "Content-Type" : "application/json"
    };

    var response = await http.post(tokenUpdateUrl, body: body, headers: header);
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    print("토큰 갱신 $result");
    return Future(() {
      return result;
    });
  }

  Future<int> _autoLogin(String token) async {
    var checkInOutUrl = Uri.parse("$speckUrl/user/login/auto");
    String body = """{
          "token" : "$token"
        }""";
    Map<String, String > header = {
      "Content-Type" : "application/json",
      "Authorization" : "$token"
    };

    var response = await http.post(checkInOutUrl, body: body, headers: header);
    var result = int.parse(response.body);
    print("자동로그인 $result");
    return Future(() {
      return result;
    });
  }

  Future<Widget> _splashAction() async {
    _checkNetworkState(); // 네트워크 통신상태 확인
    // _checkIsNewVersion(); // 새로운 버전인지 확인
    if (_connectionState == 0) {
      return NetworkErrorPage();
    }
    String email = _sp.getString("email");
    String token = _sp.getString("token");
    // 최근 토큰 갱신 날짜를 가져옴
    String tokenUpdateDate = _sp.getString("tokenUpdateDate");
    print(token);
    print("token ${_sp.getString("token")}");

    /// 지도에서 최근 검색어 목록을 가져옴
    if (_sp.getStringList("mapPostWordList") == null) {
      SearchPageState.postWordList = [];
    }
    else {
      SearchPageState.postWordList = _sp.getStringList("mapPostWordList");
    }

    initToken(email, context);

    // 토큰이 있을 때
    if (token != null) {
      if (DateTime.now().difference(DateTime.parse(tokenUpdateDate)).inDays >= 21) {
        DateTime current = DateTime.now();
        dynamic result;
        Future future = _initToken(email);
        await future.then((value) => result = value);
        int statusCode = result["status"]["statusCode"];

        if (statusCode == 200) {
          String newToken = result["token"];
          await _sp.setString("token", newToken.substring(0, newToken.length)); // 새로운 토큰 저장
          await _sp.setString("tokenUpdateDate", current.toString()); // 토큰 갱신날짜 update
          _checkBanner();
          if (_sp.getBool("tutorialStory4") == null) {
            return Future<Widget>(() {
              return Tutorial(route: 1);
            });
          }
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
      else {
        int result;
        Future future = _autoLogin(token);
        await future.then((value) => result = value);
        print("result34232 $result");
        if (result == 1) {
          _checkBanner();
          if (_sp.getBool("tutorialStory4") == null) {
            return Future<Widget>(() {
              return Tutorial(route: 1);
            });
          }
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
    // 토큰이 없으면 튜토리얼 페이지로
    return Future(() {
      return Tutorial(route: 0,);
    });
  }
}

