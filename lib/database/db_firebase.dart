import 'package:firebase_database/firebase_database.dart';
import 'package:oz/modules/users/user.dart';
import 'package:oz/modules/categories/category.dart';
import 'package:oz/modules/stock/item.dart';
import 'package:oz/modules/sales/sale.dart';
import 'dart:async';

class DbInstance {
  final FirebaseDatabase _instance = FirebaseDatabase.instance;
  DatabaseReference reference;
  final bool offline;

  DbInstance({this.offline = true}) {
    _instance.setPersistenceEnabled(offline);
    reference = _instance.reference();
  }

  Future<String> createRecord(String path, Map<String, dynamic> record) async {
    String result;
    try {
      var res;
      switch (path) {
        case 'customers':
          res = await reference
              .child(path)
              .orderByChild('email')
              .equalTo(record['email'])
              .once();
          break;
        case 'shops':
          res = await reference
              .child(path)
              .orderByChild('name')
              .equalTo(record['name'])
              .once();
          break;
        case 'categories':
          res = await reference
              .child(path)
              .orderByChild('catkey')
              .equalTo(record['catkey'])
              .once();
          break;
        case 'stock':
          res = await reference
              .child(path)
              .orderByChild('itemkey')
              .equalTo(record['itemkey'])
              .once();
          break;
        case 'sales':
          res = await reference
              .child(path)
              .orderByChild('date')
              .equalTo(record['date'])
              .once();
          break;
      }
      if (res == null || res.value == null) {
        await reference.child(path).push().set(record);
        result = 'ok';
      } else {
        result = res.value.entries.elementAt(0).key;
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<String> updateRecord(
      String path, String key, Map<String, dynamic> record) async {
    String result;
    try {
      await reference.child(path).child(key).set(record);
      result = 'ok';
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<String> updateValue(
      String path, String child, String key, dynamic value) async {
    String result;
    try {
      await reference.child(path).child(child).child(key).set(value);
      result = 'ok';
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<User> getUserByUid(String uid) async {
    if (uid == null || uid.isEmpty) return null;
    User user;
    try {
      user = await reference
          .child('users')
          .orderByChild('uid')
          .equalTo(uid)
          .once()
          .then((DataSnapshot snapshot) {
        MapEntry val = snapshot.value.entries.elementAt(0);
        return User.fromMapEntry(val);
      });
    } catch (e) {
      print(e.toString());
    }

    return user;
  }

  Future<String> removeByKey(String child, String key) async {
    if (child == null || child.isEmpty) return null;
    if (key == null || key.isEmpty) return null;
    var result;
    try {
      await reference.child(child).child(key).remove();
      result = 'ok';
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<List> getCategoryList([String parent]) async {
    var result;

    try {
      if (parent == null || parent.isEmpty)
        result = await reference
            .child('categories')
            .orderByChild('level')
            .equalTo(0)
            .once()
            .then((DataSnapshot snapshot) {
          var val = snapshot.value.entries;
          var lst = new List();
          val.forEach((f) async {
            lst.add(Category.fromMapEntry(f));
          });
          return lst;
        });
      else
        result = await reference
            .child('categories')
            .orderByChild('parent')
            .equalTo(parent)
            .once()
            .then((DataSnapshot snapshot) {
          var val = snapshot.value.entries;
          var lst = new List();
          val.forEach((f) async {
            lst.add(Category.fromMapEntry(f));
          });
          return lst;
        });
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<List> getCategoryListByLevel([int level]) async {
    var result;

    try {
      result = await reference
          .child('categories')
          .orderByChild('level')
          .equalTo(level ?? 0)
          .once()
          .then((DataSnapshot snapshot) {
        var val = snapshot.value.entries;
        var lst = new List();
        val.forEach((f) async {
          lst.add(Category.fromMapEntry(f));
        });
        return lst;
      });
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<List> getItemsByKey(String value) async {
    var result;

    try {
      result = await reference
          .child('stock')
          .orderByChild('category')
          .equalTo(value)
          .once()
          .then((DataSnapshot snapshot) {
        var val = snapshot.value.entries;
        var lst = new List();
        val.forEach((f) async {
          lst.add(Item.fromMapEntry(f));
        });
        return lst;
      });
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<List> getItemsByAlpha(String value) async {
    var result;

    try {
      result = await reference
          .child('stock')
          .orderByChild('alpha')
          .equalTo(value)
          .once()
          .then((DataSnapshot snapshot) {
        var val = snapshot.value.entries;
        var lst = new List();
        val.forEach((f) async {
          lst.add(Item.fromMapEntry(f));
        });
        return lst;
      });
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<Item> getItemByKey(String key) async {
    if (key == null || key.isEmpty) return null;
    Item item;
    try {
      item = await reference
          .child('stock')
          .orderByKey()
          .equalTo(key)
          .once()
          .then((DataSnapshot snapshot) {
        MapEntry val = snapshot.value.entries.elementAt(0);
        return Item.fromMapEntry(val);
      });
    } catch (e) {
      print(e.toString());
    }
    return item;
  }

  Future<Sale> getSaleByKey(String key) async {
    if (key == null || key.isEmpty) return null;
    Sale sale;
    try {
      sale = await reference
          .child('sales')
          .orderByKey()
          .equalTo(key)
          .once()
          .then((DataSnapshot snapshot) {
        MapEntry val = snapshot.value.entries.elementAt(0);
        return Sale.fromMapEntry(val);
      });
    } catch (e) {
      print(e.toString());
    }
    return sale;
  }

  Future<List> getSalesByDate(String shop, String date) async {
    var result;
    var key = '$shop~$date';
    try {
      result = await reference
          .child('sales')
          .orderByChild('shopdate')
          .equalTo(key)
          .once()
          .then((DataSnapshot snapshot) {
        var val = snapshot.value.entries;
        var lst = new List();
        val.forEach((f) async {
          lst.add(Sale.fromMapEntry(f));
        });
        return lst;
      });
    } catch (e) {
       print(e.toString());
    }
    return result;
  }
}
