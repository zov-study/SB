import 'package:firebase_database/firebase_database.dart';

class Category {
  String key;
  String parent;
  String name;
  int level;
  String image;
  bool subcategory;
  String catkey;

  Category([
    this.name = '',
    this.key = '',
    this.parent = '',
    this.level = 0,
    this.image = '',
    this.subcategory,
    this.catkey,
  ]);

  Category.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        parent = snapshot.value['parent'],
        name = snapshot.value['name'],
        level = snapshot.value['level'],
        image = snapshot.value['image'],
        subcategory = snapshot.value['subcategory'],
        catkey = snapshot.value['catkey'];

  Category.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        parent = snapshot.value['parent'],
        name = snapshot.value['name'],
        level = snapshot.value['level'],
        image = snapshot.value['image'],
        subcategory = snapshot.value['subcategory'] ,
        catkey = snapshot.value['catkey'];

  toJson() {
    return {
      "parent": parent,
      "name": name,
      "level": level,
      "image": image,
      "subcategory": subcategory ,
      "catkey": catkey == null ? name + '_' + parent : catkey,
    };
  }
}
