import 'package:flutter_api_services/FirestorageService.dart';
import 'package:flutter_api_services/getaway/FirestorageServiceGetaway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

main() {
  group('FirestorageService.uploadAvatar', () {
    test('Should call uploadFile from FirestorageServiceGetaway and return url',
        () async {
      // ARRANGE
      final String uid = '123456789';
      final String path = 'path/file.png';

      final _MockFirestorageServiceGetaway firestorageServiceGetaway =
          _MockFirestorageServiceGetaway();

      when(firestorageServiceGetaway.uploadFile(
              path, '/users/$uid/avatars/file.png'))
          .thenAnswer(
        (_) => Future.value('url'),
      );

      FirestorageService firestorageService = FirestorageService(
        firestorageServiceGetaway: firestorageServiceGetaway,
      );

      // ACT
      String url = await firestorageService.uploadAvatar(path, uid);

      // ASSERT
      expect(url, 'url');
    });

    test(
        'Should call uploadFile from FirestorageServiceGetaway and return null',
        () async {
      // ARRANGE
      final String uid = '123456789';
      final String path = 'path/file.png';

      final _MockFirestorageServiceGetaway firestorageServiceGetaway =
          _MockFirestorageServiceGetaway();

      when(firestorageServiceGetaway.uploadFile(
              path, '/users/$uid/avatars/file.png'))
          .thenAnswer((_) => Future.value(null));

      FirestorageService firestorageService = FirestorageService(
          firestorageServiceGetaway: firestorageServiceGetaway);

      // ACT
      String url = await firestorageService.uploadAvatar(path, uid);

      // ASSERT
      expect(url, null);
    });
  });
}

class _MockFirestorageServiceGetaway extends Mock
    implements FirestorageServiceGetaway {}
