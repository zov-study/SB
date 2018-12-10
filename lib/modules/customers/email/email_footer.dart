import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';

Widget emailFooter(BuildContext context, Function callback) {
  return BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
          icon: Icon(Icons.skip_previous), title: Text('Prev. 60')),
      BottomNavigationBarItem(
          icon: Icon(Icons.skip_next), title: Text('Next 60')),
    ],
    onTap: callback,
    fixedColor: app_color,
    currentIndex: 1,
  );
}
