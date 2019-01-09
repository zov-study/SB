import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/image_tool.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/stock/new_item.dart';
import 'package:oz/helpers/barcode_scaner.dart';

class StockList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Item> stock;
  final List<bool> filtered;
  final Category category;
  StockList(this.scaffoldKey, this.category, this.stock, this.filtered);

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  final db = DbInstance();
  Query _query;

  @override
  void initState() {
    super.initState();
    if (widget.category == null)
      _query = db.reference.child('stock').orderByChild('name');
    else
      _query = db.reference
          .child('stock')
          .orderByChild('category')
          .equalTo(widget.category.key);
  }

  void _editItem(Item item) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            NewItemForm(widget.scaffoldKey, 'New Item', widget.category, item));
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
        query: _query,
        sort: (a, b) => a.value['name'].compareTo(b.value['name']),
        padding: EdgeInsets.all(8.0),
        defaultChild: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(app_color),
            strokeWidth: 2.0,
          ),
        ),
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          if (widget.filtered[index]) {
            return GestureDetector(
              onDoubleTap: () {
                _editItem(widget.stock[index]);
              },
              child: Card(
                child: ItemCard(widget.stock[index], widget.scaffoldKey),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}

class ItemCard extends StatefulWidget {
  final Item item;
  final GlobalKey<ScaffoldState> scaffoldKey;

  ItemCard(this.item, this.scaffoldKey);
  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final _db = DbInstance();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _barcode = TextEditingController();
  int _amount;
  double _price;

  String _image;
  File _imageFile;
  ImageMode _imageMode = ImageMode.None;
  bool _isEdit = false;
  bool _allowSave = false;

  @override
  void initState() {
    super.initState();

    _name.addListener(_checkToSave);
    _name.text = widget.item.name;

    _barcode.addListener(_checkToSave);
    _barcode.text = widget.item.barcode;

    _amount = widget.item.amount;
    _price = widget.item.price;

    _image = widget.item.image;
    _imageMode = _image != null && _image.isNotEmpty
        ? ImageMode.Network
        : ImageMode.None;
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _barcode.dispose();
  }

  void _checkToSave() {
    setState(() {
      _allowSave = _name.text.isNotEmpty && _name.text != widget.item.name;
      if (!_allowSave &&
          _barcode.text.isNotEmpty &&
          _barcode.text != widget.item.barcode) _allowSave = true;
      if (!_allowSave && _amount != widget.item.amount) _allowSave = true;
      if (!_allowSave && _price != widget.item.price) _allowSave = true;
    });
  }

  Widget _buildTiles(Item item) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildImage(),
        _isEdit
            ? _buildImageButtons(item)
            : SizedBox(
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

  Widget _buildPriceInfo(Item item) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text('Amount'),
          Text(
            '$_amount',
            style: TextStyle(fontSize: 18.0, color: app_color),
          ),
          Padding(
            child: Text('Price'),
            padding: EdgeInsets.only(top: 10.0),
          ),
          Text(
            '\$${_price.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 18.0, color: app_color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Item item) {
    return Form(
      key: _formkey,
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              enabled: _isEdit,
              autovalidate: true,
              controller: _name,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  hintText: 'Item name',
                  border: _isEdit ? null : InputBorder.none),
              validator: (val) =>
                  val.isNotEmpty ? null : 'name cannot be empty',
              onFieldSubmitted: (String val) {
                if (_allowSave) _checkForm();
                setState(() {
                  _isEdit = !_isEdit;
                });
              },
            ),
            _isEdit
                ? SizedBox(
                    height: 100.0,
                    child: Slider(
                      value: _amount.toDouble(),
                      min: 0,
                      max: 100,
                      activeColor: app_color,
                      onChanged: (double val) {
                        setState(() {
                          _amount = val.toInt();
                        });
                        _checkToSave();
                      },
                    ),
                  )
                : Container(),
            _isEdit
                ? Slider(
                    value: _price,
                    min: 0,
                    max: 300,
                    activeColor: app_color,
                    onChanged: (double val) {
                      setState(() {
                        _price = val.roundToDouble();
                      });
                      _checkToSave();
                    },
                  )
                : Container(),
            _isEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OutlineButton(
                        child: Text("Scan barcode"),
                        onPressed: () async {
                          var barcode = await barcodeScan();
                          setState(() {
                            _barcode.text = barcode;
                            _checkToSave();
                          });
                        },
                      ),
                    ],
                  )
                : Text(_barcode.text),
          ],
        ),
      ),
    );
  }

  Future<void> _saveIt() async {
    var result = 'ok';
    Item item = widget.item;
    if (_name.text != null && _name.text != item.name)
      result =
          await _db.updateValue('stock', item.key, "name", _name.text.trim());
    if (_barcode.text != null && _barcode.text != item.barcode)
      result = await _db.updateValue(
          'stock', item.key, "barcode", _barcode.text.trim());
    if (_amount != null && _amount != item.amount)
      result = await _db.updateValue('stock', item.key, "amount", _amount);
    if (_price != null && _price != item.price)
      result = await _db.updateValue('stock', item.key, "price", _price * 100);

    if (_imageFile != null) _image = await uploadImage(_imageFile, item.key);
    if (_image != item.image) {
      result = await _db.updateValue('stock', item.key, "image", _image);
      setState(() {
        _imageMode = ImageMode.Network;
      });
    }

    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'Item - ${_name.text} updated successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
  }

  void _checkForm() async {
    final FormState form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      await warningDialog(context, _saveIt,
          content: 'Please, Comfirm to save changes!!!', button: 'Save');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _imageMode = ImageMode.Asset;
        _allowSave = true;
      });
    }
  }

  Widget _buildImage() {
    return Image(
      image: _imageMode == ImageMode.None
          ? AssetImage('assets/images/not-available.png')
          : _imageMode == ImageMode.Asset
              ? FileImage(_imageFile)
              : NetworkImage(_image),
      fit: BoxFit.contain,
      height: 110,
      width: 110,
    );
  }

  Widget _buildImageButtons(Item item) {
    return Column(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.clear),
            onPressed: _imageMode == ImageMode.None
                ? null
                : () {
                    setState(() {
                      _image = null;
                      _allowSave = true;
                      _imageMode = ImageMode.None;
                    });
                  }),
        IconButton(
          icon: Icon(FontAwesomeIcons.images),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
        IconButton(
            icon: Icon(FontAwesomeIcons.camera),
            onPressed: () => _getImage(ImageSource.camera)),
      ],
    );
  }

  Widget _buildButtons(Item item) {
    return Container(
      child: Row(
        children: <Widget>[
          _isEdit
              ? Column(
                  children: <Widget>[
                    _isEdit
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _name.text = item.name;
                                _barcode.text = item.barcode;
                                _amount = item.amount;
                                _price = item.price;
                                _isEdit = !_isEdit;
                              });
                            },
                          )
                        : null,
                    IconButton(
                        icon: Icon(_isEdit ? Icons.save : Icons.edit),
                        onPressed: !_isEdit || (_isEdit && _allowSave)
                            ? () {
                                if (_isEdit) _checkForm();
                                setState(() {
                                  _isEdit = !_isEdit;
                                });
                              }
                            : null),
                  ],
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEdit = !_isEdit;
                    });
                  },
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.item);
  }
}
