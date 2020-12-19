import 'package:flutter_api_services/getaway/FirestorageServiceGetaway.dart';

class FirestorageService {
  final FirestorageServiceGetaway firestorageServiceGetaway;

  const FirestorageService({
    this.firestorageServiceGetaway,
  });

  String _extratFileName(String path) {
    return path.split('/').last;
  }

  Future<String> uploadAvatar(String path, String uid) async {
    String fileName = _extratFileName(path);

    return await firestorageServiceGetaway.uploadFile(
        path, '/users/$uid/avatars/$fileName');
  }
}
