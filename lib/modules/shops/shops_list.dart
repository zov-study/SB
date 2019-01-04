import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/shops/shop.dart';
import 'package:oz/modules/tabs/shop_tabs.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/settings/config.dart';

class ShopsList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Shop> shops;
  final List<bool> filtered;
  ShopsList(this.scaffoldKey, this.shops, this.filtered);

  @override
  _ShopsListState createState() => _ShopsListState();
}

class _ShopsListState extends State<ShopsList> {
  final db = DbInstance();

  void _editIt(Shop shop) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ShopTabs(shop: shop)));
  }

  void _allowDisable(Shop shop, bool active) async {
    var auth = AuthProvider.of(context).auth;
    var lastValue = shop.active;
    if (auth.role < 2) {
      await warningDialog(context, null,
          content: "Not enough rights to change this account!");
      setState(() {
        shop.active = lastValue;
      });
    } else {
      await db.updateValue('shops', shop.key, 'active', active);
      await db.updateValue('shops', shop.key, 'closeDate',
          active ? 0 : DateTime.now().millisecondsSinceEpoch);
      setState(() {
        shop.active = active;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 800.0,
      child: FirebaseAnimatedList(
          query: db.reference.child('shops').orderByChild('name'),
          itemBuilder: (BuildContext context, DataSnapshot snaphot,
              Animation<double> animation, int index) {
            if (widget.filtered[index]) {
              return GestureDetector(
                onTap: () => _editIt(widget.shops[index]),
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(3.0),
                    child: Column(children: <Widget>[
                      ListTile(
                        isThreeLine: true,
                        leading: CircleAvatar(
                          child: Text(
                              '${widget.shops[index].name[0].toUpperCase()}'),
                          backgroundColor: widget.shops[index].active
                              ? app_color
                              : Colors.blueGrey,
                        ),
                        trailing: Switch(
                        activeColor: app_color,
                        value: widget.shops[index].active,
                        onChanged: ((bool value) =>
                            _allowDisable(widget.shops[index], value))),
                        title: Text(
                          '${widget.shops[index].name} - ${widget.shops[index].location}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: widget.shops[index].active
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                            'Contact name: ${widget.shops[index].contactName}\nphone: ${widget.shops[index].contactPhone}'),
                      ),
                    ]),
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
