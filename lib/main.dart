import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/routes/routes.dart';
import 'package:oz/auth/auth.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
        auth: Auth(),
        child: MaterialApp(
          title: app_title,
          theme: ThemeData(primarySwatch: app_theme_color),
          initialRoute: '/',
          routes: Routes(context).getRoutes(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'NZ'),
            const Locale('ru', 'RU'),
          ],
        ));
  }
}
