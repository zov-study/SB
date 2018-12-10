import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

//const String dbConnection='mongodb://127.0.0.1/smartbrands';
const String dbConnection = 'mongodb://dbuser:userdb@ds221228.mlab.com:21228/mlab_db';



// main() async {
  // void displayIt(Map customers) {
//    print(customers);
    // print(
    //     'Name: ${customers["name"]}, District: ${customers["district"]}, Email: ${customers["email"]}, Phone: ${customers["phone"]}');
//   }

//  Db db =
//  new Db(dbConnection);
//  var customers = db.collection('customers');
//  await db.open();
//  print('''Working with clients data''');
//
  // String searchString ='a';
  // String replaceString ='Auckland, Mt.Roskill';

//  var count = await customers.count(where.match('district', searchString,caseInsensitive: true));

//  Multiply Updates
//  await customers.update(where
//      .match('district', searchString,caseInsensitive: true),
//      modify.set('district',replaceString),multiUpdate: true);

//  Update one record
//  var customer = await customers.findOne({"name": "Wizard of OZ"});
//  print("Record : $customer");
//  customer["name"] = 'Wizard of OZ';
//  customer["district"] = 'Auckland, Mt.Eden';
//  customer["email"] = 'zov-study@gmx.com';
//  customer["phone"] = '02041234567';
//
//  await customers.save(customer);

// Select by district
//  await customers
//      .find(where
//      .match('district', searchString,caseInsensitive: true)
//      .sortBy('date', descending: true))
//      .forEach(displayIt);


  // print(await getCustomerList(searchString));

//  print('Selected $count, then closing db');
//  await db.close();
// }

Future<List> getCustomerList(String searchString) async{
  Db db =  new Db(dbConnection);
  var customers = db.collection('customers');
  await db.open();

  List customersList = await customers
      .find(where
      .match('district', searchString,caseInsensitive: true)
      .sortBy('date', descending: true)
      .fields(['name','district','phone','email','date']))
      .toList();
  print(customersList[0]['date'].millisecondsSinceEpoch);
  await db.close();

  return customersList;
}