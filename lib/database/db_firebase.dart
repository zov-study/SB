import 'package:firebase_database/firebase_database.dart';
import 'package:oz/modules/users/user.dart';
import 'dart:async';

class DbInstance {
  final FirebaseDatabase _instance = FirebaseDatabase.instance;
  DatabaseReference reference;
  // final String db;
  final bool offline;

  DbInstance({this.offline = true}) {
    _instance.setPersistenceEnabled(offline);
    // if(this.offline) _instance.goOffline();
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
      }
      if (res.value == null) {
        reference.child(path).push().set(record);
        result = reference.key;
      } else {
        result = res.value.entries.elementAt(0).key;
      }
    } catch (e) {
      result = e.toString();
    }
    print('Created record key - $result');
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
    print('Updated record key - $result');
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
    print('Updated record key - $result');
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
        print(val);
        return User.fromMapEntry(val);
      });
    } catch (e) {
      print(e);
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
}