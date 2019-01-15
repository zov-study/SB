import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/auth/auth_provider.dart';

List<Widget> drawerHeader(BuildContext context) {
  var auth = AuthProvider.of(context).auth;

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
      Navigator.of(context).pushNamed('/');
    } catch (e) {
      print(e.toString());
    }
  }

  return [
    DrawerHeader(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${auth.userName}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.white,
                  onPressed: () => _signOut(context),
                  tooltip: "Sign Out",
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  '(${roles[auth.role]})',
                  style: TextStyle(
                    color: Colors.white,
                    // fontSize: 16.0,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: app_color,
      ),
    )
  ];
}
