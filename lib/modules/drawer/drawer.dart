import 'package:flutter/material.dart';
import 'drawer_header.dart';
import 'drawer_body.dart';

class LeftMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: drawerHeader(context) + drawerBody(context),
      ),
    );
  }
}
