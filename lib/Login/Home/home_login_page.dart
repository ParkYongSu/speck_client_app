import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:kakao_flutter_sdk/all.dart';
import 'package:provider/provider.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/Register/register_page1.dart';
import 'package:speck_app/Register/register_page2.dart';
import 'package:speck_app/State/page_navi_state.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeLoginPage extends StatefulWidget {

  @override
  State createState() {
    return HomeLoginPageState();
  }
}

class HomeLoginPageState extends State<HomeLoginPage> {
  final UICriteria _uiCriteria = new UICriteria();
  bool _isKakaoTalkInstalled;

  @override
  void initState() {
    super.initState();
    _initKakaoTalkInstalled();
  }

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    double _height = _uiCriteria.totalHeight;
    double _width = _uiCriteria.screenWidth;

    return MaterialApp(
      title: "홈 로그인 페이지",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: Colors.white
          ),
          padding: EdgeInsets.only(top: _height * 0.26),
          child: Column(
            children: <Widget>[
              Text("간편하게 로그인하고", style: TextStyle(fontSize: _width * 0.0507)),
              SizedBox(height: _height * 0.01),
              Text("다양한 서비스를 이용하세요.",
                  style:
                  TextStyle(
                      fontSize: _width * 0.0507, fontWeight: FontWeight.w500)),
              SizedBox(height: _height * 0.036),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 375/44,
                    child: Container(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () => _isKakaoTalkInstalled ? _loginWithTalk() : _loginWithKakao(),
                        child: AspectRatio(
                          aspectRatio: 282/44,
                          child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraint) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: constraint.maxWidth * 0.0532),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFFEE500),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset("assets/png/balloon.png", color: Color(0XFF000000), height: constraint.maxHeight / 3,),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text("카카오 로그인", style: TextStyle(color: Color(0XFF000000).withOpacity(0.85), fontSize: constraint.maxHeight / 3, fontWeight: FontWeight.w700),))
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        ),
                      ),
                    ),
                  )
                  // GestureDetector(
                  //     onTap: () => _isKakaoTalkInstalled ? _loginWithTalk() : _loginWithKakao(),
                  //     child: Image.asset("assets/png/kakao_login.png", width: _width * 0.8,)),
                  // SizedBox(height: _height * 0.02,),
                  // Image.asset("assets/png/naver_login.png", width: _width * 0.8,),
                  // SizedBox(height: _height * 0.02,),
                  // Image.asset("assets/png/apple_login.png", width: _width * 0.8,),
                ],
              ),
              // RaisedButton(
              //     child: Text("소셜 로그인"),
              //     onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SocialLoginPage()))),
              // SizedBox(height: 15.0),
              SizedBox(
                height: _height * 0.025,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _uiCriteria.screenWidth * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Text("이메일로 로그인",
                          style: TextStyle(fontSize: 13.0),
                          textAlign: TextAlign.center),
                      onTap: () =>
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EmailLoginPage())),
                    ),
                    InkWell(
                      child: Text("회원가입",
                          style: TextStyle(fontSize: 13.0),
                          textAlign: TextAlign.center),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => RegisterPage1()));
                        PageNaviState pns = Provider.of<PageNaviState>(
                            context, listen: false);
                        pns.setStart("home");
                      },
                    ),
                  ],
                ),
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
  
  void _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print("kakao Installed ${installed.toString()}");

    setState(() {
      _isKakaoTalkInstalled = installed;
    });

  }

  _issueAccessToken(String authCode) async {
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      print(token);
      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage2()));
    } catch (e) {
      print(e.toString());
    }
  }

  // 카카오톡 설치 안되어 있을 때
 _loginWithKakao() async {
    try {
      var code = await AuthCodeClient.instance.request()
          .whenComplete(() => print("complete"))
          .onError((error, stackTrace) {
            print("error $error");
            return "";
      });
      await _issueAccessToken(code);
    } catch (e) {
      print("dfjdfl");
      print(e.toString());
    }
  }

  // 카카오톡 설치 되어 있을 때
  _loginWithTalk() async {
    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (e) {
      print(e.toString());
    }
  }
}
