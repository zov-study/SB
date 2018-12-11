import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:oz/settings/config.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oz/helpers/warning_dialog.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/modules/users/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserEditForm extends StatefulWidget {
  final User user;
  final GlobalKey<ScaffoldState> scaffoldKey;
  UserEditForm(this.scaffoldKey, this.user);
  _UserEditFormState createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final db = DbInstance();
  bool updated = false;
  File _imageFile;
  final User user = new User();
  final FirebaseStorage _storage = new FirebaseStorage();
  StorageReference _ref;
  FocusNode _userName = FocusNode();

  Future<void> _updateIt() async {
    if (_imageFile != null)
      user.image = await _uploadImage(_imageFile);
    else
      user.image = widget.user.image;

    var result = await db.updateRecord('users', user.key, {
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'image': user.image,
      'active': user.active,
      'uid': user.uid,
      'date': DateTime.now().millisecondsSinceEpoch
    });
    if (result == 'ok') {
      snackbarMessageKey(widget.scaffoldKey,
          'user - ${widget.user.name} updated successfully.', app_color, 3);
    } else {
      snackbarMessageKey(widget.scaffoldKey, 'Error - $result.', app_color, 3);
    }
    Navigator.of(context).pop();
  }

  void _checkForm() async {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      form.save();
      await warningDialog(context, _updateIt,
          content: 'Please, Confirm to save data!!!', button: 'Save');
    }
  }

  void _allowDisable(bool active) async {
    var auth = AuthProvider.of(context).auth;
    if (user.role > auth.role) {
      await warningDialog(context, null,
          content: "Not enough rights to change this account!");
      setState(() {
        user.active = widget.user.active;
      });
    } else if (user.uid == auth.uid && !active) {
      await warningDialog(context, null,
          content: "Sorry, You cannot disable by yourself!");
      setState(() {
        user.active = widget.user.active;
      });
    } else {
      setState(() {
        user.active = active;
      });
    }
  }

  void _checkRoles(int role) async {
    var auth = AuthProvider.of(context).auth;
    if (role > auth.role) {
      await warningDialog(context, null,
          content: "Not enough rights to change to <<${roles[role]}>> role!");
      setState(() {
        user.role = widget.user.role;
      });
    } else {
      setState(() {
        user.role = role;
      });
    }
  }

  void _changePassword() async {
    var auth = AuthProvider.of(context).auth;
    auth.requestChangePassword(user.email);
    warningDialog(context, null,
        content: 'Check the email to change password!', title: 'INFO');
    print('Change Password requested!!!');
  }

  void _requestToChangePassword() async {
    await warningDialog(context, _changePassword,
        content: 'Please, Confirm to send request to change password!!!',
        button: 'Send');
  }

  Future<String> _uploadImage(File image) async {
    if (image == null) return null;
    StorageUploadTask uploadTask = _ref
        .child('images/${user.uid}${p.extension(image.path)}')
        .putFile(image);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String uploadImageUri = await storageTaskSnapshot.ref.getDownloadURL();

    return uploadImageUri;
  }

  Future<void> _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
        user.image = 'changed';
      });
      print(user.image);
    }
  }

  @override
  void initState() {
    super.initState();
    user.key = widget.user.key;
    user.name = widget.user.name;
    user.email = widget.user.email;
    user.image = widget.user.image;
    user.uid = widget.user.uid;
    user.role = widget.user.role;
    user.active = widget.user.active;
    user.date = widget.user.date;
    _ref = _storage.ref();
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
          child: _buildForm(),
        ),
      ),
      actions: _buildActionButtons(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formkey,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10.0),
            height: MediaQuery.of(context).size.height / 4,
            alignment: Alignment.center,
            child: _buildImage(),
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Type your name',
              labelText: 'Name',
              icon: Icon(Icons.person),
            ),
            onSaved: (val) => user.name = val.trim(),
            validator: (val) => val.isNotEmpty ? null : 'Name cannot be empty',
            initialValue: user.name,
            textInputAction: TextInputAction.next,
            focusNode: _userName,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                Icons.people,
                color: Colors.grey,
              ),
              Text('Role:'),
              DropdownButton<String>(
                value: roles[user.role],
                items: roles.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: ((value) => _checkRoles(roles.indexOf(value))),
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  semanticLabel: 'Is account active?',
                  color: Colors.grey,
                ),
                Text('Is account active?'),
                Switch(
                  value: user.active,
                  onChanged: (bool val) =>_allowDisable(val),
                ),
              ]),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: user.image == null
              ? AssetImage('assets/images/not-available.png')
              : user.image == 'changed'
                  ? FileImage(_imageFile)
                  : NetworkImage(user.image),
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              OutlineButton.icon(
                label: Text(
                  '',
                ),
                icon: Icon(
                  FontAwesomeIcons.camera,
                ),
                onPressed: () => _getImage(ImageSource.camera),
              ),
              OutlineButton.icon(
                label: Text(
                  '',
                ),
                icon: Icon(
                  FontAwesomeIcons.images,
                ),
                onPressed: () => _getImage(ImageSource.gallery),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    return [
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
        color: Colors.blueGrey,
        child: Text(
          'Password',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (() {
          _requestToChangePassword();
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
          _checkForm();
        }),
      ),
    ];
  }
}
