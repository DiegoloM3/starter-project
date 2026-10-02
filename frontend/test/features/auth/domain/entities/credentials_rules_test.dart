import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';

void main() {
  group('findEmailError', () {
    test('accepts a valid email, even with spaces around it', () {
      expect(CredentialsRules.findEmailError('jane@example.com'), isNull);
      expect(CredentialsRules.findEmailError(' jane@example.com '), isNull);
    });

    test('rejects an empty email', () {
      expect(CredentialsRules.findEmailError(''), CredentialsError.blank);
      expect(CredentialsRules.findEmailError('   '), CredentialsError.blank);
    });

    test('rejects an email without a user, a domain or an @', () {
      for (final email in ['jane', 'jane@', '@example.com', 'jane@example', 'jane doe@example.com']) {
        expect(CredentialsRules.findEmailError(email), CredentialsError.invalidEmail, reason: email);
      }
    });
  });
}
