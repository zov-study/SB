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

enum Toggle { category, alpha }

class CatAlphaGrid extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  CatAlphaGrid(this.scaffoldKey, this.shop);
  _CatAlphaGridState createState() => _CatAlphaGridState();
}

class _CatAlphaGridState extends State<CatAlphaGrid> {
  Toggle _toggleMode = Toggle.category;
  final db = DbInstance();
  List cat = new List();
  List stock = new List();
  List qqq = List<int>.generate(7, (int index)=>index);
  String parent;
  int level = 0;
  bool subcat;

  @override
  void initState() {
    super.initState();
    subcat = false;
    // _fillCategoriesList();
    // _fillStock('-LTzmjdGG9wYZgGrXDKP');
  }

  void _fillCategoriesList([String parentkey]) async {
    print(this.parent);
    var lst = await db.getCategoryList(parentkey);
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        cat = lst;
        level = lst[0].level;
      });
    } else {
      setState(() {
        cat = new List();
        level = 0;
        parent = null;
      });
    }
  }

  void _fillStock([String parentkey]) async {
    print(this.parent);
    var lst = await db.getItemsByKey(parentkey);
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        stock = lst;
        subcat=false;
      });
    } else {
      setState(() {
        stock = new List();
      });
    }
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
              child: RaisedButton(
            child: Text('Categories'),
            textColor: _toggleMode == Toggle.category ? Colors.white : null,
            color: _toggleMode == Toggle.category ? app_color : null,
            onPressed: () {
              setState(() {
                _toggleMode = Toggle.category;
              });
            },
          )),
          Expanded(
            child: RaisedButton(
              child: Text('Alphabet'),
              textColor: _toggleMode == Toggle.alpha ? Colors.white : null,
              color: _toggleMode == Toggle.alpha ? app_color : null,
              onPressed: () {
                setState(() {
                  _toggleMode = Toggle.alpha;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStock() {
    return ListView.builder(
        itemCount: qqq.length,
        itemBuilder: (BuildContext context, int index) {
          ListTile(
            leading: CircleAvatar(
              child: Text('$index'),
            ),
            title: Text('Item - ${qqq[index]}stock[index].name'),
          );
        });
  }

  Widget _buildGrid() {
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        padding: EdgeInsets.all(5),
        primary: true,
        itemCount: cat.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                parent = cat[index].parent;
                subcat = cat[index].subcategory ?? false;
              });
              if (subcat)
                _fillCategoriesList(cat[index].key);
              else
                _fillStock(cat[index].key);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  (cat[index].image != null && cat[index].image.isNotEmpty)
                      ? Image.network(cat[index].image)
                      : Image.asset('assets/images/not-available.png'),
                  Text(
                    cat[index].name,
                    style: TextStyle(
                        color: app_color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildGrids() {
    return Container(
      child: Column(
        children: <Widget>[
          _buildToggleButtons(),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Card(
                child: subcat ? _buildGrid() : _buildStock(),
              ),
            ),
          ),
          level > 0
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () =>
                        _fillCategoriesList(level < 2 ? null : parent),
                    backgroundColor: app_color,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGrids();
  }
}
