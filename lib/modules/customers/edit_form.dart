import 'package:flutter/material.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/helpers/form_validation.dart';
import 'package:oz/modules/customers/customer.dart';

class CustomerEditForm extends StatefulWidget {
  final Customer customer;
  final GlobalKey<ScaffoldState> scaffoldKey;
  CustomerEditForm(this.scaffoldKey, this.customer);
  _CustomerEditFormState createState() => _CustomerEditFormState();
}

class _CustomerEditFormState extends State<CustomerEditForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final db = DbInstance();
  bool updated = false;
  final Customer customer = new Customer();
  FocusNode _custName = FocusNode();
  FocusNode _custEmail = FocusNode();
  FocusNode _custPhone = FocusNode();
  FocusNode _custLocation = FocusNode();

  Future<void> updateIt() async {
    var auth = AuthProvider.of(context).auth;
    var result = await db.updateRecord('customers', customer.key, {
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'district': customer.district,
      'byEmail': customer.byEmail,
      'bySMS': customer.bySMS,
      'shopUid': 'Matamata',
      'userUid': auth.uid,
      'date': DateTime.now().millisecondsSinceEpoch
    });
    if (result[0] == 'ok') {
      snackbarMessageKey(
          widget.scaffoldKey,
          'Customer - ${widget.customer.name} updated successfully.',
          app_color,
          3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    Navigator.of(context).pop();
  }

  void checkForm() async {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      form.save();
      if (customer.byEmail || customer.bySMS) {
        await warningDialog(context, updateIt,
            content: 'Please, Confirm to update!!!', button: 'Update');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('ATTENTION!'),
                content:
                    Text('Please, Switch the delivery method by Email or SMS!'),
                actions: <Widget>[
                  RaisedButton(
                    color: app_color,
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    customer.key = widget.customer.key;
    customer.name = widget.customer.name;
    customer.email = widget.customer.email;
    customer.phone = widget.customer.phone;
    customer.district = widget.customer.district;
    customer.byEmail = widget.customer.byEmail;
    customer.bySMS = widget.customer.bySMS;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'EDIT FORM',
        style: TextStyle(
            color: Colors.blueGrey, decoration: TextDecoration.underline),
      ),
      content: SingleChildScrollView(
        child: Container(
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width,),

                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Type your name',
                      labelText: 'Name',
                      icon: Icon(Icons.person),
                    ),
                    onSaved: (val) => customer.name = val.trim(),
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Name cannot be empty',
                    initialValue: customer.name,
                    textInputAction: TextInputAction.next,
                    focusNode: _custName,
                    onFieldSubmitted: (field) {
                      _custName.unfocus();
                      FocusScope.of(context).requestFocus(_custEmail);
                    }),
                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Type your email',
                      labelText: 'Email',
                      icon: Icon(Icons.email),
                    ),
                    onSaved: (val) => customer.email = val.trim(),
                    validator: (val) => EmailFieldValidator.validate(val),
                    initialValue: customer.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    focusNode: _custEmail,
                    onFieldSubmitted: (field) {
                      _custEmail.unfocus();
                      FocusScope.of(context).requestFocus(_custPhone);
                    }),
                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Type your phone number',
                      labelText: 'Phone',
                      icon: Icon(Icons.phone),
                    ),
                    onSaved: (val) => customer.phone = val.trim(),
                    validator: (val) => PhoneFieldValidator.validate(val),
                    initialValue: customer.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    focusNode: _custPhone,
                    onFieldSubmitted: (field) {
                      _custPhone.unfocus();
                      FocusScope.of(context).requestFocus(_custLocation);
                    }),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Type your location',
                    labelText: 'Location',
                    icon: Icon(Icons.location_city),
                  ),
                  onSaved: (val) => customer.district = val,
                  validator: (val) =>
                      val.isNotEmpty ? null : 'Location cannot be empty',
                  initialValue: widget.customer.district,
                  textInputAction: TextInputAction.done,
                  focusNode: _custLocation,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(
                      Icons.email,
                      semanticLabel: 'by Email',
                      color: Colors.grey,
                    ),
                    Text(' by Email'),
                    Switch(
                      value: customer.byEmail,
                      onChanged: (bool val) {
                        setState(() {
                          customer.byEmail = val;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(
                      Icons.sms,
                      semanticLabel: 'by SMS',
                      color: Colors.grey,
                    ),
                    Text(' by SMS'),
                    Switch(
                      value: customer.bySMS,
                      onChanged: (bool val) {
                        setState(() {
                          customer.bySMS = val;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          color: Colors.grey,
          child: Text(
            'Close',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: (() {
            Navigator.of(context).pop();
          }),
        ),
        RaisedButton(
          color: app_color,
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: (() {
            checkForm();
          }),
        ),
      ],
    );
  }
}
