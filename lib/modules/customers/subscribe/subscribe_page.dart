import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/modules/customers/customer.dart';
import 'subscribe_form.dart';

class SubscribePage extends StatefulWidget {
  final String title;
  SubscribePage({this.title});
  _SubscribePageState createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  List<Customer> customers = List();
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
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: app_color,
      ),
      body: SubscribeForm(),
    );
  }
}
