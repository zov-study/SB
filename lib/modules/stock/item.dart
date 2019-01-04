import 'package:firebase_database/firebase_database.dart';

class Item {
  String key;
  String name;
  String alpha;
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
    this.alpha = '',
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
        alpha = snapshot.value['alfa'],
        category = snapshot.value['category'],
        image = snapshot.value['image'],
        barcode = snapshot.value['barcode'],
        amount = snapshot.value['amount'],
        price = snapshot.value['price']/100,
        storage = snapshot.value['storage'],
        itemkey = snapshot.value['itemkey'];

  Item.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        alpha = snapshot.value['alfa'],
        category = snapshot.value['category'],
        image = snapshot.value['image'],
        barcode = snapshot.value['barcode'],
        amount = snapshot.value['amount'],
        price = snapshot.value['price']/100,
        storage = snapshot.value['storage'],
        itemkey = snapshot.value['itemkey'];

  toJson() {
    return {
      "name": name,
      "alpha": name[0].toUpperCase(),
      "category": category,
      "image": image,
      "barcode": barcode,
      "amount": amount,
      "price": price*100,
      "storage": storage ,
      "itemkey": itemkey == null ? name + '_' + category : itemkey,
    };
  }
}
