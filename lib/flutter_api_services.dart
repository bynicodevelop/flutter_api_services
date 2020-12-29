import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_api_services/ChatService.dart';
import 'package:flutter_api_services/FirestorageService.dart';
import 'package:flutter_api_services/FirestoreService.dart';
import 'package:flutter_api_services/UserService.dart';
import 'package:flutter_api_services/UsersService.dart';
import 'package:flutter_api_services/getaway/FirebaseAuthGetaway.dart';
import 'package:flutter_api_services/getaway/FirestorageServiceGetaway.dart';
import 'package:flutter_api_services/getaway/FirestoreServiceGetaway.dart';
import 'package:provider/provider.dart';

class ApiServices extends StatelessWidget {
  final Widget child;

  ApiServices({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox.shrink();
        }

        FirestoreService firestoreService = FirestoreService(
          firestoreServiceGetaway: FirestoreServiceGetaway(),
        );

        return MultiProvider(
          providers: [
            Provider<UserService>(
              create: (_) => UserService(
                firebaseAuthGetaway: FirebaseAuthGetaway(),
                firestoreService: firestoreService,
              ),
            ),
            Provider<FirestoreService>(
              create: (_) => firestoreService,
            ),
            Provider<FirestorageService>(
              create: (_) => FirestorageService(
                firestorageServiceGetaway: FirestorageServiceGetaway(),
              ),
            ),
            Provider<UsersService>(
              create: (_) => UsersService(
                firestoreServiceGetaway: FirestoreServiceGetaway(),
              ),
            ),
            Provider<ChatService>(
              create: (_) => ChatService(
                firestoreService: firestoreService,
              ),
            ),
          ],
          child: child,
        );
      },
    );
  }
}
