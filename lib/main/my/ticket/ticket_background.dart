import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class TicketBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final p = Path();
    p.lineTo(0, size.height / 1.6);
    p.relativeQuadraticBezierTo(size.width / 2, size.width / 6, size.width, 0);
    p.lineTo(size.width, 0);
    p.close();
    canvas.drawPath(p, Paint()
      ..shader = ui.Gradient.radial(Offset(size.width * 0.5, -size.width / 2), size.width * 3, [Colors.black, Color(0XFF404040),Colors.white], [0.2, 0.3, 0.365 ])
      ..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}