import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirestorageServiceGetaway {
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, String storagePath) async {
    Reference reference = _firebaseStorage.ref().child(storagePath);

    File file = File(path);

    UploadTask task = reference.putFile(file);

    await task;

    return await reference.getDownloadURL();
  }
}
