import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/drawer/drawer.dart';
import 'package:oz/settings/config.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedOut;
  HomePage({this.onSignedOut});
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DbInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: app_color,
        title: Text(app_title),
        centerTitle: true,
      ),
      drawer: LeftMenu(),
      body: _buildHomeGrid(),
    );
  }

  Widget _buildHomeGrid() {
    return Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/logo.jpg',
            width: 240.0,
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Text(
            'SHOP SMART, PAY LESS',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
