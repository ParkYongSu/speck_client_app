import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionErrorPage extends StatefulWidget {
  @override
  _VersionErrorPageState createState() => _VersionErrorPageState();
}

class _VersionErrorPageState extends State<VersionErrorPage> {
  @override
  Widget build(BuildContext context) {
    return _versionErrorPage();
  }

  Widget _versionErrorPage() {
    return Container(
      child: _versionErrorDialog(),
    );
  }

  Widget _versionErrorDialog() {
    TextStyle style = TextStyle(color: mainColor, fontSize: uiCriteria.textSize2, letterSpacing: 0.6, fontWeight: FontWeight.w700);

    AlertDialog alertDialog = new AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: uiCriteria.screenWidth * 0.152),
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
                        Text("새로운 버전이 출시되었습니다.", style: style),
                        Spacer(flex: 1,),
                        Text("업데이트 후 만나보세요!", style: style),
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
                          _navigateStore();
                        },
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: Text("업데이트", style: style,))
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

  void _navigateStore() async {
    String url = (Platform.isAndroid)?"https://play.google.com/store/apps/details?id=com.paidagogos.speck":"https://apps.apple.com/us/app/speck/id1575646552";
    await launch(url);
  }
}
