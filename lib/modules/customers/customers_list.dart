import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/customers/customer.dart';
import 'package:oz/modules/customers/edit_form.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/settings/config.dart';

class CustomersList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Customer> customers;
  final List<bool> checkedClient;
  final List<bool> filtered;
  final Function checkIt;
  CustomersList(this.scaffoldKey, this.customers, this.checkedClient,
      this.filtered, this.checkIt);

  @override
  _CustomersListState createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersList> {
  final db = DbInstance();
  bool undo = false;

  void _editIt(Customer customer) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            CustomerEditForm(widget.scaffoldKey, customer));
  }

  void _setUndo() {
    undo = true;
  }

  void _dismissIt(int index) async {
    Customer customer = widget.customers[index];
    widget.customers.removeAt(index);
    await warningDialog(context, _setUndo,
        content: 'You dismissed - ${customer.name}, UNDO?', button: 'UNDO');
    if (undo) {
      print('Dismised $undo');
      setState(() {
        widget.customers.insert(index, customer);
      });
      undo = false;
      snackbarMessageKey(widget.scaffoldKey,
          "${customer.name} restored successfully", app_color, 3);
    } else {
      var result = await db.removeByKey('customers', customer.key);
      snackbarMessageKey(
          widget.scaffoldKey,
          result == 'ok' ? "${customer.name} dismissed successfully" : result,
          app_color,
          3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 800.0,
      child: FirebaseAnimatedList(
          query: db.reference.child('customers').orderByChild('date'),
          itemBuilder: (BuildContext context, DataSnapshot snaphot,
              Animation<double> animation, int index) {
            if (widget.filtered[index]) {
              return Dismissible(
                key: Key(widget.customers[index].key +
                    new DateTime.now().millisecondsSinceEpoch.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart)
                    _dismissIt(index);
                },
                dismissThresholds: <DismissDirection, double>{
                  DismissDirection.startToEnd: 1.0,
                  DismissDirection.endToStart: 0.7
                },
                background: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 30.0),
                    color: Colors.redAccent,
                    child: Icon(Icons.delete, color: Colors.white)),
                secondaryBackground: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 30.0),
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 48.0,
                    )),
                child: GestureDetector(
                  onDoubleTap: () => _editIt(widget.customers[index]),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(3.0),
                      child: Column(children: <Widget>[
                        CheckboxListTile(
                          isThreeLine: true,
                          secondary: CircleAvatar(
                            child: Text(
                                '${widget.customers[index].name[0].toUpperCase()}'),
                            backgroundColor: app_color,
                          ),
                          activeColor: app_color,
                          value: widget.checkedClient[index],
                          onChanged: (bool value) {
                            setState(() {
                              widget.checkedClient[index] =
                                  !widget.checkedClient[index];
                              widget.checkIt(value);    
                            });
                          },
                          title: Text(
                            '${widget.customers[index].name} - ${widget.customers[index].district}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                              'phone: ${widget.customers[index].phone},\nemail: ${widget.customers[index].email}'),
                        ),
                      ]),
                    ),
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
