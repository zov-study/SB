import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImage(File image, String key) async {
  if (image == null || key == null || key.isEmpty) return null;
  FirebaseStorage _storage = new FirebaseStorage();
  StorageReference _ref = _storage.ref();
  String ext = p.extension(image.path);
  if(ext==null || ext.isEmpty) ext=image.path.substring(-3);
  print(ext);
  String path = 'images/$key.$ext';
  print(path);
  StorageUploadTask uploadTask = _ref.child(path).putFile(image);
  StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  String uploadImageUri = await storageTaskSnapshot.ref.getDownloadURL();
  return uploadImageUri;
}

