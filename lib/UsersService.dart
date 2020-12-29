import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';
import 'package:flutter_models/models/UserModel.dart';

class UsersService {
  final FirestoreServiceGetaway firestoreServiceGetaway;

  const UsersService({
    this.firestoreServiceGetaway,
  });

  Stream<UserModel> getUserProfile(String uid) {
    return firestoreServiceGetaway.getSnapshotById('users', uid).map((e) {
      return e != null
          ? UserModel(
              uid: e[UserModel.UID],
              username: e[UserModel.USERNAME],
              avatarURL: e[UserModel.AVATAR_URL],
              status: e[UserModel.STATUS],
              // Follow-ers/ings
              followers: e[UserModel.FOLLOWERS] ?? 0,
              followings: e[UserModel.FOLLOWINGS] ?? 0,
              followersList: List<Map<String, dynamic>>.from(
                  e[UserModel.FOLLOWERS_LIST] ?? []),
              followingsList: List<Map<String, dynamic>>.from(
                  e[UserModel.FOLLOWINGS_LIST] ?? []),
            )
          : null;
    });
  }

  Future<List<UserModel>> getUsersByReference(List<dynamic> references) async {
    return Future.wait(
        references.map((e) async => await getUserByReference(e)).toList());
  }

  Future<UserModel> getUserByReference(dynamic reference) async {
    Map<String, dynamic> e =
        await firestoreServiceGetaway.getReference(reference);

    return UserModel(
      uid: e[UserModel.UID],
      username: e[UserModel.USERNAME],
      avatarURL: e[UserModel.AVATAR_URL],
      status: e[UserModel.STATUS],
      // Follow-ers/ings
      followers: e[UserModel.FOLLOWERS] ?? 0,
      followings: e[UserModel.FOLLOWINGS] ?? 0,
      followersList:
          List<Map<String, dynamic>>.from(e[UserModel.FOLLOWERS_LIST] ?? []),
      followingsList:
          List<Map<String, dynamic>>.from(e[UserModel.FOLLOWINGS_LIST] ?? []),
    );
  }

  Future<List<UserModel>> get() async {
    final List<Map<String, dynamic>> list =
        await firestoreServiceGetaway.getList('users');

    return list
        .map(
          (e) => UserModel(
            uid: e[UserModel.UID],
            username: e[UserModel.USERNAME],
            avatarURL: e[UserModel.AVATAR_URL],
            status: e[UserModel.STATUS],
            followers: e[UserModel.FOLLOWERS] ?? 0,
            followings: e[UserModel.FOLLOWINGS] ?? 0,
          ),
        )
        .toList();
  }

  Future<void> updateRelations(String uidFrom, String uidTo) async {
    Map<String, dynamic> userForm =
        await firestoreServiceGetaway.getById('users', uidFrom);
    Map<String, dynamic> userTo =
        await firestoreServiceGetaway.getById('users', uidTo);

    bool result = await firestoreServiceGetaway.documentInCollectionExists(
        'users', 'followings', uidFrom, uidTo);

    if (!result) {
      firestoreServiceGetaway.updateReference(userForm['reference'],
          {'followings': (userForm['followings'] ?? 0) + 1});
      // userForm['reference']
      //     .update({'followings': (userForm['followings'] ?? 0) + 1});

      firestoreServiceGetaway.updateReference(
          userTo['reference'], {'followers': (userTo['followers'] ?? 0) + 1});
      // userTo['reference'].update({'followers': (userTo['followers'] ?? 0) + 1});

      await firestoreServiceGetaway.addDocumentInCollection(
          'users', 'followings', uidFrom, userTo);

      await firestoreServiceGetaway.addDocumentInCollection(
          'users', 'followers', uidTo, userForm);
    } else {
      firestoreServiceGetaway.updateReference(userForm['reference'],
          {'followings': (userForm['followings'] ?? 1) - 1});
      // userForm['reference']
      //     .update({'followings': (userForm['followings'] ?? 1) - 1});

      firestoreServiceGetaway.updateReference(
          userTo['reference'], {'followers': (userTo['followers'] ?? 1) - 1});
      // userTo['reference'].update({'followers': (userTo['followers'] ?? 1) - 1});

      await firestoreServiceGetaway.removeDocumentInCollection(
          'users', 'followings', uidFrom, uidTo);

      await firestoreServiceGetaway.removeDocumentInCollection(
          'users', 'followers', uidTo, uidFrom);
    }
  }
}
