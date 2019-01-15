import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
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
  int _saleIndex;
  int _countSales = -1;

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
    _fillSalesList(_currentDate);
  }

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

  void _fillSalesList(String dt) async {
    setState(() {
      _sales = new List();
      _items = new List();
      _totalAmount = 0;
      _totalSum = 0.00;
      _countSales = -1;
    });
    List sales = new List(), items = new List();
    int amount = 0;
    double total = 0.00;
    var lst = await _db.getSalesByDate(widget.shop.key, dt);
    if (lst != null && lst.length > 0) {
      lst.sort((a, b) => b.date.compareTo(a.date));
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
      _countSales = _sales.length;
    });
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
                    labelText: 'DATE:',
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
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('SALES:'),
                ),
                Text(
                  '$_totalAmount',
                  style: TextStyle(
                      color: app_color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
            Expanded(
                child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('TOTAL:'),
                ),
                Text(
                  '\$${_totalSum.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: app_color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSales() {
    return _countSales < 0
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: app_color,
            ),
          )
        : _countSales > 0
            ? ListView.builder(
                itemCount: _countSales,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: DailySaleCard(widget.scaffoldKey, _sales[index],
                        _items[index], _callBack),
                    color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                  );
                })
            : notFound('SORRY, NO SALES THIS DAY!');
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

  void _removeIt() async {
    _db.reference.keepSynced(true);
    var result = await _db.removeByKey('sales', _sales[_saleIndex].key);
    if (result == 'ok') {
      Item item = await _db.getItemByKey(_sales[_saleIndex].item);
      if (item != null)
        result = await _db.updateValue('stock', _sales[_saleIndex].item,
            'amount', item.amount + _sales[_saleIndex].amount);
    }
    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          '${_items[_saleIndex].name} has been removed...', app_color, 3);
      _fillSalesList(_currentDate);
    } else
      snackbarMessageKey(widget.scaffoldKey, result.toString(), app_color, 3);
  }

  void _updateIt() async {
    var result;
    int diffAmount = 0;
    double diffPrice = 0.00;
    _db.reference.keepSynced(true);
    Sale oldsale = await _db.getSaleByKey(_sales[_saleIndex].key);
    if (oldsale != null && oldsale.amount != _sales[_saleIndex].amount) {
      diffAmount = oldsale.amount - _sales[_saleIndex].amount;
      result = await _db.updateValue(
          'sales', _sales[_saleIndex].key, 'amount', _sales[_saleIndex].amount);
      if (result == 'ok') {
        Item item = await _db.getItemByKey(_sales[_saleIndex].item);
        if (item != null)
          result = await _db.updateValue('stock', _sales[_saleIndex].item,
              'amount', item.amount + diffAmount);
      }
    }
    if (oldsale != null && oldsale.price != _sales[_saleIndex].price) {
      diffPrice = oldsale.price - _sales[_saleIndex].price;
      result = await _db.updateValue(
          'sales', _sales[_saleIndex].key, 'price', _sales[_saleIndex].price*100);
    }
    if (result == 'ok')
      snackbarMessageKey(widget.scaffoldKey,
          '${_items[_saleIndex].name} updated successfully...', app_color, 3);
    else
      snackbarMessageKey(widget.scaffoldKey, result.toString(), app_color, 3);

    if (diffAmount != 0 || diffPrice != 0) _fillSalesList(_currentDate);

  }

  void _callBack(Sale sale, [bool isRemove = false]) async {
    _saleIndex = _sales.indexOf(sale);
    if (isRemove)
      await warningDialog(context, _removeIt,
          content: 'Please, Confirm to delete ${_items[_saleIndex].name}!!!',
          button: 'DELETE');
    else
      _updateIt();
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


  @override
  Widget build(BuildContext context) {
    return _buildDailySales();
  }
}
