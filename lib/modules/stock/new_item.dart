import 'package:flutter/material.dart';
import 'dart:io';
import 'package:oz/settings/config.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/barcode_scaner.dart';
import 'package:oz/helpers/image_tool.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewItemForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Category category;
  final title;
  final Item item;
  NewItemForm(this.scaffoldKey, this.title, [this.category, this.item]);
  _NewItemFormState createState() => _NewItemFormState();
}

class _NewItemFormState extends State<NewItemForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final db = DbInstance();
  final Item _item = new Item();
  ImageMode _imageMode = ImageMode.None;
  File _imageFile;
  bool _isEditMode = false;

  FocusNode _itemName = FocusNode();
  FocusNode _itemAmount = FocusNode();
  FocusNode _itemPrice = FocusNode();
  FocusNode _itemStorage = FocusNode();

  Future<void> _saveIt() async {
    var result;
    if (_imageFile != null)
      _item.image = await uploadImage(_imageFile, _item.key);
    if (_item.image != null && _item.image.isNotEmpty)
      setState(() {
        _imageMode = ImageMode.Network;
      });

    if (_isEditMode) {
      result = await db.updateRecord('stock', _item.key, _item.toJson());
    } else {
      _item.category = widget.category.key;
      result = await db.createRecord('stock', _item.toJson());
    }
    if (result == 'ok') {
      snackbarMessageKey(
          widget.scaffoldKey,
          'Item - ${_item.name} ${_isEditMode ? 'updated' : 'created'} successfully.',
          app_color,
          3);
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
          content:
              'Please, Confirm to ${_isEditMode ? 'update' : 'create new'} item!!!',
          button: _isEditMode ? 'Update' : 'Create');
    }
  }

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.item != null && widget.item.name.isNotEmpty;
    if (_isEditMode) {
      _item.key = widget.item.key;
      _item.name = widget.item.name;
      _item.alpha = widget.item.alpha;
      _item.category = widget.item.category;
      _item.itemkey = widget.item.itemkey;
      _item.amount = widget.item.amount;
      _item.price = widget.item.price;
      _item.barcode = widget.item.barcode;
      _item.storage = widget.item.storage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text(
        widget.title,
        style: TextStyle(
            color: Colors.blueGrey, decoration: TextDecoration.underline),
      ),
      content: SingleChildScrollView(
        child: Container(
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
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
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10.0),
            height: MediaQuery.of(context).size.height / 4,
            alignment: Alignment.center,
            child: _buildImage(),
          ),
          TextFormField(
              decoration: InputDecoration(
                hintText: 'item name',
                labelText: 'Name',
                icon: Icon(Icons.subtitles),
              ),
              onSaved: (val) => _item.name = val.trim(),
              validator: (val) =>
                  val.isNotEmpty ? null : 'Item name cannot be empty',
              initialValue: _item.name,
              textInputAction: TextInputAction.next,
              focusNode: _itemName,
              onFieldSubmitted: (term) {
                _itemName.unfocus();
                FocusScope.of(context).requestFocus(_itemAmount);
              }),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                    textAlign: TextAlign.right,
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      hintText: 'item amount',
                      labelText: 'Amount',
                      icon: Icon(Icons.code),
                    ),
                    onSaved: (String val) => _item.amount = int.tryParse(val),
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Item amount cannot be empty',
                    initialValue: _item.amount.toStringAsFixed(0),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    textInputAction: TextInputAction.next,
                    focusNode: _itemAmount,
                    onFieldSubmitted: (term) {
                      _itemAmount.unfocus();
                      FocusScope.of(context).requestFocus(_itemPrice);
                    }),
              ),
              Expanded(
                child: TextFormField(
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'item price',
                      labelText: 'Price',
                      icon: Icon(Icons.monetization_on),
                    ),
                    onSaved: (val) => _item.price = double.tryParse(val),
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Price cannot be empty',
                    initialValue: _item.price.toStringAsFixed(2),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.numberWithOptions(),
                    focusNode: _itemPrice,
                    onFieldSubmitted: (term) {
                      _itemPrice.unfocus();
                      FocusScope.of(context).requestFocus(_itemStorage);
                    }),
              ),
            ],
          ),
          TextFormField(
              decoration: InputDecoration(
                hintText: 'item storage',
                labelText: 'Storage',
                icon: Icon(Icons.storage),
              ),
              onSaved: (val) => _item.storage = val.trim(),
              validator: (val) =>
                  val.isNotEmpty ? null : 'Item storage cannot be empty',
              initialValue: _item.storage,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              focusNode: _itemStorage,
              onFieldSubmitted: (term) {
                _itemStorage.unfocus();
              }),
          SizedBox(
            height: 20.0,
          ),
          _item.barcode == null || _item.barcode.isEmpty
              ? OutlineButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.scanner),
                      Text(' BarCode Scanner'),
                    ],
                  ),
                  onPressed: () async {
                    var barcode = await barcodeScan();
                    if (barcode != null && barcode.isNotEmpty)
                      setState(() {
                        _item.barcode = barcode;
                      });
                  },
                )
              : TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'item barcode',
                    labelText: 'Barcode',
                    icon: Icon(Icons.scanner),
                  ),
                ),
        ],
      ),
    );
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
        onPressed: (() => Navigator.of(context).pop()),
      ),
      RaisedButton(
        color: app_color,
        child: Text(
          'Save',
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

  Future<void> _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _imageMode = ImageMode.Asset;
      });
    }
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: _imageMode == ImageMode.None
              ? AssetImage('assets/images/not-available.png')
              : _imageMode == ImageMode.Asset
                  ? FileImage(_imageFile)
                  : NetworkImage(_item.image),
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              OutlineButton.icon(
                label: Text(
                  'Camera',
                ),
                icon: Icon(
                  FontAwesomeIcons.camera,
                ),
                onPressed: () => _getImage(ImageSource.camera),
              ),
              OutlineButton.icon(
                label: Text(
                  'Gallery',
                ),
                icon: Icon(
                  FontAwesomeIcons.images,
                ),
                onPressed: () => _getImage(ImageSource.gallery),
              ),
            ],
          )
        ],
      ),
    );
  }
}
