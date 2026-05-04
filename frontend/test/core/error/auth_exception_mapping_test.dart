import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';

void main() {
  group('AuthException.localizedMessage', () {
    // Spot-check a representative subset of code → message mappings rather
    // than asserting every case — the mapping is a single switch and adding
    // tests per code mostly tests the test, not the production code.
    test('translates known Firebase auth codes to user-facing copy', () {
      expect(
        const AuthException(message: 'x', code: 'wrong-password')
            .localizedMessage,
        equals('Email or password is incorrect.'),
      );
      expect(
        const AuthException(message: 'x', code: 'email-already-in-use')
            .localizedMessage,
        equals('An account with this email already exists.'),
      );
      expect(
        const AuthException(message: 'x', code: 'network-request-failed')
            .localizedMessage,
        equals('No internet connection.'),
      );
    });

    test('falls back to generic copy for unknown or null codes', () {
      const generic = 'Sign-in failed. Please try again.';
      expect(
        const AuthException(message: 'x', code: 'some-new-code')
            .localizedMessage,
        equals(generic),
      );
      expect(
        const AuthException(message: 'x').localizedMessage,
        equals(generic),
      );
    });
  });
}
