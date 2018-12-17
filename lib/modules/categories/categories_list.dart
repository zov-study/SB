import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/categories/new_category.dart';
// import 'package:oz/helpers/warning_dialog.dart';
// import 'package:oz/settings/config.dart';

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
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 800.0,
      child: FirebaseAnimatedList(
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
                  child: CategoryCard(
                      widget.categories[index], widget.scaffoldKey),
                ),
              );
            } else {
              return Container();
            }
          }),
    );
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
  final subcat = List();
  
  
  @override
    void initState() {
      super.initState();
    }
  
  void _newSubCategory(BuildContext context, Category category) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            NewCategoryForm(widget.scaffoldKey, category));
  }

  

  Widget _buildTiles(Category category) {
    if (category.subcategory == null || category.subcategory.isEmpty)
      return ListTile(
        leading: CircleAvatar(
          child: Text('${category.name[0].toUpperCase()}'),
        ),
        title: Text(
          '${category.name}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                _newSubCategory(context, category);
                debugPrint(category.name);
              },
            ),
          ],
        ),
      );

    _getSubCategory(category.key);
    return  
    ExpansionTile(
      key: PageStorageKey<Category>(category),
      leading: CircleAvatar(
        child: Text('${category.name[0].toUpperCase()}'),
      ),
      title: Text(category.name),
      children:subcat.map<Widget>(_buildTiles).toList(),

      // children: 
      // category.subcategory.map<Widget>(_buildTiles).toList(),
    );
  }


Future <void> _getSubCategory(String key) async{
    await db.reference.child('categories')
              .orderByChild('parent')
              .equalTo(key)
              .once()
              .then((DataSnapshot snapshot) {
              MapEntry val = snapshot.value.entries.elementAt(0);
              print(val);
              subcat.add(Category.fromMapEntry(val)) ; 
      });
}


  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.category);
  }
}
