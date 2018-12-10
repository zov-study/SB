import 'package:firebase_database/firebase_database.dart';


class Shop {
  String key;
  String name;
  String location;
  String openHours;
  String contactName;
  String contactPhone;
  String image;
  bool active;
  int openDate;
  int closeDate;

  Shop(
      {this.key = '',
      this.name = '',
      this.location = '',
      this.openHours = '',
      this.contactName = '',
      this.contactPhone = '',
      this.image = '',
      this.active = false,
      this.openDate = 0,
      this.closeDate = 0});

  Shop.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        location = snapshot.value['location'],
        openHours = snapshot.value['openHours'],
        contactName = snapshot.value['contactName'],
        contactPhone = snapshot.value['contactPhone'],
        image = snapshot.value['image'],
        active = snapshot.value['active']== null? false:snapshot.value['active'],
        openDate = snapshot.value['openDate'],
        closeDate = snapshot.value['closeDate'];

  Shop.fromMapEntry(MapEntry snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        location = snapshot.value['location'],
        openHours = snapshot.value['openHours'],
        contactName = snapshot.value['contactName'],
        contactPhone = snapshot.value['contactPhone'],
        image = snapshot.value['image'],
        active = snapshot.value['active']== null? false:snapshot.value['active'],
        openDate = snapshot.value['openDate'],
        closeDate = snapshot.value['closeDate'];

  toJson() {
    return {
      "name": name,
      "location": location,
      "openHours": openHours,
      "contactName": contactName,
      "contactPhone": contactPhone,
      "image": image,
      "active": active,
      "openDate": openDate,
      "closeDate": closeDate,
    };
  }
}
