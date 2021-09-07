import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/Login/Email/email_login_page.dart';
import 'package:speck_app/State/find_state.dart';
import 'package:provider/provider.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';

class FindPasswordResultPage extends StatelessWidget {
  final UICriteria _uiCriteria = new UICriteria();
  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "비밀번호 찾기 결과 페이지",
        home: Scaffold(
          resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: _uiCriteria.appBarHeight,
              centerTitle: true,
              elevation: 0,
              backgroundColor: mainColor,
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
                    Text("비밀번호 찾기",
                        style: TextStyle(
                          letterSpacing: 0.8,
                          fontSize: _uiCriteria.textSize16,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        )),
                  ]
              ),
              // title: Text("비밀번호 찾기",
              //     style: TextStyle(fontSize: _uiCriteria.textSize16, color: Colors.black, fontWeight: FontWeight.w700)),

            ),
          body: Container(
              padding: EdgeInsets.fromLTRB(_uiCriteria.horizontalPadding, 0, _uiCriteria.horizontalPadding, _uiCriteria.totalHeight * 0.039),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: greyB3B3BC, width: 0.5)),
                  color: Colors.white),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: _uiCriteria.totalHeight * 0.425 - _uiCriteria.totalHeight * 0.039 + (_uiCriteria.appBarHeight + _uiCriteria.statusBarHeight) / 2),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("회원님의 이메일로", style: TextStyle(letterSpacing: 0.9, color: mainColor,fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w700)),
                                AspectRatio(aspectRatio: 343/9),
                                Text("임시 비밀번호를 보내드렸어요.", style: TextStyle(letterSpacing: 0.9, color: mainColor, fontSize: _uiCriteria.textSize4, fontWeight: FontWeight.w700)),
                              ]
                          ),
                          AspectRatio(aspectRatio: 343/36),
                          Container(
                            child: Column(
                                children: <Widget>[
                                  // AspectRatio(aspectRatio: 343/36),
                                  AspectRatio(
                                    aspectRatio: 343/50,
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(horizontal: _uiCriteria.screenWidth * 0.032),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(3.5),
                                          border: Border.all(color: greyB3B3BC, width: 0.5)
                                      ),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Consumer<FindState>(
                                              builder: (context, state, child) {
                                                return Text("${state.getInfo()}",
                                                    style: TextStyle(
                                                        color: mainColor,
                                                        fontSize: _uiCriteria.textSize2,
                                                        fontWeight: FontWeight.w500));
                                              },
                                            ),
                                            Consumer<FindState>(
                                              builder: (context, state, child) {
                                                return Row(
                                                  children: <Widget>[
                                                    Text("본인인증  ", style: TextStyle(letterSpacing: 0.5, color: mainColor, fontSize: _uiCriteria.screenWidth * 0.027, fontWeight: FontWeight.w500)),
                                                    Container(
                                                      height: _uiCriteria.screenWidth * 0.027,
                                                      width: 1,
                                                      color: greyD8D8D8,
                                                    ),
                                                    Text("  ${state.getRegisterDate()} 가입", style: TextStyle(letterSpacing: 0.5, color: mainColor,fontSize: _uiCriteria.screenWidth * 0.027, fontWeight: FontWeight.w500))
                                                  ],
                                                );
                                                // return Text("본인인증 ${state.getRegisterDate()} 가입", style: TextStyle(fontSize: _uiCriteria.screenWidth * 0.027, fontWeight: FontWeight.w500));
                                              },
                                            )
                                          ]),
                                    ),
                                  ),
                                  // Expanded(
                                  //     child: Column(
                                  //       mainAxisAlignment: MainAxisAlignment.end,
                                  //       children: <Widget>[
                                  //         AspectRatio(
                                  //           aspectRatio: 343/50,
                                  //           child: Container(
                                  //             width: MediaQuery.of(context).size.width,
                                  //             child: MaterialButton(
                                  //               shape: RoundedRectangleBorder(
                                  //                 borderRadius: BorderRadius.circular(3.5)
                                  //               ),
                                  //               elevation: 0,
                                  //               color: Color(0xFF404040),
                                  //               child: Text("로그인 창으로 돌아가기",
                                  //                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2)),
                                  //               onPressed: () =>
                                  //                   Navigator.push(
                                  //                   context,
                                  //                   MaterialPageRoute(
                                  //                       builder: (context) => EmailLoginPage()))
                                  //
                                  //             ),
                                  //           ),
                                  //         )
                                  //       ],
                                  //     ))
                                ]
                            ),
                          ),
                        ]
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 343/50,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.5)
                          ),
                          elevation: 0,
                          color: mainColor,
                          child: Text("로그인 창으로 돌아가기",
                              style: TextStyle(letterSpacing: 0.7, color: Colors.white, fontWeight: FontWeight.w500, fontSize: _uiCriteria.textSize2)),
                          onPressed: () =>
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmailLoginPage()), (route) => false)
                      ),
                    ),
                  )
                ],
              )),
        ));
  }
}
