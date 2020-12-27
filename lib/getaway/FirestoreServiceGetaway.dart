import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceGetaway {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> update(String collection, String document, dynamic data) async {
    await _firebaseFirestore.collection(collection).doc(document).update(data);
  }

  Stream<Map<String, dynamic>> getSnapshotById(
      String collection, String document) {
    Stream<DocumentSnapshot> documentSnapshot = _firebaseFirestore
        .collection(collection)
        .doc(document)
        .snapshots(includeMetadataChanges: true);

    return documentSnapshot.asyncMap((e) {
      if (!e.exists) {
        return null;
      }

      return {
        ...{'uid': e.id},
        ...e.data(),
      };
    });
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

  Future<List<Map<String, dynamic>>> getList(collection) async {
    QuerySnapshot querySnapshot =
        await _firebaseFirestore.collection(collection).get();

    return querySnapshot.docs
        .map((e) => {
              ...{'uid': e.id},
              ...e.data()
            })
        .toList();
  }

  Future<void> updateByDocument(
      String collection, String document, dynamic data) async {
    await _firebaseFirestore.collection(collection).doc(document).update(data);
  }
}
