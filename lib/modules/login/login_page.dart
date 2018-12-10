import 'package:flutter/material.dart';
import 'package:oz/auth/auth_provider.dart';
import 'package:oz/helpers/snackbar_message.dart';
import 'package:oz/settings/config.dart';
import 'package:oz/modules/login/login_form_inputs.dart';
import 'package:oz/modules/login/signin_form_inputs.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  LoginPage({Key key, this.onSignedIn}) : super(key: key);
  LoginPageState createState() => LoginPageState();
}

enum FormType { login, signin }

class LoginPageState extends State<LoginPage> {
  Map<String, dynamic> _user = {
    'name': '',
    'email': '',
    'password': '',
    'role': 0
  };
  final formKey = GlobalKey<FormState>();
  final _scfKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  FormType _formType = FormType.login;

  bool _validateLoginForm() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print('Login: $_user');
      return true;
    } else {
      print("The form isn't validated!!!");
      return false;
    }
  }

  void _checkFirebaseLogin(BuildContext context) async {
    if (_validateLoginForm()) {
      try {
        var auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login) {
          await auth.signInWithEmailAndPassword(
              email: _user['email'], pass: _user['password']);
          print('Signed with ${auth.uid} is active ${auth.active}');
        } else {
          await auth.createUserWithEmailAndPassword(
              userName: _user['name'],
              email: _user['email'],
              pass: _user['password'],
              userRole: _user['role']);
          print('Sign in new ${auth.uid}');
          formKey.currentState.reset();
          setState(() {
            _formType = FormType.login;
          });
          snackbarMessageKey(
              _scfKey,
              'Account for ${_user['name']} created, call the manager to activate your acount!',
              app_color,
              3);
          return;
        }
        if (auth.active != null && auth.active) {
          snackbarMessageKey(
              _scfKey,
              'Welcome ${auth.userName}, nice to meet you again!',
              app_color,
              3);
          widget.onSignedIn();
        } else {
          snackbarMessageKey(
              _scfKey,
              'Sorry, but you account is disabled, call to the manager!',
              app_color,
              3);
          auth.signOut();
        }
      } catch (e) {
        var mess = e.toString().split(',');
        // print(mess[1]);
        snackbarMessageKey(_scfKey, mess[1], snackbar_color, snackbar_delay);
      }
    }
  }

  void _signIn() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.signin;
    });
  }

  void _moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scfKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7), BlendMode.dstATop),
            image: AssetImage('assets/images/poison.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  width: 150.0,
                ),
                Card(
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  elevation: 2.0,
                  margin: EdgeInsets.all(20.0),
                  child: Container(
                    padding: EdgeInsets.all(30.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: (_formType == FormType.login
                                ? loginInputs(_user, context)
                                : signInInputs(_user, context)) +
                            buildButtons(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildButtons(BuildContext contex) {
    if (_formType == FormType.login) {
      return [
        Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Login',
                  ),
                  width: 150.0,
                ),
                color: app_color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                textColor: Colors.white,
                onPressed: () => _checkFirebaseLogin(contex),
              ),
              OutlineButton(
                child: Text(
                  'Sign In',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.indigo),
                ),
                onPressed: _signIn,
              ),
            ],
          ),
        ),
      ];
    } else {
      return [
        Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Create an account',
                  ),
                   width: 200.0,
                ),
                color: app_color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                textColor: Colors.white,
                onPressed: () => _checkFirebaseLogin(contex),
              ),
              OutlineButton(
                child: Text(
                  'Have an account? Login',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.indigo),
                ),
                onPressed: _moveToLogin,
              ),
            ],
          ),
        ),
      ];
    }
  }
}
