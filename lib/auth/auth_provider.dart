import 'package:flutter/material.dart';
import 'auth.dart';

class AuthProvider extends InheritedWidget {
  final BaseAuth auth;
  AuthProvider({Key key, Widget child, this.auth})
      : super(key: key, child: child);
      @override
        bool updateShouldNotify(InheritedWidget oldWidget) =>true;

    static AuthProvider of(BuildContext context) {
      return (context.inheritFromWidgetOfExactType(AuthProvider) as AuthProvider);
    }
}
