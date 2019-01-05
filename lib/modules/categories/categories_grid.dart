import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/categories/new_category.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/modules/stock/stock_page.dart';

class CategoriesGrid extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String parent;
  CategoriesGrid(this.scaffoldKey, [this.parent]);

  @override
  _CategoriesGridState createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  List<Category> categories = List();
  List<bool> filtered = List();
  bool isSelectedAll = false;
  int found = -1;
  final db = DbInstance();

  @override
  void initState() {
    super.initState();
    _listFillUp(widget.parent);
  }

  Future<void> _listFillUp(String parent) async {
    List lst = await db.getCategoryList(parent);
    if (lst != null && lst.isNotEmpty) {
      lst.sort((a, b) => a.name.compareTo(b.name));
      lst.forEach((f) {
        setState(() {
          categories.add(f);
          filtered.add(true);
        });
      });
    }
  }

  Widget _buildGrid() {
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          if (index < filtered.length && filtered[index]) {
            return GestureDetector(
              onTap: () => showSubCatOrItem(categories[index]),
              child: Card(
                child: CategoryGrid(categories[index], widget.scaffoldKey),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  void showSubCatOrItem(Category category) {
    if (category.subcategory != null && category.subcategory)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CategoriesGrid(widget.scaffoldKey, category.parent)));
    else
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StockPage(title: category.name, category: category)));
  }

  @override
  Widget build(BuildContext context) {
    return _buildGrid();
  }
}

class CategoryGrid extends StatefulWidget {
  final Category category;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CategoryGrid(this.category, this.scaffoldKey);
  @override
  _CategoryGridState createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  final db = DbInstance();
  String _image;
  File _imageFile;
  ImageMode _imageMode = ImageMode.None;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildGrid(Category category) {
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
                  child: Text(category.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGrid(widget.category);
  }
}
