import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget notFound([String message]) {
  return Container(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(
              FontAwesomeIcons.frownOpen,
              size: 96.0,
              color: app_color,
            ),
          ),
          Text(
            message == null || message.isEmpty ? "NOT FOUND!!!" : message,
            style: TextStyle(color: app_color, fontSize: 36.0),
          ),
        ],
      ),
    ),
  );
}
