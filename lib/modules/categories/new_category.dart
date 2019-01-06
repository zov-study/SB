import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:oz/settings/config.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ImageMode { None, Asset, Network }

class NewCategoryForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Category parent;
  final title;
  NewCategoryForm(this.scaffoldKey, this.title, [this.parent]);
  _NewCategoryFormState createState() => _NewCategoryFormState();
}

class _NewCategoryFormState extends State<NewCategoryForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final db = DbInstance();
  final Category category = new Category();
  final FirebaseStorage _storage = new FirebaseStorage();
  StorageReference _ref;
  ImageMode _imageMode = ImageMode.None;
  File _imageFile;

  FocusNode _categoryName = FocusNode();

  Future<void> _saveIt() async {
    var result;
    var parent = widget.parent;
    if (parent != null) {
      if (parent.subcategory == null || !parent.subcategory)
        parent.subcategory = true;
      if (parent.level == null) parent.level = 0;
      result = await db.updateRecord('categories', parent.key, parent.toJson());
      category.level = parent.level + 1;
      category.parent = parent.key;
    }
    if (_imageFile != null) category.image = await _uploadImage(_imageFile);
    result = await db.createRecord('categories', category.toJson());
    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'Category - ${category.name} created successfully.', app_color, 3);
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
          content: 'Please, Confirm to create new category!!!',
          button: 'Create');
    }
  }

  Future<String> _uploadImage(File image) async {
    if (image == null) return null;
    StorageUploadTask uploadTask = _ref
        .child('images/${category.key}${p.extension(image.path)}')
        .putFile(image);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String uploadImageUri = await storageTaskSnapshot.ref.getDownloadURL();
    setState(() {
      _imageMode = ImageMode.Network;
    });
    return uploadImageUri;
  }

  @override
  void initState() {
    super.initState();
    _ref = _storage.ref();
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
              hintText: 'category name',
              labelText: 'Name',
              icon: Icon(Icons.category),
            ),
            onSaved: (val) => category.name = val.trim(),
            validator: (val) =>
                val.isNotEmpty ? null : 'Category name cannot be empty',
            initialValue: category.name,
            textInputAction: TextInputAction.next,
            focusNode: _categoryName,
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
                  : NetworkImage(category.image),
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
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.camera,
                ),
                onPressed: () => _getImage(ImageSource.camera),
              ),
              IconButton(
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
