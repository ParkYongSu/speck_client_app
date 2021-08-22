import 'package:flutter/material.dart';
import 'package:speck_app/main.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/widget/public_widget.dart';

class NetworkErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: mainColor
      ),
      child: _networkErrorDialog(context),
    );
  }

  /// 네트워크 오류 다이얼로그
  Widget _networkErrorDialog(BuildContext context) {
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

}
