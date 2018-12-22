import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/categories/new_category.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoriesList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Category> categories;
  final List<bool> filtered;
  CategoriesList(this.scaffoldKey, this.categories, this.filtered);

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final db = DbInstance();

  void _editIt(Category category) {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => ShopTabs(shop: shop)));
    // await showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) =>
    //         ShopEditForm(widget.scaffoldKey, shop));
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
        query: db.reference.child('categories').orderByChild('level').endAt(0),
        itemBuilder: (BuildContext context, DataSnapshot snaphot,
            Animation<double> animation, int index) {
          if (widget.filtered[index]) {
            return Card(
              child: GestureDetector(
                onLongPress: () {
                  debugPrint(
                      'Long press to ${widget.categories[index].name}!!!');
                },
                onDoubleTap: () => _editIt(widget.categories[index]),
                child:
                    CategoryCard(widget.categories[index], widget.scaffoldKey),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}

class CategoryCard extends StatefulWidget {
  final Category category;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CategoryCard(this.category, this.scaffoldKey);
  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final db = DbInstance();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseStorage _storage = new FirebaseStorage();
  TextEditingController _name = TextEditingController();
  String _image;
  File _imageFile;
  ImageMode _imageMode = ImageMode.None;
  StorageReference _ref;
  bool _isLoaded = false;
  bool _isEdit = false;
  bool _allowSave = false;

  @override
  void initState() {
    super.initState();
    _ref = _storage.ref();
    _name.addListener(_checkToSave);
    _name.text = widget.category.name;
    _image = widget.category.image;
    _imageMode = _image != null && _image.isNotEmpty
        ? ImageMode.Network
        : ImageMode.None;
  }

  void _checkToSave() {
    setState(() {
      _allowSave = _name.text.isNotEmpty && _name.text != widget.category.name;
    });
  }

  Widget _buildTiles(Category category) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildImage(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircleAvatar(
                    backgroundColor:
                        category.level < 1 ? app_color : Colors.blueGrey,
                    child: Text('${category.name[0].toUpperCase()}'),
                  ),
                ),
                Expanded(
                  child: _buildForm(category),
                ),
                _buildButtons(category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Category category) {
    return Form(
      key: _formkey,
      child: TextFormField(
        enabled: _isEdit,
        autovalidate: true,
        controller: _name,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(5.0),
            hintText: 'category name',
            border: _isEdit ? null : InputBorder.none),
        validator: (val) => val.isNotEmpty ? null : 'name cannot be empty',
        onFieldSubmitted: (String val) {
          if (_allowSave) _checkForm();
          setState(() {
            _isEdit = !_isEdit;
          });
        },
      ),
    );
  }

  Future<void> _saveIt() async {
    var result = 'ok';
    Category category = widget.category;
    String image;
    if (_name.text != null && _name.text != category.name)
      result = await db.updateValue(
          'categories', category.key, "name", _name.text.trim());
    if (_imageFile != null)
      image = await _uploadImage(_imageFile, category.key);
    if (_image != category.image)
      result = await db.updateValue('categories', category.key, "image", image);

    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'Category - ${_name.text} updated successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    // Navigator.of(context).pop();
  }

  void _checkForm() async {
    final FormState form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      await warningDialog(context, _saveIt,
          content: 'Please, Comfirm to save changes!!!', button: 'Save');
    }
  }

  Future<String> _uploadImage(File image, String key) async {
    if (image == null) return null;
    StorageUploadTask uploadTask =
        _ref.child('images/$key${p.extension(image.path)}').putFile(image);

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
        _allowSave = true;
      });
    }
  }

  Widget _buildImage() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: _imageMode == ImageMode.None
              ? AssetImage('assets/images/not-available.png')
              : _imageMode == ImageMode.Asset
                  ? FileImage(_imageFile)
                  : NetworkImage(_image),
          fit: BoxFit.contain,
        ),
      ),
      child: _isEdit
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                OutlineButton(
                    child: Icon(FontAwesomeIcons.camera),
                    onPressed: () => _getImage(ImageSource.camera)),
                RaisedButton(
                    child: Text('Clear'),
                    onPressed: _imageMode == ImageMode.None
                        ? null
                        : () {
                            setState(() {
                              _image = null;
                              _allowSave = true;
                              _imageMode = ImageMode.None;
                            });
                          }),
                OutlineButton(
                  child: Icon(FontAwesomeIcons.images),
                  onPressed: () => _getImage(ImageSource.gallery),
                ),
              ],
            )
          : null,
    );
  }

  void _newSubCategory(Category category) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NewCategoryForm(
            widget.scaffoldKey, '${category.name}->New subcategory', category));
  }

  Widget _buildButtons(Category category) {
    return ButtonBar(
      children: <Widget>[
        _isEdit
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _name.text = category.name;
                    _image = category.image;
                    _imageMode = _image != null && _image.isNotEmpty
                        ? ImageMode.Network
                        : ImageMode.None;
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
        _isEdit
            ? null
            : IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  _newSubCategory(category);
                  debugPrint(category.name);
                },
              ),
        _isEdit
            ? null
            : IconButton(
                icon: Icon(Icons.fast_forward),
                onPressed: () {
                  print('next');
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.category);
  }
}
