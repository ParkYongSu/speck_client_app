import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class FocusTimeData {
  int date;
  int time;
  charts.Color barColor;

  FocusTimeData(
      {@required this.date, @required this.time, @required this.barColor});
}
