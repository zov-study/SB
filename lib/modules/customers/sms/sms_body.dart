import 'package:flutter/material.dart';

Widget smsBody(BuildContext context, TextEditingController phones,
    TextEditingController message) {
  return ListView(children: <Widget>[
    Container(
      child: Column(children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
              icon: Icon(Icons.people),
              hintText: 'type clients phones',
              labelText: 'Phones:'),
          controller: phones,
          keyboardType: TextInputType.phone,
          maxLines: 3,
        ),
        TextFormField(
          autofocus: true,
          controller: message,
          maxLines: 16,
          autocorrect: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            icon: Icon(Icons.sms),
            hintText: 'Type your Sms message',
            labelText: 'Sms message',
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
