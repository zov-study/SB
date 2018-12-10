import 'package:firebase_database/firebase_database.dart';

class Customer {
  String key, name, email, phone, district, shopUid, userUid;
  bool byEmail, bySMS;
  int date;

  Customer({
    this.key = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.district = '',
    this.byEmail = false,
    this.bySMS = false,
    this.shopUid = '',
    this.userUid = '',
    this.date = 0,
  });

  Customer.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        phone = snapshot.value['phone'],
        email = snapshot.value['email'],
        district = snapshot.value['district'],
        byEmail = snapshot.value['byEmail'],
        bySMS = snapshot.value['bySMS'],
        shopUid = snapshot.value['shopUid'],
        userUid = snapshot.value['userUid'],
        date = snapshot.value['date'];

  Customer.fromJson(Map<String,dynamic> data) :
        key = data['key'],
        name = data['name'],
        phone = data['phone'],
        email = data['email'],
        district = data['district'],
        byEmail = data['byEmail'],
        bySMS = data['bySMS'],
        shopUid = data['shopUid'],
        userUid = data['userUid'],
        date = data['date'].millisecondsSinceEpoch;
     

  toJson() {
    return {
      "key": key,
      "name": name,
      "phone": phone,
      "email": email,
      "district": district,
      "byEmail": byEmail,
      "bySMS": bySMS,
      "shopUid": shopUid,
      "userUid": userUid,
      "date": date,
    };
  }
}
