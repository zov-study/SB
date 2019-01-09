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
  final _db = DbInstance();
  List _categ = new List();
  List _stock = new List();
  String _parent;
  int _level = 0;
  bool _subcat;
  int _countStock = -1;

  @override
  void initState() {
    super.initState();
    _subcat = true;
    _fillCategoriesList();
  }

  void _fillCategoriesList([String parentkey]) async {
    var lst = await _db.getCategoryList(parentkey);
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _categ = lst;
        _subcat = true;
        _level = lst[0].level;
      });
    } else {
      setState(() {
        _categ = new List();
        _subcat = false;
        _level = 0;
        _parent = null;
      });
    }
  }

  void _fillStock([String parentkey]) async {
    setState(() {
      _countStock = -1;
      _stock = new List();
    });
    var lst = await _db.getItemsByKey(parentkey);
    var stock = new List();
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      lst.forEach((f) {
        if (f.amount > 0) stock.add(f);
      });
    }
    setState(() {
      _stock = stock;
      _countStock = _stock.length;
      _subcat = false;
    });
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
    return _countStock < 0
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: app_color,
            ),
          )
        : _countStock > 0
            ? ListView.builder(
                itemCount: _countStock,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: _buildStockCard(_stock[index]),
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
      height: 110,
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
      if (item.amount == 0) _stock.removeAt(_stock.indexOf(item));
    });
  }

  Widget _buildCategs() {
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        padding: EdgeInsets.all(5),
        primary: true,
        itemCount: _categ.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _subcat = _categ[index].subcategory ?? false;
              });
              if (_subcat) {
                setState(() {
                  _parent = _categ[index].parent;
                });
                _fillCategoriesList(_categ[index].key);
              } else {
                setState(() {
                  _level = _categ[index].level + 1;
                });
                _fillStock(_categ[index].key);
              }
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: (_categ[index].image != null &&
                              _categ[index].image.isNotEmpty)
                          ? Image.network(
                              _categ[index].image,
                            )
                          : Image.asset('assets/images/not-available.png'),
                    ),
                    Text(
                      _categ[index].name,
                      style: TextStyle(
                          color: app_color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                child: _subcat ? _buildCategs() : _buildStock(),
              ),
            ),
          ),
          _level > 0
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () =>
                        _fillCategoriesList(_level < 2 ? null : _parent),
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
