import 'package:flutter/material.dart';

/// 좌 -> 우
Route createRoute1(Widget widget) {
  return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return widget;
      },
      transitionsBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation, Widget child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.linearToEaseOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }

  );
}

/// 하단 -> 상단
Route createRoute2(Widget widget) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation, Widget child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.linearToEaseOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    }
  );
}

