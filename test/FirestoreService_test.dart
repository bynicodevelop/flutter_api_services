import 'package:flutter_api_services/FirestoreService.dart';
import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

main() {
  group('FirestoreService.update', () {
    test('Should call update method from FirestoreServiceGetaway', () async {
      // ARRANGE
      final String uid = '123456789';
      final dynamic data = {'email': 'email'};

      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      FirestoreService firestoreService =
          FirestoreService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      await firestoreService.updateUser(uid, data);

      // ASSERT
      verify(firestoreServiceGetaway.update('users', uid, data));
    });
  });

  group('FirestoreService.getUserById', () {
    test('Should call getBy method from FirestoreServiceGetaway', () async {
      // ARRANGE
      final String uid = '123456789';

      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getById('users', uid)).thenAnswer(
        (_) => Future.value({
          'username': 'username',
          'status': 'status',
          'avatarURL': 'avatarURL',
        }),
      );

      FirestoreService firestoreService =
          FirestoreService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      Map<String, dynamic> data = await firestoreService.getUserById(uid);

      // ASSERT
      expect(data['username'], 'username');
      expect(data['status'], 'status');
      expect(data['avatarURL'], 'avatarURL');
    });

    test(
        'Should call getBy method from FirestoreServiceGetaway and return null',
        () async {
      // ARRANGE
      final String uid = '123456789';

      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getById('users', uid)).thenAnswer(
        (_) => Future.value(null),
      );

      FirestoreService firestoreService =
          FirestoreService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      Map<String, dynamic> data = await firestoreService.getUserById(uid);

      // ASSERT
      expect(data, null);
    });
  });

  group('FirestoreService.getUsersByIds', () {
    test(
        'Should call getList method from FirestoreServiceGetaway with list ids',
        () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getList('users', listIds: ['123', '456']))
          .thenAnswer(
        (_) => Future.value([
          {'uid': '123'},
          {'uid': '456'}
        ]),
      );

      FirestoreService firestoreService = FirestoreService(
        firestoreServiceGetaway: firestoreServiceGetaway,
      );

      // ACT
      List<Map<String, dynamic>> data =
          await firestoreService.getUsersByIds(['123', '456']);

      // ASSERT
      expect(data.length, 2);
    });

    test(
        'Should call getList method from FirestoreServiceGetaway with list ids',
        () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getList('users', listIds: [])).thenAnswer(
        (_) => Future.value([]),
      );

      FirestoreService firestoreService = FirestoreService(
        firestoreServiceGetaway: firestoreServiceGetaway,
      );

      // ACT
      List<Map<String, dynamic>> data =
          await firestoreService.getUsersByIds([]);

      // ASSERT
      expect(data.length, 0);
    });
  });

  group('FirestoreService.getListMessage', () {
    test('Should call getListFormDocAndSubDoc from FirestoreServiceGetaway',
        () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getListFormDocAndSubDoc(
              'chats', '123', '456'))
          .thenAnswer(
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

      FirestoreService firestoreService = FirestoreService(
        firestoreServiceGetaway: firestoreServiceGetaway,
      );

      // ACT
      Stream<List<Map<String, dynamic>>> stream =
          firestoreService.getListMessage('123', '456');

      // ASSERT
      expect((await stream.first).length, 2);
    });
  });
}

class _MockFirestoreServiceGetaway extends Mock
    implements FirestoreServiceGetaway {}
