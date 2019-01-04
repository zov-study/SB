import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/categories/categories_grid.dart';

class CatAlfaGrid extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  CatAlfaGrid(this.scaffoldKey, this.shop);
  _CatAlfaGridState createState() => _CatAlfaGridState();
}

class _CatAlfaGridState extends State<CatAlfaGrid> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildEdit() {
    return Card(
      child: Text('data'),
    );
  }

  Widget _buildGrids() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildEdit(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGrids();
  }
}
