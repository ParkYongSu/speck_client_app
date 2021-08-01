import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speck_app/main/explorer/explorer_detail.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'package:speck_app/widget/public_widget.dart';

class ExplorerForm extends StatelessWidget {

  final UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    _uiCriteria.init(context);
    return Scaffold(
        appBar: appBar(context, "탐험단"),
        backgroundColor: mainColor,
        body: ExplorerDetail(),

    );
  }

}
