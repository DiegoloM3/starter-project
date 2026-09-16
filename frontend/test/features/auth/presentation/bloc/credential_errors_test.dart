import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/credential_errors.dart';

void main() {
  const all = [
    CredentialValidationError.shortDisplayName,
    CredentialValidationError.invalidEmail,
    CredentialValidationError.shortPassword,
  ];

  test('picks the first error that belongs to each field', () {
    expect(CredentialErrors.forDisplayName(all), CredentialValidationError.shortDisplayName);
    expect(CredentialErrors.forEmail(all), CredentialValidationError.invalidEmail);
    expect(CredentialErrors.forPassword(all), CredentialValidationError.shortPassword);
  });

  test('returns null when no error concerns the field', () {
    const onlyEmail = [CredentialValidationError.emptyEmail];

    expect(CredentialErrors.forDisplayName(onlyEmail), isNull);
    expect(CredentialErrors.forPassword(onlyEmail), isNull);
    expect(CredentialErrors.forEmail(const []), isNull);
  });

}
