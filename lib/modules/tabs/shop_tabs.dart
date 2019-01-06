import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/shops/shop_edit.dart';
import 'package:oz/modules/sales/categ_alpha_sales.dart';
import 'package:oz/modules/days/daily_sales.dart';

class ShopTabs extends StatefulWidget {
  final Shop shop;
  ShopTabs({this.shop});

  @override
  _ShopTabsState createState() => _ShopTabsState();
}

class _ShopTabsState extends State<ShopTabs> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: app_color,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store)),
              Tab(icon: Icon(Icons.storage)),
              Tab(icon: Icon(Icons.info)),
            ],
          ),
          title: Text(widget.shop.name),
        ),
        body: TabBarView(
          children: [
            DailySales(_scaffoldKey, widget.shop),
            CategAlphaSale(_scaffoldKey, widget.shop),
            ShopEditForm(_scaffoldKey, widget.shop),
          ],
        ),
      ),
    );
  }
}
