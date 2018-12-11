import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:oz/settings/config.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oz/helpers/form_validation.dart';

enum ImageMode { None, Asset, Network }
enum EditMode { Info, Edit }

class ShopEditForm extends StatefulWidget {
  final Shop shop;
  final GlobalKey<ScaffoldState> scaffoldKey;
  ShopEditForm(this.scaffoldKey, this.shop);
  _ShopEditFormState createState() => _ShopEditFormState();
}

class _ShopEditFormState extends State<ShopEditForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController _openDate = TextEditingController();
  TextEditingController _openTime = TextEditingController();
  TextEditingController _closeTime = TextEditingController();
  final db = DbInstance();
  bool updated = false;
  EditMode _formMode = EditMode.Info;
  bool _isEditMode = false;
  final Shop shop = new Shop();
  final FirebaseStorage _storage = new FirebaseStorage();
  File _imageFile;
  ImageMode _imageMode = ImageMode.None;

  StorageReference _ref;
  FocusNode _shopName = FocusNode();
  FocusNode _shopLocation = FocusNode();
  FocusNode _shopOpenTime = FocusNode();
  FocusNode _shopCloseTime = FocusNode();
  FocusNode _shopContactName = FocusNode();
  FocusNode _shopContactPhone = FocusNode();
  FocusNode _shopOpenDate = FocusNode();

  Future<void> _updateIt() async {
    if (_imageFile != null)
      shop.image = await _uploadImage(_imageFile);
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
      'openDate': DateTime.now().millisecondsSinceEpoch,
      'closeDate': DateTime.now().millisecondsSinceEpoch
    });
    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'shop - ${widget.shop.name} updated successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    Navigator.of(context).pop();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(Duration(days: 30)));
    if (picked != null && picked.millisecondsSinceEpoch != shop.openDate)
      setState(() {
        _openDate.text = picked.toString().substring(0, 10);
        shop.openDate = picked.millisecondsSinceEpoch;
      });
    print('$picked = ${shop.openDate}');
  }

  Future<Null> _selectTime(BuildContext context, bool openTime) async {
    final TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (picked != null)
      setState(() {
        if (openTime) {
          _openTime.text = picked.toString().substring(10, 15);
          shop.openHours = picked.toString();
        } else {
          _closeTime.text = picked.toString().substring(10, 15);
          shop.openHours = picked.toString();
        }
      });
    print('$picked = ${shop.openHours}');
  }

  DateTime _convertToDate(String input) {
    print(input);
    try {
      var d = DateTime.parse(input);
      // var d = new DateFormat.yMd().parseStrict(input);
      print(d);
      return d;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void _checkForm() async {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      form.save();
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
      setState(() {
        shop.active = active;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    if (image == null) return null;
    StorageUploadTask uploadTask = _ref
        .child('images/${shop.key}${p.extension(image.path)}')
        .putFile(image);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String uploadImageUri = await storageTaskSnapshot.ref.getDownloadURL();
    setState(() {
      _imageMode = ImageMode.Network;
    });
    return uploadImageUri;
  }

  Future<void> _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _imageMode = ImageMode.Asset;
      });
      print(shop.image);
    }
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
    if (shop.openDate != null && shop.openDate > 0)
      _openDate.text =
          DateTime.fromMillisecondsSinceEpoch(shop.openDate).toString();
    _ref = _storage.ref();
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
                      _formMode = val ? EditMode.Edit : EditMode.Info;
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
        key: formkey,
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

            onChanged: (dt) => setState(() => _openDate.text = dt.toString()),
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
                  onChanged: (t) =>
                      setState(() => _openTime.text = t.toString()),
                  validator: (val) =>
                      val != null ? null : 'Select an open hour',
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
                  onChanged: (t) =>
                      setState(() => _closeTime.text = t.toString()),
                  validator: (val) =>
                      val != null ? null : 'Close time cannot be empty!',
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
        height: MediaQuery.of(context).size.height / 3,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: _imageMode == ImageMode.None
                ? AssetImage('assets/images/not-available.png')
                : _imageMode == ImageMode.Asset
                    ? FileImage(_imageFile)
                    : NetworkImage(shop.image),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 130.0,
            ),
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
                  onPressed:
                      _isEditMode ? () => _getImage(ImageSource.camera) : null,
                ),
                OutlineButton.icon(
                  label: Text(
                    'Gallery',
                  ),
                  icon: Icon(
                    FontAwesomeIcons.images,
                  ),
                  onPressed:
                      _isEditMode ? () => _getImage(ImageSource.gallery) : null,
                ),
              ],
            )
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
            SizedBox(width: 5.0,),
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
