import 'package:flutter_api_services/UsersService.dart';
import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';
import 'package:flutter_models/models/UserModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

main() {
  group('UsersService.getProfile', () {
    test(
        'Should call getSnapshotById from FirestoreServiceGetaway with good id',
        () async {
      // ARRANGE
      String uid = '123';

      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getSnapshotById('users', uid)).thenAnswer(
        (_) => Stream.value({
          'uid': uid,
          'username': 'username',
          'status': 'status',
          'avatarURL': 'avatarURL',
        }),
      );

      final UsersService usersService =
          UsersService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      Stream<UserModel> stream = usersService.getUserProfile(uid);

      UserModel userModel = await stream.first;

      // ASSERT
      expect(userModel, isInstanceOf<UserModel>());

      expect(userModel.uid, uid);
      expect(userModel.username, 'username');
      expect(userModel.status, 'status');
      expect(userModel.avatarURL, 'avatarURL');
    });

    test(
        'Should call getSnapshotById from FirestoreServiceGetaway with wrong id',
        () async {
      // ARRANGE
      String uid = '123';

      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getSnapshotById('users', uid)).thenAnswer(
        (_) => Stream.value(null),
      );

      final UsersService usersService =
          UsersService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      Stream<UserModel> stream = usersService.getUserProfile(uid);

      UserModel userModel = await stream.first;

      // ASSERT
      expect(userModel, null);
    });
  });

  group('UsersService.get', () {
    test('Should call getList from FirestoreServiceGetaway with 2 results',
        () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getList('users'))
          .thenAnswer((_) => Future.value([
                {
                  UserModel.UID: '12345678',
                  UserModel.EMAIL: 'j.doe@domain.tld',
                },
                {
                  UserModel.UID: '98765',
                  UserModel.EMAIL: 'jane.die@domain.tld',
                },
              ]));

      final UsersService usersService =
          UsersService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      List<UserModel> usersModel = await usersService.get();

      // ASSERT
      expect(usersModel.length, 2);
      expect(usersModel[0].uid, '12345678');
      expect(usersModel[0].email, null);
    });

    test('Should call getList from FirestoreServiceGetaway without result',
        () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getList('users'))
          .thenAnswer((_) => Future.value([]));

      final UsersService usersService =
          UsersService(firestoreServiceGetaway: firestoreServiceGetaway);

      // ACT
      List<UserModel> usersModel = await usersService.get();

      // ASSERT
      expect(usersModel.length, 0);
    });
  });

  group('UsersService.updateRelations', () {
    test('Should create new relation between 2 users', () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getById('users', '456')).thenAnswer(
        (_) => Future.value({
          'followers': null,
        }),
      );

      when(firestoreServiceGetaway.getById('users', '123')).thenAnswer(
        (_) => Future.value({
          'followings': null,
        }),
      );

      when(firestoreServiceGetaway.documentInCollectionExists(
              'users', 'followings', '123', '456'))
          .thenAnswer(
        (_) => Future.value(false),
      );

      final UsersService usersService = UsersService(
        firestoreServiceGetaway: firestoreServiceGetaway,
      );

      // ACT
      await usersService.updateRelations('123', '456');

      // ASSERT
      verify(firestoreServiceGetaway.updateReference(any, any));

      verify(
        firestoreServiceGetaway.addDocumentInCollection(
            'users', 'followings', '123', any),
      );

      verify(
        firestoreServiceGetaway.addDocumentInCollection(
            'users', 'followers', '456', any),
      );
    });

    test('Should remove relation between 2 users', () async {
      // ARRANGE
      final _MockFirestoreServiceGetaway firestoreServiceGetaway =
          _MockFirestoreServiceGetaway();

      when(firestoreServiceGetaway.getById('users', '456')).thenAnswer(
        (_) => Future.value({
          'followers': null,
        }),
      );

      when(firestoreServiceGetaway.getById('users', '123')).thenAnswer(
        (_) => Future.value({
          'followings': null,
        }),
      );

      when(firestoreServiceGetaway.documentInCollectionExists(
              'users', 'followings', '123', '456'))
          .thenAnswer(
        (_) => Future.value(true),
      );

      final UsersService usersService = UsersService(
        firestoreServiceGetaway: firestoreServiceGetaway,
      );

      // ACT
      await usersService.updateRelations('123', '456');

      // ASSERT
      verify(firestoreServiceGetaway.updateReference(any, any));

      verify(
        firestoreServiceGetaway.removeDocumentInCollection(
            'users', 'followings', '123', '456'),
      );

      verify(
        firestoreServiceGetaway.removeDocumentInCollection(
            'users', 'followers', '456', '123'),
      );
    });
  });
}

class _MockFirestoreServiceGetaway extends Mock
    implements FirestoreServiceGetaway {}
