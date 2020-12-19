import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceGetaway {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> update(String collection, String document, dynamic data) async {
    await _firebaseFirestore.collection(collection).doc(document).update(data);
  }

  Future<Map<String, dynamic>> getById(
      String collection, String document) async {
    DocumentSnapshot documentSnapshot =
        await _firebaseFirestore.collection(collection).doc(document).get();

    if (!documentSnapshot.exists) {
      return null;
    }

    return documentSnapshot.data();
  }
}
