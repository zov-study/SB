import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/image_tool.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oz/helpers/form_validation.dart';

enum ImageMode { None, Asset, Network }

class ShopEditForm extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  ShopEditForm(this.scaffoldKey, this.shop);
  _ShopEditFormState createState() => _ShopEditFormState();
}

class _ShopEditFormState extends State<ShopEditForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController _openDate = TextEditingController();
  TextEditingController _openTime = TextEditingController();
  TextEditingController _closeTime = TextEditingController();
  final db = DbInstance();
  bool updated = false;
  bool _isEditMode = false;
  final Shop shop = new Shop();
  File _imageFile;
  ImageMode _imageMode = ImageMode.None;

  FocusNode _shopName = FocusNode();
  FocusNode _shopLocation = FocusNode();
  FocusNode _shopContactName = FocusNode();
  FocusNode _shopContactPhone = FocusNode();

  Future<void> _updateIt() async {
    if (_imageFile != null)
      shop.image = await uploadImage(_imageFile, shop.key);
    if (shop.image != null && shop.image.isNotEmpty)
      setState(() {
        _imageMode = ImageMode.Network;
      });
    else
      shop.image = widget.shop.image;

    var result = await db.updateRecord('shops', shop.key, {
      'name': shop.name,
      'location': shop.location,
      'openHours': shop.openHours,
      'contactName': shop.contactName,
      'contactPhone': shop.contactPhone,
      'image': shop.image,
      'active': shop.active,
      'openDate': shop.openDate,
      'closeDate': shop.closeDate
    });
    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'shop - ${widget.shop.name} updated successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    setState(() {
      _isEditMode = false;
    });
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

  void _checkForm() async {
    final FormState form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      if (shop.toJson() == widget.shop.toJson())
        await warningDialog(context, null, content: 'Nothing changed!!!');
      else
        await warningDialog(context, _updateIt,
            content: 'Please, Confirm to save data!!!', button: 'Save');
    }
  }

  void _allowDisable(bool active) async {
    var auth = AuthProvider.of(context).auth;
    if (auth.role < 2) {
      await warningDialog(context, null,
          content: "Not enough rights to change this account!");
      setState(() {
        shop.active = widget.shop.active;
      });
    } else {
      await db.updateValue('shops', shop.key, 'active', active);
      await db.updateValue('shops', shop.key, 'closeDate',
          active ? 0 : DateTime.now().millisecondsSinceEpoch);
      setState(() {
        shop.active = active;
      });
    }
  }

  Future<void> _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null)
      setState(() {
        _imageFile = image;
        _imageMode = ImageMode.Asset;
      });
  }

  @override
  void initState() {
    super.initState();
    shop.key = widget.shop.key;
    shop.name = widget.shop.name;
    shop.location = widget.shop.location;
    shop.openHours = widget.shop.openHours;
    shop.contactName = widget.shop.contactName;
    shop.contactPhone = widget.shop.contactPhone;
    shop.image = widget.shop.image;
    shop.active = widget.shop.active;
    shop.openDate = widget.shop.openDate;
    shop.closeDate = widget.shop.closeDate;
    if (_imageFile != null) _imageMode = ImageMode.Asset;
    if (shop.image != null && shop.image.isNotEmpty)
      _imageMode = ImageMode.Network;
    if (shop.openDate != null && shop.openDate > 0)
      _openDate.text = DateTime.fromMillisecondsSinceEpoch(shop.openDate)
          .toString()
          .substring(0, 10);
    if (shop.openHours != null && shop.openHours.isNotEmpty) {
      var hours = shop.openHours.split('-');
      _openTime.text = hours[0];
      _closeTime.text = hours[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildForm();
  }

  Widget _buildEdit() {
    return Card(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              child: Row(
                children: <Widget>[
                  Switch(
                    value: shop.active,
                    onChanged: (bool val) => _allowDisable(val),
                  ),
                  Text(shop.active ? 'Enabled' : 'Disabled'),
                ],
              ),
            ),
            SizedBox(
              child: Row(children: <Widget>[
                Text('Edit'),
                Switch(
                  value: _isEditMode,
                  onChanged: (bool val) {
                    setState(() {
                      _isEditMode = val;
                    });
                  },
                ),
              ]),
            ),
          ]),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildEdit(),
              _buildImage(),
              _buildFields(),
              _isEditMode ? _buildActionButtons() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Container(
      child: Column(
        children: <Widget>[
          TextFormField(
              enabled: _isEditMode,
              decoration: InputDecoration(
                hintText: 'name of the shop',
                labelText: 'Shop Name',
                icon: Icon(Icons.shop),
              ),
              onSaved: (val) => shop.name = val.trim(),
              validator: (val) =>
                  val.isNotEmpty ? null : 'Name cannot be empty',
              initialValue: shop.name,
              textInputAction: TextInputAction.next,
              focusNode: _shopName,
              onFieldSubmitted: (term) {
                _shopName.unfocus();
                FocusScope.of(context).requestFocus(_shopContactName);
              }),
          DateTimePickerFormField(
            // enabled: _isEditMode,
            editable: false,
            dateOnly: true,
            format: DateFormat("yyyy-MM-dd"),
            firstDate: DateTime.now().subtract(Duration(days: 10)),
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText: 'Select the open date',
              labelText: 'Open Date',
            ),
            controller: _openDate,
            onChanged: (dt) =>
                setState(() => shop.openDate = dt.millisecondsSinceEpoch),
            validator: (val) =>
                (val != null || _convertToDate(val.toString()) != null)
                    ? null
                    : 'Select an open date',
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TimePickerFormField(
                  editable: false,
                  format: DateFormat("hh:mm a"),
                  decoration: InputDecoration(
                      hintText: '09:00',
                      labelText: 'Open Time:',
                      icon: Icon(Icons.access_time)),
                  controller: _openTime,
                  onChanged: (t) => setState(() {
                        // _openTime.text = t.toString();
                        shop.openHours = "${_openTime.text}-${_closeTime.text}";
                      }),
                  validator: (val) => val != null || _openTime != null
                      ? null
                      : 'Select an open hour',
                ),
              ),
              Expanded(
                child: TimePickerFormField(
                  editable: false,
                  format: DateFormat("hh:mm a"),
                  decoration: InputDecoration(
                      hintText: '17:00',
                      labelText: 'Close Time:',
                      icon: Icon(Icons.remove)),
                  controller: _closeTime,
                  onChanged: (t) => setState(() {
                        // _closeTime.text = t.toString();
                        shop.openHours = "${_openTime.text}-${_closeTime.text}";
                      }),
                  validator: (val) => val != null || _closeTime != null
                      ? null
                      : 'Close time cannot be empty!',
                ),
              ),
            ],
          ),
          TextFormField(
              enabled: _isEditMode,
              decoration: InputDecoration(
                  hintText: 'contact name',
                  labelText: 'Conact Name:',
                  icon: Icon(Icons.person)),
              focusNode: _shopContactName,
              initialValue: shop.contactName,
              validator: (val) =>
                  val.isNotEmpty ? null : 'Contact name cannot be empty',
              onSaved: (String val) => shop.contactName = val.trim(),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (term) {
                _shopContactName.unfocus();
                FocusScope.of(context).requestFocus(_shopContactPhone);
              }),
          TextFormField(
              enabled: _isEditMode,
              decoration: InputDecoration(
                  hintText: 'contact phone',
                  labelText: 'Phone:',
                  icon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
              focusNode: _shopContactPhone,
              initialValue: shop.contactPhone,
              validator: (val) => PhoneFieldValidator.validate(val),
              onSaved: (String val) => shop.contactPhone = val.trim(),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (term) {
                _shopContactPhone.unfocus();
                FocusScope.of(context).requestFocus(_shopLocation);
              }),
          TextFormField(
              enabled: _isEditMode,
              decoration: InputDecoration(
                hintText: 'Shop location',
                labelText: 'Address:',
                icon: Icon(Icons.location_city),
              ),
              initialValue: shop.location,
              onSaved: (String val) => shop.location = val.trim(),
              validator: (val) =>
                  val.isNotEmpty ? null : 'Name cannot be empty',
              keyboardType: TextInputType.text,
              focusNode: _shopLocation,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (term) {
                _shopLocation.unfocus();
              }),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Card(
      child: Container(
        height: 240.0,
        // MediaQuery.of(context).size.height / 3,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: _imageMode == ImageMode.None
                ? AssetImage('assets/images/not-available.png')
                : _imageMode == ImageMode.Asset
                    ? FileImage(_imageFile)
                    : NetworkImage(shop.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _isEditMode && _imageMode != ImageMode.None
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _imageMode = ImageMode.None;
                            shop.image = null;
                          });
                        },
                      ),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 130.0,
            ),
            _isEditMode
                ? Row(
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
                        onPressed: _isEditMode
                            ? () => _getImage(ImageSource.camera)
                            : null,
                      ),
                      OutlineButton.icon(
                        label: Text(
                          'Gallery',
                        ),
                        icon: Icon(
                          FontAwesomeIcons.images,
                        ),
                        onPressed: _isEditMode
                            ? () => _getImage(ImageSource.gallery)
                            : null,
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: FlatButton(
              color: Colors.grey,
              child: Text(
                'Restore',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: (() {
                // Navigator.of(context).pop();
              }),
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          RaisedButton(
            color: app_color,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            onPressed: (() {
              _checkForm();
            }),
          ),
        ],
      ),
    );
  }
}
