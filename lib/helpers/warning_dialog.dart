import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';

Future<Null> warningDialog(BuildContext context, Function callback,
    {String content = 'Please confirm!',
    String title = 'ATTENTION!!!',
    String button = 'Ok'}) async {
  return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          title: Text(
            title,
            style: TextStyle(
                color: app_color, decoration: TextDecoration.underline),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
                ),
            callback != null
                ? FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      callback();
                    },
                    child: Text(button))
                : callback,
          ],
        );
      });
}
