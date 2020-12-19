import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_api_services/exceptions/AuthenticationException.dart';
import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';

class FirebaseAuthGetaway {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirestoreServiceGetaway _firestoreServiceGetaway;

  FirebaseAuthGetaway() {
    _firestoreServiceGetaway = FirestoreServiceGetaway();
  }

  Stream<Map<String, dynamic>> get user {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      return {
        'uid': user.uid,
        'email': user.email,
      };
    });
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      String email, String password) async {
    UserCredential userCredential;

    try {
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw new AuthenticationException(
            code: AuthenticationException.WRONG_CREDENTIALS,
          );
          break;
        case 'too-many-request':
          throw new AuthenticationException(
            code: AuthenticationException.TOO_MANY_REQUESTS,
          );
          break;
        case 'user-no-found':
          throw new AuthenticationException(
            code: AuthenticationException.USER_NOT_FOUND,
          );
          break;
        default:
          throw new AuthenticationException(
            code: e.code,
          );
      }
    }

    return {
      'uid': userCredential.user.uid,
      'email': userCredential.user.email,
    };
  }

  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
      String email, String password) async {
    UserCredential userCredential;

    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('FirebaseAuthGetaway => Firebase error: ${e.code}');

      throw new AuthenticationException(
        code: AuthenticationException.USER_ALREADY_IN_EXISTS,
      );
    }

    return {
      'uid': userCredential.user.uid,
      'email': userCredential.user.email,
    };
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> delete() async {
    try {
      await _firebaseAuth.currentUser.delete();
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthGetaway (delete) => Firebase error: ${e.code}');

      throw new AuthenticationException(
        code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
      );
    }
  }

  Future<void> updateField(dynamic data) async {
    try {
      await _firestoreServiceGetaway.update(
          'users', _firebaseAuth.currentUser.uid, data);
    } catch (e) {
      print('FirebaseAuthGetaway (updateField) => Firebase error: ${e.code}');

      throw new AuthenticationException(
        code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
      );
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      await _firebaseAuth.currentUser.updateEmail(email);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthGetaway (updateEmail) => Firebase error: ${e.code}');

      throw new AuthenticationException(
        code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
      );
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _firebaseAuth.currentUser.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthGetaway (updatePassword) => Firebase error: ${e.code}');

      throw new AuthenticationException(
        code: AuthenticationException.REQUIRE_RECENTE_LOGIN,
      );
    }
  }
}
