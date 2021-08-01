import 'package:flutter/material.dart';

class SocialLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "소셜로그인",
      home: Scaffold(
        body: Center(
          child: Text("소셜 로그인 페이지"),
        ),
      )
    );
  }
}