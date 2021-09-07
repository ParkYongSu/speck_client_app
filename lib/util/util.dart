import 'dart:io';
import 'dart:ui';

import 'package:speck_app/kakao/kakao_share.dart';
import 'package:url_launcher/url_launcher.dart';

String speckUrl = "https://api.speck.kr";
// String speckUrl = "https://develop.speck.kr";
// String speckUrl = "http://192.168.0.17:8080";

String getCharacter(int index) {
  switch (index) {
    case 0:
      return "assets/png/bbumi.png";
      break;
    case 1:
      return "assets/png/ggomi.png";
      break;
    case 2:
      return "assets/png/pang.png";
      break;
    case 3:
      return "assets/png/ssugi.png";
      break;
  }
  return "";
}

String getSleepCharacter(int index) {
  switch (index) {
    case 0:
      return "assets/png/bbumi_sleep.png";
      break;
    case 1:
      return "assets/png/ggomi_sleep.png";
      break;
    case 2:
      return "assets/png/pang_sleep.png";
      break;
    case 3:
      return "assets/png/ssugi_sleep.png";
      break;
  }
  return "";
}

inviteFriends() {
  KakaoShareManager().isKakaotalkInstalled().then((installed) {
    if (installed) {
      KakaoShareManager().shareMyCode();
    }
    else {
      if (Platform.isAndroid) {
        launch("https://play.google.com/store/apps/details?id=com.kakao.talk&hl=ko&gl=US");
      }
      else if (Platform.isIOS) {
        launch("https://apps.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947");
      }
    }
  });
}

Color shadowColor(int index) {
  switch (index) {
    case 0:
      return Color(0XFFFCA3D3);
    case 1:
      return Color(0XFFA9B5FF);
    case 2:
      return Color(0XFFFFB860);
    case 3:
      return Color(0XFFACCE75).withOpacity(0.79);
  }
  return null;
}