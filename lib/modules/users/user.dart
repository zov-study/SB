import 'package:firebase_database/firebase_database.dart';

enum UserRole { guest, shopAssistant, owner, admin }

class User {
  String key;
  String name;
  String email;
  int role;
  String uid;
  String image;
  bool active;
  int date;

  User(
      {this.key = '',
      this.name = '',
      this.email = '',
      this.role = 0,
      this.uid = '',
      this.active = false,
      this.date = 0});

  User.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        email = snapshot.value['email'],
        role = snapshot.value['role'],
        uid = snapshot.value['uid'],
        active = snapshot.value['active']== null? false:snapshot.value['active'],
        image = snapshot.value['image'],
        date = snapshot.value['date'];

  User.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        email = snapshot.value['email'],
        role = snapshot.value['role'],
        uid = snapshot.value['uid'],
        active = snapshot.value['active']== null? false:snapshot.value['active'],
        image = snapshot.value['image'],
        date = snapshot.value['date'];

  toJson() {
    return {
      "key": key,
      "name": name,
      "email": email,
      "role": role,
      "uid": uid,
      "active": active,
      "image": image,
      "date": date,
    };
  }
}
