import 'package:flutter/material.dart';
import 'dart:ui' as ui;
class MyBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint지
    Paint paint = Paint()
      ..shader = ui.Gradient.radial(Offset(size.width * 0.5, -size.height * 3), size.width * 14, [Colors.black, Color(0XFF404040),Colors.white], [0.07, 0.097,0.103])
      ..color = Colors.black;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, 0), width: size.height * 60, height: size.width), paint);
  }

  // 프레임이 바뀌는 동안 계속 다시 그리는
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}