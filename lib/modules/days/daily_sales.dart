import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oz/database/db_firebase.dart';
// import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:oz/helpers/warning_dialog.dart';
// import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/sales/sale.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:oz/modules/days/daily_sale_card.dart';

class DailySales extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  DailySales(this.scaffoldKey, this.shop);
  _DailySalesState createState() => _DailySalesState();
}

class _DailySalesState extends State<DailySales> {
  final _db = DbInstance();
  List _sales = new List();
  List _items = new List();
  int _totalAmount = 0;
  double _totalSum = 0.00;

  TextEditingController _workDate = TextEditingController();
  String _currentDate;

  @override
  void initState() {
    super.initState();
    var dt = DateTime.now();
    _currentDate =
        '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
    _workDate.text =
        '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    _workDate.addListener(_checkDate);
    _db.reference.keepSynced(true);
    // _db.reference.child('sales').onChildAdded.listen(_salesAdded);
    // _db.reference.child('sales').onChildChanged.listen(_salesChanged);
    _fillSalesList(_currentDate);
  }

  // void _salesAdded(Event event) {
  //   setState(() {
  //     var sale = Sale.fromSnapshot(event.snapshot);
  //     if (sale.shopdate=='${widget.shop.key}~$_currentDate') _sales.add(sale);
  //     if (sale.item!=null && sale.item.isNotEmpty) _fillItems(sale.item);
  //     if (_sales.isNotEmpty) {
  //       _sales.sort((a, b) => a.date.compareTo(b.date));
  //     }
  //   });
  //   print(_sales.length);
  // }

  // void _salesChanged(Event event) {
  //   var old = _sales.singleWhere((entry) {
  //     return entry.key == event.snapshot.key;
  //   });
  //   setState(() {
  //     _sales[_sales.indexOf(old)] = Sale.fromSnapshot(event.snapshot);
  //   });
  // }

  void _checkDate() {
    var dt = _workDate.text.split('-');
    var currentDate = '${dt[2]}${dt[1]}${dt[0]}';
    if (_currentDate != currentDate) {
      setState(() {
        _currentDate = currentDate;
      });
      _fillSalesList(_currentDate);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _workDate.dispose();
  }

  // void _fillItems(String key) async {
  //       var item = await _db.getItemByKey(key);
  //       setState(() {
  //         if (item != null) _items.add(item);
  //       });
  // }

  void _fillSalesList(String dt) async {
    setState(() {
      _sales = new List();
      _items = new List();
      _totalAmount = 0;
      _totalSum = 0.00;
    });
    List sales = new List(), items = new List();
    int amount = 0;
    double total = 0.00;
    var lst = await _db.getSalesByDate(widget.shop.key, dt);
    if (lst != null && lst.length > 0) {
      lst.sort((a, b) => a.date.compareTo(b.date));
      for (int i = 0; i < lst.length; i++) {
        var item = await _db.getItemByKey(lst[i].item);
        if (item != null) items.add(item);
        sales.add(lst[i]);
        amount += lst[i].amount;
        total += (lst[i].amount * lst[i].price);
      }
    }
    setState(() {
      _sales = sales;
      _items = items;
      _totalAmount = amount;
      _totalSum = total;
    });
    print('${_sales.length}=${_items.length}');
  }

  Widget _buildDailyTotal() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              height: 100,
              width: 200,
              child: Form(
                child: DateTimePickerFormField(
                  editable: false,
                  dateOnly: true,
                  initialDate: DateTime.now(),
                  format: DateFormat("dd-MM-yyyy"),
                  firstDate: DateTime.now().subtract(Duration(days: 10)),
                  decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    hintText: 'Select a date',
                    labelText: 'Date:',
                  ),
                  controller: _workDate,
                  validator: (val) =>
                      (val != null || _convertToDate(val.toString()) != null)
                          ? null
                          : 'Please, select a date',
                ),
              ),
            ),
            Expanded(
                child: Column(
              children: <Widget>[
                Text('Sales:'),
                Text(
                  '$_totalAmount',
                  style: TextStyle(color: app_color, fontSize: 20),
                ),
              ],
            )),
            Expanded(
                child: Column(
              children: <Widget>[
                Text('TOTAL:'),
                Text(
                  '\$$_totalSum',
                  style: TextStyle(color: app_color, fontSize: 20),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSales() {
    return _sales.length > 0
        ? ListView.builder(
            itemCount: _sales.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: DailySaleCard(
                    widget.scaffoldKey, _sales[index], _items[index]),
                color: index % 2 == 0 ? Colors.white : Colors.grey[50],
              );
            })
        : notFound('NO SALES ON ${_workDate.text}, YET!');
  }

  DateTime _convertToDate(String input) {
    try {
      var d = DateTime.parse(input);
      return d;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Widget _buildDailySales() {
    return Container(
      child: Column(
        children: <Widget>[
          _buildDailyTotal(),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Card(
                child: _buildSales(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDailySales();
  }
}
