import 'package:flutter/material.dart';
import 'dart:io';
import 'package:oz/settings/config.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/image_tool.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/helpers/form_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class NewShopForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  NewShopForm(this.scaffoldKey);
  _NewShopFormState createState() => _NewShopFormState();
}

class _NewShopFormState extends State<NewShopForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final db = DbInstance();
  final Shop shop = new Shop();
  ImageMode _imageMode = ImageMode.None;
  File _imageFile;

  FocusNode _shopName = FocusNode();
  FocusNode _shopLocation = FocusNode();
  FocusNode _shopOpenHours = FocusNode();
  FocusNode _shopContactName = FocusNode();
  FocusNode _shopContactPhone = FocusNode();

  Future<void> _saveIt() async {
    var result;
    if (_imageFile != null)
      shop.image = await uploadImage(_imageFile, shop.key);
    if (shop.image != null && shop.image.isNotEmpty)
      setState(() {
        _imageMode = ImageMode.Network;
      });

    result = await db.createRecord('shops', shop.toJson());
    if (result != null) {
      snackbarMessageKey(widget.scaffoldKey,
          'shop - ${shop.name} created successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    Navigator.of(context).pop();
  }

  void _checkForm() async {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      form.save();
      await warningDialog(context, _saveIt,
          content: 'Please, Confirm to create new shop!!!', button: 'Create');
    }
  }

  void _allowDisable(bool active) async {
    var auth = AuthProvider.of(context).auth;
    if (auth.role < 2) {
      await warningDialog(context, null,
          content: "Not enough rights to change this account!");
      setState(() {
        shop.active = active;
      });
    } else {
      setState(() {
        shop.active = active;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text(
        'NEW shop',
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
      key: formkey,
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
                _shopLocation.unfocus();
                FocusScope.of(context).requestFocus(_shopLocation);
              }),
          TextFormField(
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
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (term) {
                _shopLocation.unfocus();
                FocusScope.of(context).requestFocus(_shopOpenHours);
              }),
          TextFormField(
              decoration: InputDecoration(
                  hintText: 'from 9am - 5pm',
                  labelText: 'Open Hours:',
                  icon: Icon(Icons.watch)),
              onSaved: (String val) => shop.openHours = val.trim(),
              validator: (val) =>
                  val.isNotEmpty ? null : 'Open hours cannot be empty',
              focusNode: _shopOpenHours,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (term) {
                _shopOpenHours.unfocus();
                FocusScope.of(context).requestFocus(_shopContactName);
              }),
          TextFormField(
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
              }),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.shop_two,
                  semanticLabel: 'Is shop active?',
                  color: Colors.grey,
                ),
                Text('Is shop active?'),
                Switch(
                  value: shop.active,
                  onChanged: (bool val) => _allowDisable(val),
                ),
              ]),
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
        onPressed: (() {
          print('${_imageFile == null ? null : _imageFile.path}');
          Navigator.of(context).pop();
        }),
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
      print(shop.image);
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
                  : NetworkImage(shop.image),
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
