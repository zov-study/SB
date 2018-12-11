import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/users/user.dart';
import 'package:oz/modules/users/user_edit_form.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/settings/config.dart';

class UsersList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<User> users;
  final List<bool> filtered;
  UsersList(this.scaffoldKey, this.users, this.filtered);

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final db = DbInstance();

  void _editIt(User user) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            UserEditForm(widget.scaffoldKey, user));
  }

  void _allowDisable(User user, bool active) async {
    var auth = AuthProvider.of(context).auth;
    var lastValue = user.active;
    if (user.role > auth.role) {
      await warningDialog(context, null,
          content: "Not enough rights to change this account!");
      setState(() {
        user.active = lastValue;
      });
    } else if (user.uid == auth.uid && !active) {
      await warningDialog(context, null,
          content: "Sorry, You cannot disable by yourself!");
      setState(() {
        user.active = lastValue;
      });
    } else {
      setState(() {
        user.active = active;
        db.updateValue('users', user.key, 'active', active);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 800.0,
      child: FirebaseAnimatedList(
          query: db.reference.child('users').orderByChild('name'),
          itemBuilder: (BuildContext context, DataSnapshot snaphot,
              Animation<double> animation, int index) {
            if (widget.filtered[index]) {
              return Card(
                child: GestureDetector(
                  onDoubleTap: () => _editIt(widget.users[index]),
                  child: Container(
                    padding: EdgeInsets.all(3.0),
                    child: Column(children: <Widget>[
                      SwitchListTile(
                        isThreeLine: true,
                        secondary: CircleAvatar(
                          child: Text(
                              '${widget.users[index].name[0].toUpperCase()}'),
                          backgroundColor: widget.users[index].active
                              ? app_color
                              : Colors.blueGrey,
                        ),
                        activeColor: app_color,
                        value: widget.users[index].active,
                        onChanged: ((bool value) =>
                            _allowDisable(widget.users[index], value)),
                        title: Text(
                          '${widget.users[index].name} - ${roles[widget.users[index].role]}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: widget.users[index].active
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Text('Email: ${widget.users[index].email}',style: TextStyle(fontSize: 12.0),),
                      ),
                    ]),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
