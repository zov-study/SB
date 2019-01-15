import 'package:flutter/material.dart';
import 'dart:async';
import 'package:oz/helpers/send_sms.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/settings/config.dart';
import 'sms_body.dart';
import 'sms_footer.dart';

class SmsForm extends StatefulWidget {
  final List smsPhones;
  final String title;

  SmsForm({Key key, this.title, this.smsPhones}) : super(key: key);

  @override
  _SmsFormState createState() => _SmsFormState();
}

class _SmsFormState extends State<SmsForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _smsPhonesController =
      new TextEditingController();
  final TextEditingController _bodyController = new TextEditingController();
  final int _step = 20;
  int _lastIndex, _startIndex;

  @override
  void initState() {
    super.initState();
    _startIndex = 0;
    _lastIndex =
        widget.smsPhones.length > _step ? _step + 1 : widget.smsPhones.length;
    _fillPhones(_startIndex, _lastIndex);
    _bodyController.text = '''Dear Smart Brands lovers,
    
    
    
  See ya there...''';
  }

  void _fillPhones(int start, int last) {
    setState(() {
      _smsPhonesController.text =
          widget.smsPhones.sublist(start, last).join('; ');
    });
  }

  Future<void> _sendIt() async {
    try {
      sendSms(_smsPhonesController.text.split(';'), _bodyController.text);
      snackbarMessageKey(
          _scaffoldKey, 'SMS have been generated successfuly!!!', app_color, 3);
    } catch (error) {
      snackbarMessageKey(_scaffoldKey, error.toString(), app_color, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        backgroundColor: app_color,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.send),
              onPressed: () => warningDialog(context, _sendIt,
                  content: 'Please, Confirm to send SMS!!!', button: 'Send'))
        ],
      ),
      key: _scaffoldKey,
      body: smsBody(context, _smsPhonesController, _bodyController),
      bottomNavigationBar: widget.smsPhones.length > _step
          ? smsFooter(context, bottomTapped)
          : null,
    );
  }

  void bottomTapped(int button) {
    switch (button) {
      case 0:
        _lastIndex = _startIndex;
        _startIndex = _startIndex - _step <= 0 ? 0 : _startIndex - _step;
        break;
      case 1:
        _startIndex = _lastIndex;
        _lastIndex = _lastIndex + _step >= widget.smsPhones.length
            ? widget.smsPhones.length
            : _lastIndex + _step;
        break;
    }
    if (_startIndex < _lastIndex)
      _fillPhones(_startIndex, _lastIndex);
    else
      snackbarMessageKey(
          _scaffoldKey,
          'These are ${button == 0 ? 'first' : 'last'} $_step phones!',
          app_color,
          3);
  }
}
