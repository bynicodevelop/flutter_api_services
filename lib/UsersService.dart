import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';
import 'package:flutter_models/models/UserModel.dart';

class UsersService {
  final FirestoreServiceGetaway firestoreServiceGetaway;

  const UsersService({
    this.firestoreServiceGetaway,
  });

  Stream<UserModel> getUserProfile(String uid) {
    return firestoreServiceGetaway.getSnapshotById('users', uid).map(
          (e) => e != null
              ? UserModel(
                  uid: e[UserModel.UID],
                  username: e[UserModel.USERNAME],
                  avatarURL: e[UserModel.AVATAR_URL],
                  status: e[UserModel.STATUS],
                  // Follow-ers/ings
                  followers: e[UserModel.FOLLOWERS]?.length ?? 0,
                  followings: e[UserModel.FOLLOWINGS]?.length ?? 0,
                  followersList:
                      List<String>.from(e[UserModel.FOLLOWERS] ?? []),
                  followingsList:
                      List<String>.from(e[UserModel.FOLLOWINGS] ?? []),
                )
              : null,
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
            followers: e[UserModel.FOLLOWERS]?.length ?? 0,
            followings: e[UserModel.FOLLOWINGS]?.length ?? 0,
          ),
        )
        .toList();
  }

  Future<void> updateRelations(String uidFrom, String uidTo) async {
    Map<String, dynamic> userForm =
        await firestoreServiceGetaway.getById('users', uidFrom);
    Map<String, dynamic> userTo =
        await firestoreServiceGetaway.getById('users', uidTo);

    if (userTo['followers'] == null || userTo['followers'].length == 0) {
      await firestoreServiceGetaway.updateByDocument('users', uidTo, {
        'followers': [uidFrom]
      });
    }

    if (userTo['followers'] != null) {
      if (!userTo['followers'].contains(uidFrom)) {
        userTo['followers'].add(uidFrom);
      } else {
        userTo['followers'].remove(uidFrom);
      }

      await firestoreServiceGetaway
          .updateByDocument('users', uidTo, {'followers': userTo['followers']});
    }

    if (userForm['followings'] == null || userForm['followings'].length == 0) {
      await firestoreServiceGetaway.updateByDocument('users', uidFrom, {
        'followings': [uidTo]
      });
    }

    if (userForm['followings'] != null) {
      if (!userForm['followings'].contains(uidTo)) {
        userForm['followings'].add(uidTo);
      } else {
        userForm['followings'].remove(uidTo);
      }

      await firestoreServiceGetaway.updateByDocument(
          'users', uidFrom, {'followings': userForm['followings']});
    }
  }
}
