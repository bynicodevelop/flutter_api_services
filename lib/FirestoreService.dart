import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';

class FirestoreService {
  final FirestoreServiceGetaway firestoreServiceGetaway;

  const FirestoreService({
    this.firestoreServiceGetaway,
  });

  Future<void> updateUser(String uid, dynamic data) async {
    await firestoreServiceGetaway.update('users', uid, data);
  }

  Future<Map<String, dynamic>> getUserById(String uid) async {
    return await firestoreServiceGetaway.getById('users', uid);
  }
}
