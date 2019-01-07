import 'package:firebase_database/firebase_database.dart';

class Sale {
  String shop;
  String item;
  int amount;
  double price;
  String shopdate;
  String shopmonthyear;
  String shopyear;
  String itemdate;
  String itemmonthyear;
  String itemyear;
  String key;
  int date;

  Sale([
    this.shop = '',
    this.item = '',
    this.amount = 0,
    this.price = 0.00,
    this.shopdate = '',
    this.shopmonthyear = '',
    this.shopyear = '',
    this.itemdate = '',
    this.itemmonthyear = '',
    this.itemyear = '',
    this.key = '',
    this.date = 0,
  ]);

  Sale.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        shop = snapshot.value['shop'],
        shopdate = snapshot.value['shopdate'],
        shopmonthyear = snapshot.value['shopmonthyear'],
        shopyear = snapshot.value['shopyear'],
        item = snapshot.value['item'],
        itemdate = snapshot.value['itemdate'],
        itemmonthyear = snapshot.value['itemmonthyear'],
        itemyear = snapshot.value['itemyear'],
        amount = snapshot.value['amount'],
        price = snapshot.value['price'] / 100,
        date = snapshot.value['date'];

  Sale.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        shop = snapshot.value['shop'],
        shopdate = snapshot.value['shopdate'],
        shopmonthyear = snapshot.value['shopmonthyear'],
        shopyear = snapshot.value['shopyear'],
        item = snapshot.value['item'],
        itemdate = snapshot.value['itemdate'],
        itemmonthyear = snapshot.value['itemmonthyear'],
        itemyear = snapshot.value['itemyear'],
        amount = snapshot.value['amount'],
        price = snapshot.value['price'] / 100,
        date = snapshot.value['date'];

  toJson() {
    var _dt = new DateTime.now();
    var mm = '${_dt.month}'.padLeft(2, '0');
    var dd = '${_dt.day}'.padLeft(2, '0');
    return {
      "shop": shop,
      "shopdate": '$shop~${_dt.year}$mm$dd',
      "shopmonthyear": '$shop~${_dt.year}$mm',
      "shopyear": '$shop~${_dt.year}',
      "item": item,
      "itemdate": '$item~${_dt.year}$mm$dd',
      "itemmonthyear": '$item~${_dt.year}$mm',
      "itemyear": '$item~${_dt.year}',
      "amount": amount,
      "price": price * 100,
      "date": _dt.millisecondsSinceEpoch,
    };
  }
}
