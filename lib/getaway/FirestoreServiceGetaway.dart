import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceGetaway {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _mergeData(
      DocumentSnapshot documentSnapshot) async {
    if (!documentSnapshot.exists) {
      return null;
    }

    QuerySnapshot querySnapshotFollowers =
        await documentSnapshot.reference.collection('followers').get();

    QuerySnapshot querySnapshotFollowings =
        await documentSnapshot.reference.collection('followings').get();

    return {
      ...{
        'uid': documentSnapshot.id,
        'reference': documentSnapshot.reference,
        'followersList':
            querySnapshotFollowers.docs.map((e) => e.data()).toList(),
        'followingsList':
            querySnapshotFollowings.docs.map((e) => e.data()).toList(),
      },
      ...documentSnapshot.data(),
    };
  }

  Future<Map<String, dynamic>> getReference(dynamic reference) async {
    DocumentSnapshot documentSnapshot = await reference['ref'].get();

    return await _mergeData(documentSnapshot);
  }

  Future<void> update(String collection, String document, dynamic data) async {
    await _firebaseFirestore.collection(collection).doc(document).update(data);
  }

  Stream<Map<String, dynamic>> getSnapshotById(
      String collection, String document) {
    Stream<DocumentSnapshot> documentSnapshot = _firebaseFirestore
        .collection(collection)
        .doc(document)
        .snapshots(includeMetadataChanges: true);

    return documentSnapshot.asyncMap((e) async => await _mergeData(e));
  }

  Future<Map<String, dynamic>> getById(
      String collection, String document) async {
    DocumentSnapshot documentSnapshot =
        await _firebaseFirestore.collection(collection).doc(document).get();

    return await _mergeData(documentSnapshot);
  }

  Future<List<Map<String, dynamic>>> getList(String collection,
      {List<String> listIds = const []}) async {
    QuerySnapshot querySnapshot;

    CollectionReference collectionReference =
        _firebaseFirestore.collection(collection);

    if (listIds.length > 0) {
      querySnapshot = await collectionReference
          .where(FieldPath.documentId, whereIn: listIds)
          .get();
    } else {
      querySnapshot = await collectionReference.get();
    }

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

  Future<void> addDocumentInCollection(String collection, String subCollection,
      String document, Map<String, dynamic> data) async {
    await _firebaseFirestore
        .collection(collection)
        .doc(document)
        .collection(subCollection)
        .doc(data['uid'])
        .set({'ref': data['reference']});
  }

  Future<void> removeDocumentInCollection(String collection,
      String subCollection, String document, String docId) async {
    await _firebaseFirestore
        .collection(collection)
        .doc(document)
        .collection(subCollection)
        .doc(docId)
        .delete();
  }

  Future<void> updateReference(dynamic ref, dynamic data) async {
    await ref.update(data);
  }

  Future<bool> documentInCollectionExists(String collection,
      String subCollection, String document, String docId) async {
    DocumentSnapshot documentSnapshot = await _firebaseFirestore
        .collection(collection)
        .doc(document)
        .collection(subCollection)
        .doc(docId)
        .get();

    return documentSnapshot.exists;
  }

  // TODO: Changer nom getListFormDocAndSubDoc => getListFromDocAndSubDoc
  Stream<List<Map<String, dynamic>>> getListFormDocAndSubDoc(
      String collection, String document, String subDocument) {
    Stream<QuerySnapshot> querySnapshot = _firebaseFirestore
        .collection(collection)
        .doc(document)
        .collection(subDocument)
        // TODO: Rendre plus générique...
        .orderBy('sendAt')
        .snapshots();

    return querySnapshot.asyncMap(
      (event) => event.docs
          .map((e) => {
                ...{
                  'uid': e.id,
                },
                ...e.data()
              })
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getListJoinCollections(
      String collection, String collectionJoin, String document) async {
    DocumentSnapshot user =
        await _firebaseFirestore.collection(collectionJoin).doc(document).get();

    QuerySnapshot chatRefs = await user.reference.collection('chatRefs').get();

    List<Map<String, dynamic>> list = await Future.wait(
      chatRefs.docs.map((e) async {
        QuerySnapshot messages = await _firebaseFirestore
            .collection(e['ref'])
            .orderBy('sendAt', descending: true)
            .limit(1)
            .get();

        List<String> s = e['ref'].split('/');

        DocumentSnapshot userTo = await _firebaseFirestore
            .collection(collectionJoin)
            .doc(s.last)
            .get();

        if (messages.docs.length == 0) {
          return null;
        }

        return {
          ...{
            'uid': messages.docs.last.id,
            'sendAt': messages.docs.last.get('sendAt'),
            'user': {
              ...{'uid': userTo.id},
              ...userTo.data(),
            }
          },
          ...messages.docs.last.data()
        };
      }),
    );

    List<Map<String, dynamic>> newList = list.where((element) {
      return element != null;
    }).toList()
      ..sort((a, b) => b['sendAt'].compareTo(a['sendAt']));

    return newList;
  }

  Future<String> saveFromDocAndSubDoc(String collection, String document,
      String subDocument, dynamic data) async {
    String path = '$collection/$document/$subDocument';

    await _firebaseFirestore.collection(path).add(data);

    return path;
  }
}
