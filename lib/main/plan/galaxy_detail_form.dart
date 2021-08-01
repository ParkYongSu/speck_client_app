import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/main/plan/galaxy_detail.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';

class GalaxyDetailForm extends StatelessWidget {
  final String galaxyName; // 학교이름
  final String message; // 리더의 한마디
  final String imagePath; // 프로필
  final int galaxyNum; // 학교아이디
  final int official;
  final int route;

  GalaxyDetailForm({
    Key key,
    @required this.galaxyName,
    @required this.message,
    @required this.imagePath,
    @required this.galaxyNum,
    @required this.official,
    @required this.route
  }) : super(key: key);
  final UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: appBar(context, "갤럭시"),
        body: GalaxyDetail(
          galaxyName: galaxyName,
          imagePath: imagePath,
          galaxyNum: galaxyNum,
          official: official,
          route: route,

        )
    );
  }
}

