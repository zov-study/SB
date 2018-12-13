import 'package:firebase_database/firebase_database.dart';

class Category {
  String key;
  String name;
  String image;

  Category({
    this.key = '',
    this.name = '',
    this.image = '',
  });

  Category.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        image = snapshot.value['image'];

  Category.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        image = snapshot.value['image'];

  toJson() {
    return {
      "name": name,
      "image": image,
    };
  }
}
