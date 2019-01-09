import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/helpers/barcode_scaner.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/stock/stock_list.dart';
import 'package:oz/modules/stock/new_item.dart';

class StockPage extends StatefulWidget {
  final String title;
  final Category category;
  StockPage({this.title, this.category});
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Item> stock = List();
  List<bool> filtered = List();
  bool isSelectedAll = false;
  int found = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DbInstance();

  @override
  void initState() {
    super.initState();
    db.reference.child('stock').onChildAdded.listen(_stockAdded);
    db.reference.child('stock').onChildChanged.listen(_stockChanged);
  }

  void _stockAdded(Event event) {
    setState(() {
      var item = Item.fromSnapshot(event.snapshot);
      if (widget.category != null &&
          item.key.isNotEmpty &&
          item.category == widget.category.key) stock.add(item);
      if (widget.category == null) stock.add(item);
      if (stock.isNotEmpty) {
        stock.sort((a, b) => a.name.compareTo(b.name));
        filtered.add(true);
        found = stock.length;
      }
    });
  }

  void _stockChanged(Event event) {
    var old = stock.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      stock[stock.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        searchBar.getSearchAction(context),
        IconButton(
          icon: Icon(Icons.scanner),
          color: Colors.white,
          tooltip: 'Search by barcode',
          onPressed: () async {
            var barcode = await barcodeScan();
            onSubmitted(barcode, true);
          },
        ),
        found == 0
            ? IconButton(
                icon: Icon(Icons.clear),
                color: Colors.white,
                tooltip: "Clear filter",
                onPressed: () {
                  onSubmitted('');
                },
              )
            : Container(),
        widget.category != null
            ? IconButton(
                icon: Icon(Icons.add_circle),
                tooltip: 'New item',
                onPressed: () => _newItem(),
              )
            : Container(),
      ],
      backgroundColor: app_color,
    );
  }

  _StockPageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  void onSubmitted(String value, [bool isBarcode = false]) {
    print(value);
    found = 0;
    setState(() {
      for (int i = 0; i < stock.length; i++) {
        if (isBarcode)
          filtered[i] = stock[i]
              .barcode
              .toLowerCase()
              .trim()
              .contains(value.trim().toLowerCase());
        else
          filtered[i] = stock[i]
              .name
              .toLowerCase()
              .trim()
              .contains(value.trim().toLowerCase());
        if (filtered[i]) found++;
      }
      if (found > 0)
        snackbarMessageKey(
            _scaffoldKey, "Were found $found items", app_color, 3);
    });
  }

  void _newItem() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            NewItemForm(_scaffoldKey, 'New Item', widget.category));
    setState(() {
      stock = stock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      body: found > 0
          ? StockList(_scaffoldKey, widget.category, stock, filtered)
          : notFound(),
    );
  }
}
