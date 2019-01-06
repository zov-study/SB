import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
// import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/sales/new_sale.dart';

enum Toggle { category, alpha }

class CategAlphaSale extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  CategAlphaSale(this.scaffoldKey, this.shop);
  _CategAlphaSaleState createState() => _CategAlphaSaleState();
}

class _CategAlphaSaleState extends State<CategAlphaSale> {
  Toggle _toggleMode = Toggle.category;
  final db = DbInstance();
  List cat = new List();
  List stock = new List();
  String parent;
  int level = 0;
  bool subcat;

  @override
  void initState() {
    super.initState();
    subcat = true;
    _fillCategoriesList();
  }

  void _fillCategoriesList([String parentkey]) async {
    print(this.parent);
    var lst = await db.getCategoryList(parentkey);
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        cat = lst;
        subcat = true;
        level = lst[0].level;
      });
    } else {
      setState(() {
        cat = new List();
        subcat = false;
        level = 0;
        parent = null;
      });
    }
  }

  void _fillStock([String parentkey]) async {
    print(this.parent);
    setState(() {
      stock = new List();
    });
    var lst = await db.getItemsByKey(parentkey);
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        lst.forEach((f) {
          if (f.amount > 0) stock.add(f);
        });
        subcat = false;
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
              _fillCategoriesList();
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
    return stock.length > 0
        ? ListView.builder(
            itemCount: stock.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: _buildStockCard(stock[index]),
                color: index % 2 == 0 ? Colors.white : Colors.grey[50],
              );
            })
        : notFound();
  }

  Widget _buildStockCard(Item item) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildImage(item),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: _buildForm(item),
        ),
        _buildPriceInfo(item),
        _buildButtons(item),
      ]),
    );
  }

  Widget _buildImage(Item item) {
    return Image(
      image: item.image == null || item.image.isEmpty
          ? AssetImage('assets/images/not-available.png')
          : NetworkImage(item.image),
      fit: BoxFit.contain,
      width: 110,
    );
  }

  Widget _buildForm(Item item) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        item.name,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          color: app_color,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(Item item) {
    return Expanded(
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Amount'),
                Text(
                  '${item.amount}',
                  style: TextStyle(fontSize: 20.0, color: app_color),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Price'),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 24.0,
                      color: app_color,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(Item item) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(
                'SELL IT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              color: app_color,
              textColor: Colors.white,
              onPressed: () => _sellIt(item),
            ),
          ],
        ));
  }

  void _sellIt(Item item) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            NewSaleForm(widget.scaffoldKey, widget.shop, item));
    setState(() {
      item.amount = item.amount;
      if (item.amount == 0) stock.removeAt(stock.indexOf(item));
    });
  }

  Widget _buildCategs() {
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
                subcat = cat[index].subcategory ?? false;
              });
              if (subcat) {
                setState(() {
                  parent = cat[index].parent;
                });
                _fillCategoriesList(cat[index].key);
              } else {
                setState(() {
                  level = cat[index].level + 1;
                });
                _fillStock(cat[index].key);
              }
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
                child: subcat ? _buildCategs() : _buildStock(),
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
