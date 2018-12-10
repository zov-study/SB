import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oz/database/db_firebase.dart';
import 'package:oz/modules/users/user.dart';

abstract class BaseAuth {
  bool signed, active;
  String uid, key, userName, email;
  int role;
  Future<String> signInWithEmailAndPassword({String email, String pass});
  Future<String> createUserWithEmailAndPassword(
      {String email,
      String pass,
      String userName,
      int userRole,
      bool active,
      String image});
  Future<void> requestChangePassword(String email);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  bool signed, active;
  String uid, key, userName, email;
  int role;

  final db = DbInstance();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signInWithEmailAndPassword(
      {String email: '', String pass: ''}) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: pass);
    signed = user.uid != null;
    if (signed) {
      uid = user.uid;
      await currentUser();
    }
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(
      {String email: '',
      String pass: '',
      String userName: '',
      int userRole: 0,
      bool active: false,
      String image: ''}) async {
    if (userName.isEmpty && email.isEmpty && pass.isEmpty) return null;
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: pass);
    signed = user.uid != null;
    if (signed) {
      uid = user.uid;
      if (userName.isNotEmpty)
        key = await db.createRecord('users', {
          'uid': uid,
          'name': userName,
          'email': email,
          'role': userRole,
          'active': active,
          'image': image,
          'date': DateTime.now().millisecondsSinceEpoch,
        });
    }
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user == null) return null;
    uid = user.uid;
    User tempUser = await db.getUserByUid(uid);
    key = tempUser.key;
    userName = tempUser.name;
    role = tempUser.role;
    email = tempUser.email;
    active = tempUser.active;
    signed = true;
    return uid;
  }

  Future<void> requestChangePassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    uid = key = userName = email = null;
    active = signed = false;
    role = 0;
    return _firebaseAuth.signOut();
  }
}
