import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oz/database/db_firebase.dart';
// import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/sales/sale.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class DailySales extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  DailySales(this.scaffoldKey, this.shop);
  _DailySalesState createState() => _DailySalesState();
}

class _DailySalesState extends State<DailySales> {
  final _db = DbInstance();
  List _sales = new List();
  int _totalAmount;
  double _totalSum;
  TextEditingController _workDate = TextEditingController();
  String _currentDate;

  @override
  void initState() {
    super.initState();
    var dt = DateTime.now().toString().substring(0, 10).split('-');
    _workDate.text = '${dt[2]}-${dt[1]}-${dt[0]}';
    _currentDate = '${dt[0]}${dt[1]}${dt[3]}';
    print(_currentDate);
    _workDate.addListener(_checkDate);
    _fillSalesList(_currentDate);
  }

  void _checkDate() {
    var dt = _workDate.text.split('-');
    setState(() {
      _currentDate = '${dt[2]}${dt[1]}${dt[0]}';
    });
    print(_currentDate);
  }

  void _fillSalesList([String dt]) async {
      setState(() {
        _sales = new List();
        _totalAmount=0;
        _totalSum=0.00;
      });
    var lst = await _db.getSalesByDate(widget.shop.key,dt);
    if (lst != null && lst.isNotEmpty) {
      setState(() {
        lst.forEach((f){
           _sales.add(f) ;
           _totalAmount+=f.amount;
           _totalSum+=(f.amount*f.price);
        });
        _sales = lst;

      });
    }
  }

  Widget _buildDailyTotal() {
    return Container(
      height: 150,
      padding: EdgeInsets.all(10),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: 180,
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
              child: Text('Sales:'),
            ),
            Expanded(
              child: Text(
                '$_totalAmount',
                style: TextStyle(color: app_color, fontSize: 24),
              ),
            ),
            Expanded(
              child: Text('TOTAL:'),
            ),
            Expanded(
              child: Text(
                '\$$_totalSum',
                style: TextStyle(color: app_color, fontSize: 24),
              ),
            ),
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
                child: _buildSaleCard(_sales[index]),
                color: index % 2 == 0 ? Colors.white : Colors.grey[50],
              );
            })
        : notFound('NO SALES TODAY YET!');
  }


  Widget _buildSaleCard(Sale sale) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildImage(sale),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: _buildForm(sale),
        ),
        _buildPriceInfo(sale),
        _buildButtons(sale),
      ]),
    );
  }

  Widget _buildImage(Sale sale) {
    return Image(
      image: sale.itemimage == null || sale.itemimage.isEmpty
          ? AssetImage('assets/images/not-available.png')
          : NetworkImage(sale.itemimage),
      fit: BoxFit.contain,
      width: 110,
    );
  }

  Widget _buildForm(Sale sale) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        sale.item,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          color: app_color,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(Sale sale) {
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
                  '${sale.amount}',
                  style: TextStyle(fontSize: 20.0, color: app_color),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Price'),
                Text(
                  '\$${sale.price.toStringAsFixed(2)}',
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

  Widget _buildButtons(Sale sale) {
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
              onPressed: () {},
            ),
          ],
        ));
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
