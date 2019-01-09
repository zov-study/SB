import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/shops/shops_list.dart';
import 'package:oz/modules/shops/new_shop.dart';

class ShopsPage extends StatefulWidget {
  final String title;
  ShopsPage({this.title});
  _ShopsPageState createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  List<Shop> shops = List();
  List<bool> filtered = List();
  bool isSelectedAll = false;
  int found = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DbInstance();

  @override
  void initState() {
    super.initState();
    db.reference.child('shops').onChildAdded.listen(_shopAdded);
    db.reference.child('shops').onChildChanged.listen(_shopChanged);
  }


  void _shopAdded(Event event) {
    setState(() {
      shops.add(Shop.fromSnapshot(event.snapshot));
      shops.sort((a, b) => a.name.compareTo(b.name));
      filtered.add(true);
      found++;
    });
  }

  void _shopChanged(Event event) {
    var old = shops.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      shops[shops.indexOf(old)] = Shop.fromSnapshot(event.snapshot);
    });
  }

  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        searchBar.getSearchAction(context),
        found == 0
            ? IconButton(
                icon: Icon(Icons.close),
                color: Colors.white,
                onPressed: (() {
                  onSubmitted('');
                }),
              )
            : Container(),
        IconButton(
          icon: Icon(Icons.add_circle),
          tooltip: 'New shop',
          onPressed: () => _newShop(),
        ),
      ],
      backgroundColor: app_color,
    );
  }

  _ShopsPageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  void onSubmitted(String value) {
    print(value);
    found = 0;
    setState(() {
      for (int i = 0; i < shops.length; i++) {
        filtered[i] = shops[i].name.toLowerCase().contains(value);
        if (filtered[i]) found++;
      }
      if (found > 0)
        snackbarMessageKey(
            _scaffoldKey, "Were found $found Shops", app_color, 3);
    });
  }

  void _newShop() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NewShopForm(_scaffoldKey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      body: found == -1
          ? Center(
              child: CircularProgressIndicator(),
            )
          : found > 0 ? ShopsList(_scaffoldKey, shops, filtered) : notFound(),
    );
  }
}
