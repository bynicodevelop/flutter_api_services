import 'package:flutter_api_services/FirestoreService.dart';
import 'package:flutter_api_services/exceptions/AuthenticationException.dart';
import 'package:flutter_api_services/getaway/FirebaseAuthGetaway.dart';
import 'package:flutter_models/models/UserModel.dart';

class UserService {
  final FirebaseAuthGetaway firebaseAuthGetaway;
  final FirestoreService firestoreService;

  const UserService({
    this.firebaseAuthGetaway,
    this.firestoreService,
  });

  Stream<UserModel> get user {
    return firebaseAuthGetaway.user.asyncMap((e) async {
      if (e == null) return null;

      Map<String, dynamic> data =
          await firestoreService.getUserById(e[UserModel.UID]);

      return UserModel(
        // From auth
        uid: e[UserModel.UID],
        email: e[UserModel.EMAIL],
        // From database
        username: data[UserModel.USERNAME],
        status: data[UserModel.STATUS],
        avatarURL: data[UserModel.AVATAR_URL],
        // Follow-ers/ings
        followers: data[UserModel.FOLLOWERS] ?? 0,
        followings: data[UserModel.FOLLOWINGS] ?? 0,
        followersList: List<Map<String, dynamic>>.from(
            data[UserModel.FOLLOWERS_LIST] ?? []),
        followingsList: List<Map<String, dynamic>>.from(
            data[UserModel.FOLLOWINGS_LIST] ?? []),
      );
    });
  }

  Future<List<UserModel>> getFollowers(List<String> followersIds) async {
    if (followersIds.length == 0) {
      return [];
    }

    List<Map<String, dynamic>> users =
        await firestoreService.getUsersByIds(followersIds);

    return users.map(
      (e) {
        return UserModel(
          uid: e[UserModel.UID],
          email: e[UserModel.EMAIL],
          // From database
          username: e[UserModel.USERNAME],
          status: e[UserModel.STATUS],
          avatarURL: e[UserModel.AVATAR_URL],
          // Follow-ers/ings
          followers: e[UserModel.FOLLOWERS] ?? 0,
          followings: e[UserModel.FOLLOWINGS] ?? 0,
          followersList: List<Map<String, dynamic>>.from(
              e[UserModel.FOLLOWERS_LIST] ?? []),
          followingsList: List<Map<String, dynamic>>.from(
              e[UserModel.FOLLOWINGS_LIST] ?? []),
        );
      },
    ).toList();
  }

  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      Map<String, dynamic> data = await firebaseAuthGetaway
          .signInWithEmailAndPassword(email.toLowerCase(), password);

      return UserModel(
        uid: data[UserModel.UID],
        email: data[UserModel.EMAIL],
      );
    } on AuthenticationException catch (e) {
      throw new AuthenticationException(code: e.code);
    }
  }

  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      Map<String, dynamic> data = await firebaseAuthGetaway
          .signUpWithEmailAndPassword(email.toLowerCase(), password);

      return UserModel(
        uid: data[UserModel.UID],
        email: data[UserModel.EMAIL],
      );
    } on AuthenticationException catch (e) {
      throw new AuthenticationException(code: e.code);
    }
  }

  Future<void> signOut() async {
    await firebaseAuthGetaway.signOut();
  }

  Future<void> delete() async {
    try {
      await firebaseAuthGetaway.delete();
    } on AuthenticationException catch (e) {
      throw new AuthenticationException(code: e.code);
    }
  }

  Future<void> update(String key, String value) async {
    if (key != UserModel.PASSWORD) {
      await firebaseAuthGetaway.updateField({
        key: value,
      });
    }

    if (key == UserModel.EMAIL) {
      try {
        await firebaseAuthGetaway.updateEmail(value.toLowerCase());
      } on AuthenticationException catch (e) {
        throw new AuthenticationException(code: e.code);
      }
    }

    if (key == UserModel.PASSWORD) {
      try {
        await firebaseAuthGetaway.updatePassword(value);
      } on AuthenticationException catch (e) {
        throw new AuthenticationException(code: e.code);
      }
    }
  }
}
