import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/database/db_mongo.dart';
import 'package:oz/modules/customers/customer.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'convert_footer.dart';

class ConvertClientsPage extends StatefulWidget {
  final String title;

  ConvertClientsPage({Key key, this.title}) : super(key: key);

  @override
  _ConvertClientsPageState createState() => new _ConvertClientsPageState();
}

class _ConvertClientsPageState extends State<ConvertClientsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int countClients, countChecked = 0;
  bool isSelectedAll = false;
  bool isTransfering = false;
  List clients;
  List<bool> checkedClient;

  Future<int> getClientsList(String searchString) async {
    var lClient = await getCustomerList(searchString);
    setState(() {
      clients = lClient;
      countClients = clients.length;
      checkedClient = new List<bool>(countClients);
      for (int i = 0; i < countClients; i++) checkedClient[i] = false;
      snackbarMessageKey(
          _scaffoldKey, '$countClients clients were found!', app_color, 3);
    });
    return clients.length;
  }

  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [searchBar.getSearchAction(context)],
      backgroundColor: app_color,
    );
  }

  void onSubmitted(String value) {
    this.getClientsList(value);
  }

  _ConvertClientsPageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  @override
  void initState() {
    this.getClientsList('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      body: clients == null || clients.length == 0 || isTransfering
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildMigrateList(),
      bottomNavigationBar: convertFooter(context, bottomTapped),
    );
  }

  Future<void> transferIT() async {
    setState(() {
      isTransfering = true;
    });
    Customer customer;
    var auth = AuthProvider.of(context).auth;
    var db = DbInstance();
    int count=0;
    for (int i = 0; i < this.countClients; i++)
      if (this.checkedClient[i]) {
        customer = Customer.fromJson(this.clients[i]);
        await db.createRecord('customers', {
          'name': customer.name,
          'email': customer.email,
          'phone': customer.phone,
          'district': customer.district,
          'byEmail': true,
          'bySMS': true,
          'shopUid': 'Transfered',
          'userUid': auth.uid,
          'date': customer.date
        });
        setState(() {
          this.checkedClient[i] = false;
        });
        count++;
      }
    setState(() {
      countChecked=0;
      isTransfering = false;
    });
    snackbarMessageKey(_scaffoldKey, '$count clients successfully migrated', app_color, 3);
  }

  void bottomTapped(int button) {
    switch (button) {
      case 0:
        print('Transfer');
        if (countChecked > 0)
          warningDialog(context, transferIT,
              button: 'Migrate',
              content: 'Are you sure to migrate old customers to new ones?');
        else {
          snackbarMessageKey(_scaffoldKey,
              'No clients were selected, please make a choice!', app_color, 3);
        }
        break;
      case 1:
        setState(() {
          this.isSelectedAll = !this.isSelectedAll;
          this.isSelectedAll ? countChecked = countClients : countChecked = 0;
          for (int i = 0; i < this.countClients; i++)
            this.checkedClient[i] = this.isSelectedAll;
        });
        break;
    }
  }

  Widget _buildMigrateList() {
    return ListView.builder(
        itemCount: clients == null ? 0 : clients.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Container(
                padding: EdgeInsets.all(12.0),
                child: Column(children: <Widget>[
                  CheckboxListTile(
                    activeColor: app_color,
                    value: checkedClient[index],
                    onChanged: (bool value) {
                      setState(() {
                        checkedClient[index] = !checkedClient[index];
                        checkedClient[index] ? countChecked++ : countChecked--;
                      });
                    },
                    title: Text(
                      '${clients[index]["name"]} - ${clients[index]["district"]}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'phone: ${clients[index]["phone"]},\nemail: ${clients[index]["email"]}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ])),
          );
        });
  }
}
