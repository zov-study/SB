import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/sales/sale.dart';

class NewSaleForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Shop shop;
  final Item item;
  NewSaleForm(this.scaffoldKey, this.shop, this.item);
  _NewSaleFormState createState() => _NewSaleFormState();
}

class _NewSaleFormState extends State<NewSaleForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final db = DbInstance();
  TextEditingController _amount = TextEditingController();
  TextEditingController _price = TextEditingController();
  Sale sale;

  FocusNode _focusAmount = FocusNode();
  FocusNode _focusPrice = FocusNode();

  Future<void> _saveIt() async {
    var result;
    var item = widget.item;
    print(sale.toJson());  
    if (sale != null && sale.amount > 0 && sale.price > 0) {
      result = await db.createRecord('sales', sale.toJson());
      if (result == 'ok') {
        if (item.amount - sale.amount > 0)
          item.amount -= sale.amount;
        else
          item.amount = 0;
        result = await db.updateValue('stock', item.key, 'amount', item.amount);
      }
    }
    if (result == 'ok') {
      snackbarMessageKey(
          widget.scaffoldKey, 'Item - ${item.name} sold.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    Navigator.of(context).pop();
  }

  void _checkForm() async {
    final FormState form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      await warningDialog(context, _saveIt,
          content: 'Please, Confirm to sell ${widget.item.name}!!!',
          button: 'SELL');
    }
  }

  @override
  void initState() {
    super.initState();
    _amount.text = '1';
    _price.text = widget.item.price.toStringAsFixed(2);
    sale = Sale(widget.shop.key, widget.item.key);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text(
        'SELLING - ${widget.item.name}',
        style:
            TextStyle(color: app_color, decoration: TextDecoration.underline),
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.grey[100], //const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          width: MediaQuery.of(context).size.width,
          child: _buildForm(),
        ),
      ),
      actions: _buildActionButtons(),
    );
  }

  Widget _buildForm() {
    return Form(
        key: _formkey,
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      onPressed: () {
                        var amount = int.tryParse(_amount.text);
                        setState(() {
                          _amount.text = (++amount).toStringAsFixed(0);
                        });
                      },
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: app_color, fontSize: 24),
                      decoration: InputDecoration(
                        hintText: '1',
                        labelText: 'Amount:',
                        icon: Icon(Icons.shopping_basket),
                      ),
                      autovalidate: true,
                      controller: _amount,
                      onSaved: (val) => sale.amount = int.tryParse(val),
                      validator: (val) {
                        int amount = int.tryParse(val);
                        String warn;
                        if (amount == 0) warn = "amount cannot be zero";
                        if (amount > widget.item.amount) {
                          warn = "it's more than stock";
                          _amount.text = widget.item.amount.toStringAsFixed(0);
                        }
                        ;
                        return warn;
                      },
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      textInputAction: TextInputAction.next,
                      focusNode: _focusAmount,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        var amount = int.tryParse(_amount.text);
                        amount = --amount < 1 ? 1 : amount;
                        setState(() {
                          _amount.text = (amount).toStringAsFixed(0);
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      onPressed: () {
                        var price = double.tryParse(_price.text);
                        setState(() {
                          _price.text = (++price).toStringAsFixed(2);
                        });
                      },
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: app_color, fontSize: 24),
                      decoration: InputDecoration(
                        hintText: '99.99',
                        labelText: 'Price:',
                        icon: Icon(Icons.attach_money),
                      ),
                      autovalidate: true,
                      controller: _price,
                      onSaved: (val) => sale.price = double.tryParse(val),
                      validator: (val) =>
                          val.isNotEmpty && double.tryParse(val) > 0
                              ? null
                              : 'price cannot be empty',
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      textInputAction: TextInputAction.next,
                      focusNode: _focusPrice,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        var price = double.tryParse(_price.text);
                        price = --price < 1 ? 1.00 : price;
                        setState(() {
                          _price.text = (price).toStringAsFixed(2);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  List<Widget> _buildActionButtons() {
    return [
      FlatButton(
        color: Colors.grey,
        child: Text(
          'Close',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (() {
          Navigator.of(context).pop();
        }),
      ),
      RaisedButton(
        color: app_color,
        child: Text(
          'SELL',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (() {
          _checkForm();
        }),
      ),
    ];
  }
}
