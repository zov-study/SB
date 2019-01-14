import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

//const String dbConnection='mongodb://127.0.0.1/smartbrands';
const String dbConnection = 'mongodb://dbuser:userdb@ds221228.mlab.com:21228/mlab_db';


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