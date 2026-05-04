import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('validateEmail accepts well-formed addresses, rejects others', () {
      expect(AuthValidators.validateEmail('user@example.com'), isNull);
      expect(AuthValidators.validateEmail('user@mail.example.co.uk'), isNull);
      expect(AuthValidators.validateEmail(''), isNotNull);
      expect(AuthValidators.validateEmail(null), isNotNull);
      expect(AuthValidators.validateEmail('notanemail'), isNotNull);
      expect(AuthValidators.validateEmail('user@'), isNotNull);
    });

    test('validatePassword requires at least 8 characters', () {
      expect(AuthValidators.validatePassword('12345678'), isNull);
      expect(AuthValidators.validatePassword('1234567'), isNotNull);
      expect(AuthValidators.validatePassword(''), isNotNull);
      expect(AuthValidators.validatePassword(null), isNotNull);
      // Error copy mentions the minimum so users know what to fix.
      expect(AuthValidators.validatePassword('short'), contains('8'));
    });

    test('validateDisplayName requires at least 2 characters', () {
      expect(AuthValidators.validateDisplayName('Al'), isNull);
      expect(AuthValidators.validateDisplayName('A'), isNotNull);
      expect(AuthValidators.validateDisplayName(''), isNotNull);
      expect(AuthValidators.validateDisplayName(null), isNotNull);
    });
  });
}
