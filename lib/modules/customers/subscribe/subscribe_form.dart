import 'package:flutter/material.dart';
import 'package:oz/modules/customers/customer.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/helpers/form_validation.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/settings/config.dart';
import 'terms_agreement.dart';

class SubscribeForm extends StatefulWidget {
  @override
  _SubscribeFormState createState() => _SubscribeFormState();
}

class _SubscribeFormState extends State<SubscribeForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  FocusNode _custName = FocusNode();
  FocusNode _custEmail = FocusNode();
  FocusNode _custPhone = FocusNode();
  FocusNode _custLocation = FocusNode();

  final db = DbInstance();
  bool _termsChecked = false;
  Customer customer;

  @override
  void initState() {
    super.initState();
    customer = Customer(byEmail: true, bySMS: true);
  }

  void callBack() {
    Navigator.of(context).pop();
    setState(() {
      _termsChecked = true;
    });
  }

  void subscribeIt(BuildContext context) async {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      if (_termsChecked) {
        form.save();
        if (customer.byEmail || customer.bySMS) {
          var auth = AuthProvider.of(context).auth;
          var result = await db.createRecord('customers', {
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
          if (result == 'ok')
            snackbarMessage(context,
                "Thank you ${customer.name}, you've subscribed!", app_color, 3);
          form.reset();
          customer.byEmail = true;
          customer.bySMS = true;
          setState(() {
            _termsChecked = false;
          });
        } else {
          snackbarMessage(context, 'Choose the method of delivery information',
              app_color, 3);
        }
      } else {
        snackbarMessage(
            context, 'Select agreement of Terms and Conditions', app_color, 3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7), BlendMode.dstATop),
          image: AssetImage('assets/images/poison.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                elevation: 2.0,
                margin: EdgeInsets.all(10.0),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: _buildFields() +
                          _buildSwitchChannel() +
                          _buildAgreement() +
                          _buildButtons(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    return [
      TextFormField(
          decoration: InputDecoration(
            hintText: 'Type your name',
            labelText: 'Name',
            icon: Icon(Icons.person),
          ),
          onSaved: (val) => customer.name = val.trim(),
          validator: (val) => val.isNotEmpty ? null : 'Name cannot be empty',
          initialValue: '',
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
          initialValue: '',
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
          initialValue: '',
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
        validator: (val) => val.isNotEmpty ? null : 'Location cannot be empty',
        initialValue: '',
        focusNode: _custLocation,
        textInputAction: TextInputAction.done,
      )
    ];
  }

  List<Widget> _buildSwitchChannel() {
    return [
      Container(
        margin: EdgeInsets.all(10.0),
        alignment: Alignment.bottomRight,
        child: Text(
          "be in touch",
          style: TextStyle(fontSize: 16.0),
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
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
      ])
    ];
  }

  List<Widget> _buildAgreement() {
    return [
      Divider(
        color: Colors.grey,
        indent: 30.0,
      ),
      CheckboxListTile(
        activeColor: app_color,
        title: FlatButton(
          child: Text(
            'Terms and Conditions',
            style:
                TextStyle(decoration: TextDecoration.underline, fontSize: 16.0),
          ),
          textColor: app_color,
          onPressed: (() {
            setState(() {
              _termsChecked = false;
            });
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) => termsAgreement(callBack));
          }),
        ),
        value: _termsChecked,
        onChanged: (bool value) => setState(() => _termsChecked = value),
      )
    ];
  }

  List<Widget> _buildButtons() {
    return [
      SizedBox(
        height: 40.0,
        child: RaisedButton(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Subscribe',
            style: TextStyle(fontSize: 22.0, color: Colors.white),
          ),
          color: app_color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: () => subscribeIt(context),
        ),
      )
    ];
  }
}
