import 'package:flutter/material.dart';

 void snackbarMessage(BuildContext context, String message, Color bgColor,int delay){
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: delay),
          backgroundColor: bgColor,
        ));
  }

  void snackbarMessageKey(GlobalKey<ScaffoldState> skfKey, String message, Color bgColor,int delay){
    skfKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: delay),
          backgroundColor: bgColor,
        ));
  }

