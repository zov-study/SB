import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/customers/customer.dart';
import 'package:oz/modules/customers/customers_list.dart';
import 'package:oz/modules/customers/email/email_form.dart';
import 'package:oz/modules/customers/sms/sms_form.dart';

class CustomersPage extends StatefulWidget {
  final String title;
  CustomersPage({this.title});
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final db = DbInstance();
  List<Customer> customers = List();
  List<bool> checkedClient = List();
  List<bool> filtered = List();
  bool isSelectedAll = false;
  int found = -1, selected = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db.reference.child('customers').onChildAdded.listen(_customerAdded);
    db.reference.child('customers').onChildChanged.listen(_customerChanged);
    db.reference.child('customers').onChildRemoved.listen(_customerRemoved);
  }

  void _customerAdded(Event event) {
    setState(() {
      customers.add(Customer.fromSnapshot(event.snapshot));
      customers.sort((a, b) => b.date.compareTo(a.date));
      checkedClient.add(false);
      filtered.add(true);
      found++;
    });
  }

  void _customerChanged(Event event) {
    var old = customers.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      customers[customers.indexOf(old)] = Customer.fromSnapshot(event.snapshot);
    });
  }

  void _customerRemoved(Event event) {
    var old = customers.singleWhere((entry) => entry.key == event.snapshot.key);
    var index = customers.indexOf(old);
    setState(() {
      checkedClient.removeAt(index);
      customers.removeAt(index);
      found = customers.length;
      selected--;
    });
  }

  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        searchBar.getSearchAction(context),
        selected > 0
            ? IconButton(
                icon: Icon(Icons.delete),
                color: Colors.white,
                onPressed: () => warningDialog(context, _deleteIt,
                    content: 'Are you sure to delete $selected customers?',
                    button: 'Delete'),
              )
            : Container(),
        found == 0
            ? IconButton(
                icon: Icon(Icons.add_circle),
                color: Colors.white,
                onPressed: (() {
                  Navigator.pushNamed(context, '/subscribe');
                  onSubmitted('');
                }),
              )
            : Container(),
      ],
      backgroundColor: app_color,
    );
  }

  _CustomersPageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  void onSubmitted(String value) {
    found = 0;
    setState(() {
      for (int i = 0; i < customers.length; i++) {
        filtered[i] = customers[i].district.toLowerCase().contains(value);
        if (filtered[i]) found++;
      }
      if (found > 0)
        snackbarMessageKey(
            _scaffoldKey, "Were found $found customers", app_color, 3);
    });
  }

  void _checkIt(bool value) {
    setState(() {
      value ? selected++ : selected--;
      if (selected == 0) isSelectedAll = false;
    });
  }

  void _deleteIt() async {
    var result;
    var db = DbInstance();
    List customersForDelete = new List();
    for (int i = 0; i < customers.length; i++)
      if (checkedClient[i]) customersForDelete.add(customers[i]);
    if (customersForDelete.length > 0)
      for (int i = 0; i < customersForDelete.length; i++) {
        result = await db.removeByKey('customers', customersForDelete[i].key);
        snackbarMessageKey(
            _scaffoldKey,
            result == 'ok'
                ? "${customersForDelete[i].name} deleted successfully..."
                : result,
            app_color,
            1);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      key: _scaffoldKey,
      body: found == -1
          ? Center(
              child: CircularProgressIndicator(),
            )
          : found > 0
              ? CustomersList(_scaffoldKey, customers, checkedClient,filtered,_checkIt)
              : notFound(),
      bottomNavigationBar: found > 0 ? _bottomBar() : null,
    );
  }

  Widget _bottomBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.email), title: Text('Email')),
        BottomNavigationBarItem(icon: Icon(Icons.sms), title: Text('SMS')),
        BottomNavigationBarItem(
            icon: Icon(Icons.check_circle), title: Text('Select all')),
      ],
      onTap: bottomTapped,
      fixedColor: app_color,
      currentIndex: 2,
    );
  }

  void bottomTapped(int button) {
    switch (button) {
      case 0:
        List emails = new List();
        for (int i = 0; i < this.checkedClient.length; i++)
          if (this.checkedClient[i] && this.filtered[i])
            emails.add(this.customers[i].email);
        if (emails.isNotEmpty && emails.length > 0) {
          var route = new MaterialPageRoute(
            builder: (BuildContext context) =>
                EmailForm(title: 'Send Email', emailAddresses: emails),
          );
          Navigator.of(context).push(route);
        } else {
          snackbarMessageKey(_scaffoldKey,
              'No clients were selected, please make a choice!', app_color, 3);
        }
        break;
      case 1:
        List phones = new List();
        for (int i = 0; i < this.checkedClient.length; i++)
          if (this.checkedClient[i] && this.filtered[i])
            phones.add(this.customers[i].phone);
        if (phones.isNotEmpty && phones.length > 0) {
          var route = new MaterialPageRoute(
            builder: (BuildContext context) =>
                SmsForm(title: 'Send SMS', smsPhones: phones),
          );
          Navigator.of(context).push(route);
        } else {
          snackbarMessageKey(_scaffoldKey,
              'No clients were selected, please make a choice!', app_color, 3);
        }
        break;
      case 2:
        setState(() {
          this.isSelectedAll = !this.isSelectedAll;
          for (int i = 0; i < this.checkedClient.length; i++)
            this.checkedClient[i] = this.isSelectedAll;
          this.selected = this.isSelectedAll ? this.checkedClient.length : 0;
        });
        break;
    }
  }
}
