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
  CategoriesPage({this.title});
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
  }

  void _categoryAdded(Event event) {
    setState(() {
      var cat = Category.fromSnapshot(event.snapshot);
      // print(cat.level);
      if (cat.level==null || cat.level<1){
      categories.add(cat);
      categories.sort((a, b) => a.name.compareTo(b.name));
      filtered.add(true);
      found++;
      }
    });
  }

  void _categoryChanged(Event event) {
    var old = categories.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      categories[categories.indexOf(old)] = Category.fromSnapshot(event.snapshot);
    });
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
    print(value);
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
        builder: (BuildContext context) => NewCategoryForm(_scaffoldKey,'New Category'));
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
          : found > 0 ? CategoriesList(_scaffoldKey, categories, filtered) : notFound(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: app_color,
        child: Icon(Icons.add),
        tooltip: 'New Category.',
        onPressed: () => _newCategory(),
      ),
    );
  }
}
