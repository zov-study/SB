import 'package:flutter/material.dart';

Widget emailBody(
    BuildContext context,
    TextEditingController from,
    TextEditingController bcc,
    TextEditingController subject,
    TextEditingController message) {
  return ListView(children: <Widget>[
    Container(
      child: Column(children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
              icon: Icon(Icons.perm_identity),
              hintText: 'type your email address',
              labelText: 'From:'),
          controller: from,
          autovalidate: true,
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          decoration: InputDecoration(
              icon: Icon(Icons.email),
              hintText: 'type clients email addresses',
              labelText: 'BCC:'),
          controller: bcc,
          maxLines: 2,
        ),
        TextFormField(
          decoration: InputDecoration(
              icon: Icon(Icons.subject),
              hintText: 'type your subject',
              labelText: 'Subject:'),
          controller: subject,
          keyboardType: TextInputType.text,
        ),
        TextFormField(
          autofocus: true,
          controller: message,
          maxLines: 12,
          autocorrect: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            icon: Icon(Icons.edit),
            hintText: 'Type your email message',
            labelText: 'Email message',
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.grey, style: BorderStyle.solid, width: 5.0),
            ),
          ),
        ),
      ]),
    ),
  ]);
}
