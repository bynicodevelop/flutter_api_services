import 'package:flutter_api_services/ChatService.dart';
import 'package:flutter_api_services/FirestoreService.dart';
import 'package:flutter_models/models/MessageModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

main() {
  group('ChatService.messages', () {
    test('Should return a list of messages', () async {
      // ARRANGE
      _MockFirestoreService firestoreService = _MockFirestoreService();

      when(firestoreService.getListMessage('123', '456')).thenAnswer(
        (_) => Stream.fromFuture(
          Future.value([
            {
              'uid': '123',
            },
            {
              'uid': '456',
            }
          ]),
        ),
      );

      ChatService chatService = ChatService(
        firestoreService: firestoreService,
      );

      chatService.userFormUid = '123';
      chatService.userToUid = '456';

      // ACT
      Stream<List<MessageModel>> stream = chatService.messages;

      List<MessageModel> messages = await stream.first;

      // ASSERT
      expect(messages.length, 2);
      expect(messages[0].uid, '123');
      expect(messages[1].uid, '456');
    });

    test('Should return an empty list ', () async {
      // ARRANGE
      _MockFirestoreService firestoreService = _MockFirestoreService();

      when(firestoreService.getListMessage('123', '456')).thenAnswer(
        (_) => Stream.fromFuture(
          Future.value([]),
        ),
      );

      ChatService chatService = ChatService(
        firestoreService: firestoreService,
      );

      chatService.userFormUid = '123';
      chatService.userToUid = '456';

      // ACT
      Stream<List<MessageModel>> stream = chatService.messages;

      List<MessageModel> messages = await stream.first;

      // ASSERT
      expect(messages.length, 0);
    });
  });
}

class _MockFirestoreService extends Mock implements FirestoreService {}
