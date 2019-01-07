import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/sales/sale.dart';
// import 'package:oz/helpers/warning_dialog.dart';
// import 'package:oz/helpers/snackbar_message.dart';

class DailySaleCard extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Sale sale;
  final Item item;

  DailySaleCard(this.scaffoldKey, this.sale, this.item);
  @override
  _DailySaleCardState createState() => _DailySaleCardState();
}

class _DailySaleCardState extends State<DailySaleCard> {
  bool _isEdit = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Item _item;
  Sale _sale;

  @override
  void initState() {
    super.initState();
    _sale = widget.sale;
    _item = widget.item;
  }



  Widget _buildSaleCard() {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildImage(),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: _buildTitle(),
        ),
        _buildForm(),
        _buildButtons(),
      ]),
    );
  }

  Widget _buildImage() {
    return Image(
      image: _item.image == null || _item.image.isEmpty
          ? AssetImage('assets/images/not-available.png')
          : NetworkImage(_item.image),
      fit: BoxFit.contain,
      width: 110,
    );
  }

  Widget _buildTitle() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        _item.name,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          color: app_color,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildForm() {
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
                  setState(() {
                    // _amount = item.amount;
                    // _price = item.price;
                    _isEdit = !_isEdit;
                  });
                },
              ),
              IconButton(
                  icon: Icon(_isEdit ? Icons.save : Icons.edit),
                  onPressed: !_isEdit
                      ? () {
                          if (_isEdit) _checkForm();
                          setState(() {
                            _isEdit = !_isEdit;
                          });
                        }
                      : null),
            ],
          )
        ],
      ),
    );
  }

  void _checkForm() async {
    // final FormState form = _formkey.currentState;
    // if (form.validate()) {
    //   form.save();
    //   await warningDialog(context, _saveIt,
    //       content: 'Please, Comfirm to save changes!!!', button: 'Save');
    // }
  }

  @override
    void dispose() {
      super.dispose();
      dispose();
    }
  @override
  Widget build(BuildContext context) {
    return _buildSaleCard();
  }
}
