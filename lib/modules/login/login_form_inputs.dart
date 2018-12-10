import 'package:flutter/material.dart';
import 'package:oz/helpers/form_validation.dart';

List<Widget> loginInputs(Map<String, dynamic> user, BuildContext context) {
  FocusNode _emailFocus = FocusNode();
  FocusNode _passFocus = FocusNode();
  return [
    TextFormField(
        decoration: InputDecoration(
          hintText: 'type your email',
          labelText: 'Email:',
          icon: Icon(Icons.email),
        ),
        onSaved: (String val) => user['email'] = val.trim(),
        validator: (value) => EmailFieldValidator.validate(value),
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (field) {
          _emailFocus.unfocus();
          FocusScope.of(context).requestFocus(_passFocus);
        }),
    TextFormField(
      decoration: InputDecoration(
          hintText: 'type your password',
          labelText: 'Password:',
          icon: Icon(Icons.lock_open)),
      onSaved: (String val) => user['password'] = val.trim(),
      obscureText: true,
      focusNode: _passFocus,
      textInputAction: TextInputAction.done,
      validator: (value) => PasswordFieldValidator.validate(value),
    ),
  ];
}
