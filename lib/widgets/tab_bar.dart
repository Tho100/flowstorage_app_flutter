import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {

  final List<Widget> tabs;

  const CustomTabBar({
    required this.tabs,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, left: 16.0, right: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.justWhite,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: ThemeColor.justWhite,
            width: 2.0
          )
        ),
        child: TabBar(
          indicator: BoxDecoration(
            color: ThemeColor.darkBlack,
            borderRadius: BorderRadius.circular(15.0),
          ),
          labelColor: ThemeColor.justWhite,
          unselectedLabelColor: ThemeColor.darkBlack,
          tabs: tabs
        ),
      ),
    );
  }

}