import 'package:firebase_database/firebase_database.dart';

class Item {
  String key;
  String name;
  String category;
  String image;
  String barcode;
  int amount;
  double price;
  String storage;
  String itemkey;

  Item([
    this.key = '',
    this.name = '',
    this.category = '',
    this.image = '',
    this.barcode = '',
    this.amount = 0,
    this.price=0.00,
    this.storage,
    this.itemkey,
  ]);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        category = snapshot.value['category'],
        image = snapshot.value['image'],
        barcode = snapshot.value['barcode'],
        amount = snapshot.value['amount'],
        price = snapshot.value['price'],
        storage = snapshot.value['storage'],
        itemkey = snapshot.value['itemkey'];

  Item.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        category = snapshot.value['category'],
        image = snapshot.value['image'],
        barcode = snapshot.value['barcode'],
        amount = snapshot.value['amount'],
        price = snapshot.value['price'],
        storage = snapshot.value['storage'],
        itemkey = snapshot.value['itemkey'];

  toJson() {
    return {
      "name": name,
      "category": category,
      "image": image,
      "barcode": barcode,
      "amount": amount,
      "price": price,
      "storage": storage ,
      "itemkey": itemkey == null ? name + '_' + category : itemkey,
    };
  }
}
