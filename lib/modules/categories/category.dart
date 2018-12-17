import 'package:firebase_database/firebase_database.dart';

class Category {
  String key;
  String parent;
  String name;
  int level;
  String image;
  List<String> subcategory;

  Category(
      [this.name = '',
      this.key = '',
      this.parent = '',
      this.level = 0,
      this.image = '',
      this.subcategory ]);

  Category.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        parent = snapshot.value['parent'],
        name = snapshot.value['name'],
        level = snapshot.value['level'],
        image = snapshot.value['image'],
        subcategory = snapshot.value['subcategory']==null ? null: snapshot.value['subcategory'].toString().split(',');

  Category.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        parent = snapshot.value['parent'],
        name = snapshot.value['name'],
        level = snapshot.value['level'],
        image = snapshot.value['image'],
        subcategory = snapshot.value['subcategory']==null ? null: snapshot.value['subcategory'].toString().split(',');



  toJson() {
    return {
      "parent":parent,
      "name": name,
      "level" :level,
      "image": image,
      "subcategory": subcategory==null || subcategory.isEmpty? null:  subcategory.toString(),
    };
  }
}
