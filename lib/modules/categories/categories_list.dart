import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/categories/new_category.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/image_tool.dart';
import 'package:oz/settings/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oz/modules/categories/categories_page.dart';
import 'package:oz/modules/stock/stock_page.dart';

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
  Query _query;

  @override
  void initState() {
    super.initState();
    if (widget.categories[0].level < 1)
      _query = db.reference.child('categories').orderByChild('level').endAt(0);
    else
      _query = db.reference
          .child('categories')
          .orderByChild('parent')
          .equalTo(widget.categories[0].parent);
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
          if (index < widget.filtered.length && widget.filtered[index]) {
            return Card(
              child: GestureDetector(
                onTap: () =>
                    showSubCatOrItem(context, widget.categories[index]),
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
  TextEditingController _name = TextEditingController();
  String _image;
  File _imageFile;
  ImageMode _imageMode = ImageMode.None;
  bool _isEdit = false;
  bool _allowSave = false;
  bool _allowDelete = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(_checkToSave);
    _updateVars();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateVars();
  }

  void _updateVars() {
    setState(() {
      _name.text = widget.category.name;
      _image = widget.category.image;
      _imageMode = _image != null && _image.isNotEmpty
          ? ImageMode.Network
          : ImageMode.None;
    });
    _checkToDelete();
  }

  void _checkToDelete() async {
    var subcat = widget.category.subcategory;
    var stock = await db.getItemsByKey(widget.category.key);
    setState(() {
      _allowDelete =
          (subcat == null || !subcat) && (stock == null || stock.isEmpty);
    });
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
      child: _isEdit
          ? TextFormField(
              autovalidate: true,
              controller: _name,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5.0),
                hintText: 'category name',
              ),
              validator: (val) =>
                  val.isNotEmpty ? null : 'name cannot be empty',
              onFieldSubmitted: (String val) {
                if (_allowSave) _checkForm();
                setState(() {
                  _isEdit = !_isEdit;
                });
              },
            )
          : Text(category.name),
    );
  }

  Future<void> _saveIt() async {
    var result = 'ok';
    Category category = widget.category;
    if (_name.text != null && _name.text != category.name)
      result = await db.updateValue(
          'categories', category.key, "name", _name.text.trim());
    if (_imageFile != null)
      _image = await uploadImage(_imageFile, category.key);
    if (_image != category.image) {
      result =
          await db.updateValue('categories', category.key, "image", _image);
    }

    if (result == 'ok') {
      _updateVars();
      snackbarMessageKey(widget.scaffoldKey,
          'Category - ${_name.text} updated successfully.', app_color, 3);
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
          : _allowDelete
              ? Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _confirmToRemove(),
                        )
                      ],
                    ),
                  ],
                )
              : null,
    );
  }

  Future<void> _removeIt() async {
    String name = widget.category.name;
    var result = await db.removeByKey('categories', widget.category.key);

    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'Category - $name was deleted successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
  }

  void _confirmToRemove() async {
    await warningDialog(context, _removeIt,
        content:
            'Please, Comfirm the category "${widget.category.name}" - should be removed!!!',
        button: 'Remove');
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
                  _updateVars();
                  setState(() {
                    _isEdit = !_isEdit;
                  });
                },
              )
            : null,
        IconButton(
            icon: Icon(_isEdit ? Icons.save : Icons.edit),
            onPressed: !_isEdit || (_isEdit && _allowSave)
                ? () {
                    if (_isEdit)
                      _checkForm();
                    else
                      _updateVars();
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

void showSubCatOrItem(BuildContext context, Category category) {
  if (category.subcategory != null && category.subcategory)
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CategoriesPage(title: category.name, parent: category)));
  else
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StockPage(
                title: '${category.name} - STOCK', category: category)));
}
