import 'package:flutter/material.dart';
import 'dart:async';
import 'package:oz/helpers/send_email2url.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/settings/config.dart';
import 'email_body.dart';
import 'email_footer.dart';

class EmailForm extends StatefulWidget {
  final List emailAddresses;
  final String title;

  EmailForm({Key key, this.title, this.emailAddresses}) : super(key: key);

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _fromController = new TextEditingController();
  final TextEditingController _emailsController = new TextEditingController();
  final TextEditingController _subjectController = new TextEditingController();
  final TextEditingController _bodyController = new TextEditingController();
  final int _step = 60;
  int _lastIndex, _startIndex;

  @override
  void initState() {
    super.initState();
    _startIndex = 0;
    _lastIndex = widget.emailAddresses.length > _step
        ? _step + 1
        : widget.emailAddresses.length;
    _fillEmails(_startIndex, _lastIndex);

    _fromController.text = 'info@smartbrans.co.nz';
    _subjectController.text = 'GOOD NEWS FROM SMART BRANDS!';
    _bodyController.text = '''Dear Smart Brands lovers,
    
    
    
  Sincerelly yours,
  Smart Brands''';
  }

  void _fillEmails(int start, int last) {
    setState(() {
      _emailsController.text =
          widget.emailAddresses.sublist(start, last).join('; ');
    });
  }

  Future<Null> _sendIt() async {
    try {
      sendEmail(_emailsController.text, _subjectController.text,
          _bodyController.text);
      snackbarMessageKey(_scaffoldKey,
          'Emails have been generated successfuly!!!', app_color, 3);
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
                  content: 'Please, Confirm to send bulk emails!!!',
                  button: 'Send'))
        ],
      ),
      key: _scaffoldKey,
      body: emailBody(context, _fromController, _emailsController,
          _subjectController, _bodyController),
      bottomNavigationBar: widget.emailAddresses.length > _step
          ? emailFooter(context, bottomTapped)
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
        _lastIndex = _lastIndex + _step >= widget.emailAddresses.length
            ? widget.emailAddresses.length
            : _lastIndex + _step;
        break;
    }
    if (_startIndex < _lastIndex)
      _fillEmails(_startIndex, _lastIndex);
    else
      snackbarMessageKey(
          _scaffoldKey,
          'These are ${button == 0 ? 'first' : 'last'} $_step emails!',
          app_color,
          3);
  }
}
