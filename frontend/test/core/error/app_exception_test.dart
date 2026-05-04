import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';

void main() {
  group('AppException', () {
    test('all subtypes carry message and inherit from AppException', () {
      final cases = <AppException>[
        const NetworkException(message: 'no internet'),
        const FirestoreException(message: 'denied', code: 'permission-denied'),
        const StorageException(message: 'upload failed'),
        const AuthException(message: 'not authenticated'),
        const ValidationException(message: 'field required'),
        const UnknownException(message: 'unexpected'),
      ];

      for (final e in cases) {
        expect(e.message, isNotEmpty);
        expect(e, isA<AppException>());
        expect(e.localizedMessage, isNotEmpty);
      }
    });

    test('FirestoreException keeps the optional code field', () {
      const e = FirestoreException(message: 'x', code: 'permission-denied');
      expect(e.code, equals('permission-denied'));
    });

    test('cause and stackTrace are preserved', () {
      final cause = Exception('socket');
      final st = StackTrace.current;
      final e =
          NetworkException(message: 'failed', cause: cause, stackTrace: st);

      expect(e.cause, equals(cause));
      expect(e.stackTrace, equals(st));
    });

    test('sealed hierarchy supports exhaustive switch', () {
      String classify(AppException e) => switch (e) {
            NetworkException() => 'network',
            FirestoreException() => 'firestore',
            StorageException() => 'storage',
            AuthException() => 'auth',
            ValidationException() => 'validation',
            UnknownException() => 'unknown',
          };

      expect(classify(const NetworkException(message: 'x')), 'network');
      expect(classify(const AuthException(message: 'x')), 'auth');
    });
  });
}
