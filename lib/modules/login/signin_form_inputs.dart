import 'package:flutter/material.dart';
import 'package:oz/helpers/form_validation.dart';

enum UserRole { guest, shopAssistant, owner, admin }

List<Widget> signInInputs(Map<String, dynamic> user, BuildContext context) {
  String pass;
  FocusNode _userName = FocusNode();
  FocusNode _userEmail = FocusNode();
  FocusNode _userPass = FocusNode();
  FocusNode _userConf = FocusNode();
  print("!!! $user");
  return [
    TextFormField(
        decoration: InputDecoration(
          hintText: 'type your name',
          labelText: 'Name:',
          icon: Icon(Icons.person),
        ),
        onSaved: (String val) => user['name'] = val.trim(),
        validator: (value) =>
            value == null || value.isEmpty ? 'Name cannot be empty' : null,
        textInputAction: TextInputAction.next,
        focusNode: _userName,
        onFieldSubmitted: (term) {
          _userName.unfocus();
          FocusScope.of(context).requestFocus(_userEmail);
        }),
    TextFormField(
        decoration: InputDecoration(
          hintText: 'type your email',
          labelText: 'Email:',
          icon: Icon(Icons.email),
        ),
        onSaved: (String val) => user['email'] = val.trim(),
        validator: (value) => EmailFieldValidator.validate(value),
        keyboardType: TextInputType.emailAddress,
        focusNode: _userEmail,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (term) {
          _userEmail.unfocus();
          FocusScope.of(context).requestFocus(_userPass);
        }),
    TextFormField(
        decoration: InputDecoration(
            hintText: 'at least 6 symbols',
            labelText: 'Password:',
            icon: Icon(Icons.lock)),
        onSaved: (String val) => user['password'] = val.trim(),
        obscureText: true,
        validator: (value) {
          pass = value;
          return PasswordFieldValidator.validate(value);
        },
        focusNode: _userPass,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (term) {
          _userPass.unfocus();
          FocusScope.of(context).requestFocus(_userConf);
        }),
    TextFormField(
      decoration: InputDecoration(
          hintText: 'repeat your password',
          labelText: 'Confirm Password:',
          icon: Icon(Icons.repeat)),
      obscureText: true,
      focusNode: _userConf,
      validator: (value) {
        print('Confirm:$value, Password:$pass}');
        return value != pass ? 'Passwords is not equial' : null;
      },
      textInputAction: TextInputAction.done,
    ),
  ];
}
