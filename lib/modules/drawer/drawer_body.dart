import 'package:flutter/material.dart';
import 'package:oz/auth/auth_provider.dart';
import 'menu.dart';

List<Widget> drawerBody(BuildContext context) {
  var auth = AuthProvider.of(context).auth;
  int _role = auth.role == null ? 0 : auth.role;
  List _menu = List();
  List<Widget> _drawerBody = List();

  for (int i = 0; i < _role + 1; i++) {
    var drawerMenu = menu[i]['menu'] as List;
    drawerMenu.forEach((f) =>
        _menu.add([f['title'], f['icon'], f['navigator'], f['priority']]));
  }
  _menu.sort((a, b) => a[3].compareTo(b[3]));

  _menu.forEach((f) => _drawerBody.add(ListTile(
      title: Text(f[0]),
      leading: Icon(f[1]),
      onTap: () {
        Navigator.pushNamed(context, f[2]);
      })));

  return _drawerBody;
}
