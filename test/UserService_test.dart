import 'package:flutter_api_services/FirestoreService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_api_services/UserService.dart';
import 'package:flutter_api_services/exceptions/AuthenticationException.dart';
import 'package:flutter_api_services/getaway/FirebaseAuthGetaway.dart';
import 'package:flutter_models/models/UserModel.dart';

main() {
  group('UserService.user', () {
    test('Should return a Stream with an UserModel', () async {
      // ARRANGE
      final String uid = '123456789';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();
      final _MockFirestoreService firestoreService = _MockFirestoreService();

      when(firestoreService.getUserById(uid)).thenAnswer(
        (_) => Future.value({
          'username': 'username',
          'status': 'status',
          'avatarURL': 'avatarURL',
        }),
      );

      when(firebaseAuthGetaway.user).thenAnswer(
        (_) => Stream.fromFuture(
          Future.value({
            'uid': uid,
            'email': 'email',
            'username': 'username',
            'status': 'status',
            'avatarURL': 'avatarURL',
          }),
        ),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
        firestoreService: firestoreService,
      );

      // ACT
      Stream<UserModel> stream = userService.user;

      UserModel userModel = await stream.first;

      // ASSERT
      expect(userModel, isInstanceOf<UserModel>());

      expect(userModel.uid, uid);
      expect(userModel.email, 'email');
      expect(userModel.username, 'username');
      expect(userModel.status, 'status');
      expect(userModel.avatarURL, 'avatarURL');

      verify(firestoreService.getUserById(uid));
    });

    test('Should return a Stream with an null value when user is logout',
        () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.user)
          .thenAnswer((_) => Stream.fromFuture(Future.value(null)));

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      Stream<UserModel> stream = userService.user;

      // ASSERT
      expect(await stream.first, null);
    });
  });

  group('UserService signInWithEmailAndPassword', () {
    test('Should authenticated with success', () async {
      // ARRANGE
      final String uid = '1234567';
      final String email = 'john.doe@domain.tld';
      final String password = '123456';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.signInWithEmailAndPassword(email, password))
          .thenAnswer(
        (_) => Future.value({
          'uid': uid,
          'email': email,
        }),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      final UserModel userModel =
          await userService.signInWithEmailAndPassword(email, password);

      // ASSERT
      verify(firebaseAuthGetaway.signInWithEmailAndPassword(email, password));

      expect(userModel.uid, uid);
      expect(userModel.email, email);
    });

    test('Should expected an AuthenticationException (wrong credential)',
        () async {
      // ARRANGE
      final String email = 'john.doe@domain.tld';
      final String password = '123456';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.signInWithEmailAndPassword(email, password))
          .thenThrow(AuthenticationException(
              code: AuthenticationException.WRONG_CREDENTIALS));

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT && EXPECT
      expect(
        () async =>
            await userService.signInWithEmailAndPassword(email, password),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate(
                (f) => f.code == AuthenticationException.WRONG_CREDENTIALS),
          ),
        ),
      );
    });

    test('Should expected an Authentication exception (user not found)',
        () async {
      // ARRANGE
      final String email = 'john.doe@domain.tld';
      final String password = '123456';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.signInWithEmailAndPassword(email, password))
          .thenThrow(AuthenticationException(
              code: AuthenticationException.USER_NOT_FOUND));

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT && EXPECT
      expect(
        () async =>
            await userService.signInWithEmailAndPassword(email, password),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate((f) => f.code == AuthenticationException.USER_NOT_FOUND),
          ),
        ),
      );
    });

    test('Should expected an Authentication exception (to many request)',
        () async {
      // ARRANGE
      final String email = 'john.doe@domain.tld';
      final String password = '123456';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.signInWithEmailAndPassword(email, password))
          .thenThrow(AuthenticationException(
              code: AuthenticationException.TOO_MANY_REQUESTS));

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT && EXPECT
      expect(
        () async =>
            await userService.signInWithEmailAndPassword(email, password),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate(
                (f) => f.code == AuthenticationException.TOO_MANY_REQUESTS),
          ),
        ),
      );
    });
  });

  group('UserService signUpWithEmailAndPassword', () {
    test('Should create a user with success', () async {
      // ARRANGE
      final String uid = '1234567';
      final String email = 'john.doe@domain.tld';
      final String password = '123456';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.signUpWithEmailAndPassword(email, password))
          .thenAnswer(
        (_) => Future.value({
          'uid': uid,
          'email': email,
        }),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      UserModel userModel =
          await userService.signUpWithEmailAndPassword(email, password);

      // ASSERT
      expect(userModel.uid, uid);
      expect(userModel.email, email);
    });

    test('Should expect an AuthenticationException (user-already-exist)',
        () async {
      // ARRANGE
      final String email = 'john.doe@domain.tld';
      final String password = '123456';
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.signUpWithEmailAndPassword(email, password))
          .thenThrow(
        AuthenticationException(
          code: AuthenticationException.USER_ALREADY_IN_EXISTS,
        ),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT & ASSERT
      expect(
        () async =>
            await userService.signUpWithEmailAndPassword(email, password),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate((f) =>
                f.code == AuthenticationException.USER_ALREADY_IN_EXISTS),
          ),
        ),
      );
    });
  });

  group('UserService.delete', () {
    test('Should call delete method', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      await userService.delete();

      // ASSERT
      verify(firebaseAuthGetaway.delete());
    });

    test('Should require recent login', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.delete()).thenThrow(
        AuthenticationException(
          code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
        ),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT & ASSERT
      expect(
        () async => await userService.delete(),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate(
                (f) => f.code == AuthenticationException.REQUIRE_RECENTE_LOGIN),
          ),
        ),
      );
    });
  });

  group('UserService.update', () {
    test('Should update email', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      await userService.update(UserModel.EMAIL, 'john.doe@domain.tld');

      // ASSERT
      verify(firebaseAuthGetaway.updateField({
        UserModel.EMAIL: 'john.doe@domain.tld',
      }));

      verify(firebaseAuthGetaway.updateEmail('john.doe@domain.tld'));
      verifyNever(firebaseAuthGetaway.updatePassword(any));
    });

    test('Should update email but require recent login', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.updateEmail(any)).thenThrow(
        AuthenticationException(
          code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
        ),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT & ASSERT
      expect(
        () async =>
            await userService.update(UserModel.EMAIL, 'john.doe@domain.tld'),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate(
                (f) => f.code == AuthenticationException.REQUIRE_RECENTE_LOGIN),
          ),
        ),
      );
    });

    test('Should update password', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      await userService.update(UserModel.PASSWORD, '123456');

      // ASSERT

      verify(firebaseAuthGetaway.updatePassword('123456'));
      verifyNever(firebaseAuthGetaway.updateEmail(any));
      verifyNever(firebaseAuthGetaway.updateField(any));
    });

    test('Should update password but require recent login', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.updatePassword('123456')).thenThrow(
        AuthenticationException(
          code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
        ),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT & ASSERT
      expect(
        () async => await userService.update(UserModel.PASSWORD, '123456'),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate(
                (f) => f.code == AuthenticationException.REQUIRE_RECENTE_LOGIN),
          ),
        ),
      );
    });

    test('Should update another field', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT
      await userService.update(
          UserModel.AVATAR_URL, 'http://localhost/profile.png');

      // ASSERT
      verify(firebaseAuthGetaway.updateField({
        UserModel.AVATAR_URL: 'http://localhost/profile.png',
      }));

      verifyNever(firebaseAuthGetaway.updateEmail(any));
      verifyNever(firebaseAuthGetaway.updatePassword(any));
    });

    test('Should update another field', () async {
      // ARRANGE
      final _FirebaseAuthGetaway firebaseAuthGetaway = _FirebaseAuthGetaway();

      when(firebaseAuthGetaway.updateField(any)).thenThrow(
        AuthenticationException(
          code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
        ),
      );

      final UserService userService = UserService(
        firebaseAuthGetaway: firebaseAuthGetaway,
      );

      // ACT & ASSERT
      expect(
        () async =>
            await userService.update(UserModel.EMAIL, 'john.doe@domain.tld'),
        throwsA(
          allOf(
            isInstanceOf<AuthenticationException>(),
            predicate(
                (f) => f.code == AuthenticationException.REQUIRE_RECENTE_LOGIN),
          ),
        ),
      );
    });
  });

  group('UserService.getFollowers', () {
    test('Should return an user list from list ID', () async {
      // ARRANGE
      final _MockFirestoreService firestoreService = _MockFirestoreService();

      when(firestoreService.getUsersByIds(
        ['123', '456'],
      )).thenAnswer((_) => Future.value([
            {'uid': '123'},
            {'uid': '456'},
          ]));

      final UserService userService = UserService(
          firebaseAuthGetaway: null, firestoreService: firestoreService);

      // ACT
      List<UserModel> followersProfiles =
          await userService.getFollowers(['123', '456']);

      // ASSERT
      expect(followersProfiles.length, 2);
      expect(followersProfiles[0].uid, '123');
      expect(followersProfiles[1].uid, '456');
    });

    test('Should return an user list from an empty list', () async {
      // ARRANGE
      final _MockFirestoreService firestoreService = _MockFirestoreService();

      when(firestoreService.getUsersByIds(
        [],
      )).thenAnswer((_) => Future.value([]));

      final UserService userService = UserService(
          firebaseAuthGetaway: null, firestoreService: firestoreService);

      // ACT
      List<UserModel> followersProfiles = await userService.getFollowers([]);

      // ASSERT
      expect(followersProfiles.length, 0);
    });
  });
}

class _FirebaseAuthGetaway extends Mock implements FirebaseAuthGetaway {}

class _MockFirestoreService extends Mock implements FirestoreService {}
