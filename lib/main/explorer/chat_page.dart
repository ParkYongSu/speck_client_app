import 'package:flutter/material.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: uiCriteria.appBarHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 242,),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: uiCriteria.textSize16, fontWeight: FontWeight.w600, color: mainColor, ),
                children: <TextSpan>[
                  TextSpan(text: "곧 "),
                  TextSpan(text: "채팅 서비스", style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: "가 오픈될 예정입니다!")
                ]
              ),
            ),
            SizedBox(height: uiCriteria.totalHeight * 0.0148,),
            Text("지금은 대체 서비스로 오픈채팅방을 운영중입니다.", style: TextStyle(fontSize: uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.w500)),
            SizedBox(height: uiCriteria.totalHeight * 0.0099,),
            Text("채팅을 통해 서로 자료를 공유해보세요!", style: TextStyle(fontSize: uiCriteria.textSize2, color: mainColor, fontWeight: FontWeight.w500)),
            Spacer(flex: 50,),
            Text("스펙 오픈채팅방", style: TextStyle(fontSize: uiCriteria.textSize2, color: greyAAAAAA, fontWeight: FontWeight.w700)),
            SizedBox(height: uiCriteria.totalHeight * 0.0074,),
            GestureDetector(
                onTap: () => launch("https://open.kakao.com/o/g5wavQmd"),
                child: Text("https://open.kakao.com/o/g5wavQmd", style: TextStyle(decoration: TextDecoration.underline,fontSize: uiCriteria.textSize2, color: greyAAAAAA, fontWeight: FontWeight.w500))),
            SizedBox(height: uiCriteria.totalHeight * 0.0074,),
            Text("참여코드: G01T", style: TextStyle(fontSize: uiCriteria.textSize2, color: greyAAAAAA, fontWeight: FontWeight.w500)),
            Spacer(flex: 261,),
          ],
        )
    );
  }
}
