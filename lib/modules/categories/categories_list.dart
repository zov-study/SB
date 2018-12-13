import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/settings/config.dart';

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
          query: db.reference.child('categories').orderByChild('name'),
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
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                          '${widget.categories[index].name[0].toUpperCase()}'),
                    ),
                    title: Text(
                      '${widget.categories[index].name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
