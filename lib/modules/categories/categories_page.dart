import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/categories/categories_list.dart';
import 'package:oz/modules/categories/new_category.dart';

class CategoriesPage extends StatefulWidget {
  final String title;
  final Category parent;
  CategoriesPage({this.title, this.parent});
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> categories = List();
  List<bool> filtered = List();
  bool isSelectedAll = false;
  int found = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DbInstance();

  @override
  void initState() {
    super.initState();
    db.reference.child('categories').onChildAdded.listen(_categoryAdded);
    db.reference.child('categories').onChildChanged.listen(_categoryChanged);
    db.reference.child('categories').onChildRemoved.listen(_categoryRemoved);
  }

  void _categoryAdded(Event event) {
    setState(() {
      var cat = Category.fromSnapshot(event.snapshot);
      if (widget.parent == null && cat.level < 1) categories.add(cat);
      if (widget.parent != null &&
          widget.parent.key.isNotEmpty &&
          cat.parent == widget.parent.key) categories.add(cat);
      if (categories.isNotEmpty) {
        categories.sort((a, b) => a.name.compareTo(b.name));
        filtered.add(true);
        found = categories.length;
      }
    });
  }

  void _categoryChanged(Event event) {
    var old =
        categories.singleWhere((entry) => entry.key == event.snapshot.key);
    setState(() {
      categories[categories.indexOf(old)] =
          Category.fromSnapshot(event.snapshot);
    });
  }

  void _categoryRemoved(Event event) async {
    var old =
        categories.singleWhere((entry) => entry.key == event.snapshot.key);

    if (categories.length == 1 && old.level > 0) {
      if (old.parent != null && old.parent.isNotEmpty)
        await db.updateValue('categories', old.parent, 'subcategory', false);
      Navigator.of(context).pop();
    }
  }

  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        searchBar.getSearchAction(context),
        found == 0
            ? IconButton(
                icon: Icon(Icons.close),
                color: Colors.white,
                onPressed: (() {
                  onSubmitted('');
                }),
              )
            : Container(),
        IconButton(
          icon: Icon(Icons.add_circle),
          tooltip: 'New category',
          onPressed: () => _newCategory(),
        ),
      ],
      backgroundColor: app_color,
    );
  }

  _CategoriesPageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  void onSubmitted(String value) {
    found = 0;
    setState(() {
      for (int i = 0; i < categories.length; i++) {
        filtered[i] = categories[i].name.toLowerCase().contains(value);
        if (filtered[i]) found++;
      }
      if (found > 0)
        snackbarMessageKey(
            _scaffoldKey, "Were found $found categories", app_color, 3);
    });
  }

  void _newCategory() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            NewCategoryForm(_scaffoldKey, 'New Category', widget.parent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      body: found == -1
          ? Center(
              child: CircularProgressIndicator(),
            )
          : found > 0
              ? CategoriesList(_scaffoldKey, categories, filtered)
              : notFound(),
    );
  }
}
