import 'dart:io';

import 'package:kakao_flutter_sdk/link.dart';

class KakaoShareManager {

  static final KakaoShareManager _manager = KakaoShareManager._internal();

  factory KakaoShareManager() {
    return _manager;
  }

  KakaoShareManager._internal() {
    // 초기화 코드
    KakaoContext.clientId = "73f39efa3b70764d2db33838d3d8afb7";
    KakaoContext.javascriptClientId = "92c297bce9437e32308dead29e3b1806";
  }

  void initializeKakaoSDK() {
    String kakaoAppKey = "73f39efa3b70764d2db33838d3d8afb7";
    KakaoContext.clientId = kakaoAppKey;
  }

  Future<bool> isKakaotalkInstalled() async {
    bool installed = await isKakaoTalkInstalled();
    return installed;
  }

  void shareMyCode() async {
    try {
      var template = _getTemplate();
      var uri = await LinkClient.instance.defaultWithTalk(template);
      await LinkClient.instance.launchKakaoTalk(uri);
    } catch (error) {
      print(error.toString());
    }
  }

  DefaultTemplate _getTemplate() {
    String title = "스펙 - 집 밖을 나서는 순간, 계획은 시작!";
    Uri imageLink = Uri.parse("https://users-profile-bucket.s3.ap-northeast-2.amazonaws.com/kakao_share_image.png");
    Link link;
    if (Platform.isAndroid) {
      link = new Link(
        webUrl: Uri.parse("https://play.google.com/store/apps/details?id=com.paidagogos.speck"),
        mobileWebUrl: Uri.parse("https://play.google.com/store/apps/details?id=com.paidagogos.speck")
      );
    }
    else if (Platform.isIOS) {
      link = new Link(
          webUrl: Uri.parse("https://apps.apple.com/us/app/스펙/id1575646552"),
          mobileWebUrl: Uri.parse("https://apps.apple.com/us/app/스펙/id1575646552")
      );
    }

    Content content = Content(
      title,
      imageLink,
      link,
    );

    FeedTemplate template = FeedTemplate(
        content,
        buttons: [
          Button("앱으로 보기",

              Link(mobileWebUrl: (Platform.isAndroid)?Uri.parse("https://play.google.com/store/apps/details?id=com.paidagogos.speck"):Uri.parse("https://apps.apple.com/us/app/스펙/id1575646552")
              )
          ),
        ]
    );

    return template;
  }
}