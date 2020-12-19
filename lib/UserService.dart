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
      );
    });
  }

  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      Map<String, dynamic> data =
          await firebaseAuthGetaway.signInWithEmailAndPassword(email, password);

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
      Map<String, dynamic> data =
          await firebaseAuthGetaway.signUpWithEmailAndPassword(email, password);

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
        await firebaseAuthGetaway.updateEmail(value);
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
