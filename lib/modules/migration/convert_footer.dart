import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';

Widget convertFooter(BuildContext context, Function callback) {
  return BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
          icon: Icon(Icons.transform), title: Text('Transfer')),
      BottomNavigationBarItem(
          icon: Icon(Icons.check_circle), title: Text('Select all')),
    ],
    onTap: callback,
    fixedColor: app_color,
    currentIndex: 1,
  );
}
