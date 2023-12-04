import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MoveFilePage extends StatefulWidget {

  final List<String> fileNames;
  final List<String> fileBase64Data;

  const MoveFilePage({
    required this.fileNames,
    required this.fileBase64Data,
    Key? key
  }) : super(key: key);

  @override
  State<MoveFilePage> createState() => MoveFilePageState();

}

class MoveFilePageState extends State<MoveFilePage> {

  Widget buildBody() {
    return Column(
      children: [

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: Text(
          "Selected ${widget.fileNames.length} item(s)",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: buildBody(),
    );
  }

}