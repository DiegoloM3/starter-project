import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';

const validDraft = RegistrationDraftEntity(
  name: 'Jane Doe',
  email: 'jane@example.com',
  password: 'a-long-password',
  passwordConfirmation: 'a-long-password',
);

void main() {
  test('a draft that follows every rule is valid', () {
    expect(validDraft.isValid, isTrue);
    expect(validDraft.nameError, isNull);
    expect(validDraft.emailError, isNull);
    expect(validDraft.passwordError, isNull);
    expect(validDraft.passwordConfirmationError, isNull);
  });

  test('an empty draft is not valid', () {
    expect(const RegistrationDraftEntity().isValid, isFalse);
  });

  test('copyWith changes only the given fields', () {
    final edited = validDraft.copyWith(name: 'John Smith');

    expect(edited.name, 'John Smith');
    expect(edited.email, validDraft.email);
    expect(edited.password, validDraft.password);
    expect(edited.passwordConfirmation, validDraft.passwordConfirmation);
  });

  group('name', () {
    test('is required', () {
      expect(validDraft.copyWith(name: '  ').nameError, CredentialsError.blank);
    });

    test('accepts up to ${CredentialsRules.maxNameLength} characters', () {
      final longestName = 'a' * CredentialsRules.maxNameLength;
      expect(validDraft.copyWith(name: longestName).nameError, isNull);
      expect(validDraft.copyWith(name: '${longestName}a').nameError, CredentialsError.tooLong);
    });
  });

  test('the email must be valid', () {
    expect(validDraft.copyWith(email: 'jane@').emailError, CredentialsError.invalidEmail);
  });

  group('password', () {
    test('is required', () {
      expect(validDraft.copyWith(password: '').passwordError, CredentialsError.blank);
    });

    test('has at least ${CredentialsRules.minPasswordLength} characters', () {
      final shortestPassword = 'a' * CredentialsRules.minPasswordLength;
      expect(validDraft.copyWith(password: shortestPassword).passwordError, isNull);
      expect(validDraft.copyWith(password: shortestPassword.substring(1)).passwordError, CredentialsError.tooShort);
    });
  });

  group('password confirmation', () {
    test('is required', () {
      expect(validDraft.copyWith(passwordConfirmation: '').passwordConfirmationError, CredentialsError.blank);
    });

    test('must match the password', () {
      final draft = validDraft.copyWith(passwordConfirmation: 'another-password');

      expect(draft.passwordConfirmationError, CredentialsError.mismatch);
      expect(draft.isValid, isFalse);
    });
  });
}
