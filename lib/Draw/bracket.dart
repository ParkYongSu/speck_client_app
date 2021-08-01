import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Bracket extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;
    final points = [
      Offset(-5, -34),
      Offset(12, 0),
      Offset(-5, 34)
    ];

    final paint = Paint()
    ..color = Color(0xFF8D92A3)
    ..strokeWidth = 1;

    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}