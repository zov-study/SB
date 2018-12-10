import 'package:flutter/material.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:oz/settings/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oz/modules/users/user.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/not_found.dart';
import 'package:oz/modules/users/users_list.dart';

class UsersPage extends StatefulWidget {
  final String title;
  UsersPage({this.title});
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = List();
  List<bool> filtered = List();
  bool isSelectedAll = false;
  int found = -1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DbInstance();

  @override
  void initState() {
    super.initState();
    db.reference.child('users').onChildAdded.listen(_userAdded);
    db.reference.child('users').onChildChanged.listen(_userChanged);
  }

  void _userAdded(Event event) {
    setState(() {
      users.add(User.fromSnapshot(event.snapshot));
      users.sort((a, b) => a.name.compareTo(b.name));
      filtered.add(true);
      found++;
    });
  }

  void _userChanged(Event event) {
    var old = users.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      users[users.indexOf(old)] = User.fromSnapshot(event.snapshot);
    });
  }

  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        searchBar.getSearchAction(context),
        found == 0
            ? IconButton(
                icon: Icon(Icons.close),
                color: Colors.white,
                onPressed: (() {
                  onSubmitted('');
                }),
              )
            : Container(),
      ],
      backgroundColor: app_color,
    );
  }

  _UsersPageState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  void onSubmitted(String value) {
    print(value);
    found = 0;
    setState(() {
      for (int i = 0; i < users.length; i++) {
        filtered[i] = users[i].name.toLowerCase().contains(value);
        if (filtered[i]) found++;
      }
      if (found > 0)
        snackbarMessageKey(
            _scaffoldKey, "Were found $found users", app_color, 3);
    });
  }

  // void _newUser() async {
  //   await showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) => NewUserForm(_scaffoldKey));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      body: found == -1
          ? Center(
              child: CircularProgressIndicator(),
            )
          : found > 0 ? UsersList(_scaffoldKey, users, filtered) : notFound(),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: app_color,
      //   child: Icon(Icons.add),
      //   tooltip: 'New user.',
      //   onPressed: () => _newUser(),
      // ),
    );
  }
}
