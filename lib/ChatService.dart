import 'package:flutter_api_services/FirestoreService.dart';
import 'package:flutter_models/models/MessageModel.dart';

class ChatService {
  final FirestoreService firestoreService;
  String userFormUid;
  String userToUid;

  ChatService({
    this.firestoreService,
  });

  set formUid(String value) => userFormUid = value;

  set toUid(String value) => userToUid = value;

  Stream<List<MessageModel>> get messages {
    return firestoreService.getListMessage(userFormUid, userToUid).asyncMap(
          (msgs) => msgs
              .map(
                (e) => MessageModel(
                  uid: e[MessageModel.UID],
                  text: e[MessageModel.TEXT],
                  userUid: e[MessageModel.USER_UID],
                  sendAt: e[MessageModel.SEND_AT],
                ),
              )
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> get lastMessages async {
    return await firestoreService.getLastMessages(userFormUid);
  }

  Future<Map<String, String>> sendMessage(
      MessageModel messageModel, String toUid) async {
    dynamic data = {
      'text': messageModel.text,
      'userUid': messageModel.userUid,
      'sendAt': DateTime.now().millisecondsSinceEpoch,
    };

    return await firestoreService.saveMessage(toUid, data);
  }

  Future<void> updateProfiles(
      String uidFrom, String pathFrom, String uidTo, String pathTo) async {
    await firestoreService.updateChatRefs(uidFrom, pathFrom, uidTo, pathTo);

    print('chatRefs updated');
  }
}
