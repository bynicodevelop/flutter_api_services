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

  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> ids) async {
    return await firestoreServiceGetaway.getList('users', listIds: ids);
  }

  Stream<List<Map<String, dynamic>>> getListMessage(userFromUid, userToUid) {
    return firestoreServiceGetaway.getListFormDocAndSubDoc(
        'chats', userFromUid, userToUid);
  }

  Future<List<Map<String, dynamic>>> getLastMessages(userFromUid) async {
    return await firestoreServiceGetaway.getListJoinCollections(
        'chats', 'users', userFromUid);
  }

  Future<Map<String, String>> saveMessage(String to, dynamic data) async {
    String pathFrom = await firestoreServiceGetaway.saveFromDocAndSubDoc(
        'chats', data['userUid'], to, data);

    String pathTo = await firestoreServiceGetaway.saveFromDocAndSubDoc(
        'chats', to, data['userUid'], data);

    return {
      'pathFrom': pathFrom,
      'pathTo': pathTo,
    };
  }

  Future<void> updateChatRefs(
      String uidFrom, String pathFrom, String uidTo, String pathTo) async {
    await firestoreServiceGetaway
        .saveFromDocAndSubDoc('users', uidFrom, 'chatRefs', {'ref': pathFrom});

    await firestoreServiceGetaway
        .saveFromDocAndSubDoc('users', uidTo, 'chatRefs', {'ref': pathTo});
  }
}
