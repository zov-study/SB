import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/sales/sale.dart';
import 'package:oz/helpers/warning_dialog.dart';

class DailySaleCard extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Sale sale;
  final Item item;
  final Function callBack;

  DailySaleCard(this.scaffoldKey, this.sale, this.item, this.callBack);
  @override
  _DailySaleCardState createState() => _DailySaleCardState();
}

class _DailySaleCardState extends State<DailySaleCard> {
  bool _isEdit = false;
  bool _allowSave = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  int _amount;
  double _price;
  Item _item;
  Sale _sale;

  @override
  void initState() {
    super.initState();
    _sale = widget.sale;
    _item = widget.item;
    _amount = _sale.amount;
    _price = _sale.price;
  }

  Widget _buildSaleCard() {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildSaleTime(),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: _buildTitle(),
        ),
        _buildBody(),
        _buildButtons(),
      ]),
    );
  }

  Widget _buildSaleTime() {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(_sale.date);
    return Container(
      padding: EdgeInsets.all(10),
      child: CircleAvatar(
        minRadius: 30,
        backgroundColor: app_color,
        child: Text(
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  
  Widget _buildTitle() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        _item.name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          color: app_color,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: _isEdit ? _buildForm() : _buildSaleInfo(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formkey,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Amount'),
                IconButton(
                  icon: Icon(Icons.arrow_drop_up),
                  onPressed: () {
                    setState(() {
                      if (_amount < _item.amount)
                        _amount++;
                      else
                        _amount = _item.amount;
                      _allowSave =
                          _amount != _sale.amount || _price != _sale.price;
                    });
                  },
                ),
                Text(
                  '$_amount',
                  style: TextStyle(fontSize: 20.0, color: app_color),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      if (_amount > 1)
                        _amount--;
                      else
                        _amount = 1;
                      _allowSave =
                          _amount != _sale.amount || _price != _sale.price;
                    });
                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Price'),
                IconButton(
                  icon: Icon(Icons.arrow_drop_up),
                  onPressed: () {
                    setState(() {
                      _price=_price.roundToDouble();
                      _price++;
                      _allowSave =
                          _amount != _sale.amount || _price != _sale.price;
                    });
                  },
                ),
                Text(
                  '\$${_price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 24.0,
                      color: app_color,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      _price=_price.roundToDouble();
                      if (_price > 1)
                        _price--;
                      else
                        _price = 1;
                      _allowSave =
                          _amount != _sale.amount || _price != _sale.price;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleInfo() {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text('Amount'),
              Text(
                '${_sale.amount}',
                style: TextStyle(fontSize: 20.0, color: app_color),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text('Price'),
              Text(
                '\$${_sale.price.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 24.0,
                    color: app_color,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              IconButton(
                icon: Icon(_isEdit ? Icons.clear : Icons.delete_forever),
                onPressed: () {
                  if (_isEdit)
                    _restoreState();
                  else
                    widget.callBack(_sale, true);
                },
              ),
              IconButton(
                  icon: Icon(_isEdit ? Icons.save : Icons.edit),
                  onPressed: !_isEdit
                      ? () {
                          setState(() {
                            _isEdit = !_isEdit;
                          });
                        }
                      : _isEdit && _allowSave
                          ? () async {
                              await warningDialog(context, _saveData,
                                  content:
                                      'Please, Confirm to update ${_item.name}!!!',
                                  button: 'UPDATE');
                              _restoreState();
                            }
                          : null),
            ],
          )
        ],
      ),
    );
  }

  void _restoreState() {
    setState(() {
      _amount = _sale.amount;
      _price = _sale.price;
      _isEdit = !_isEdit;
      _allowSave = false;
    });
  }

  void _saveData() {
    setState(() {
      _sale.amount = _amount;
      _sale.price = _price;
    });
    widget.callBack(_sale);
  }

  @override
  Widget build(BuildContext context) {
    return _buildSaleCard();
  }
}
