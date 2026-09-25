import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/account/data/models/account_model.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_provider.dart';

void main() {
  test('reads the profile fields from raw auth data', () {
    final entity = AccountModel.fromRawData({
      'uid': 'u1',
      'isAnonymous': false,
      'email': 'ana@example.com',
      'displayName': 'Ana Diaz',
      'photoURL': 'https://example.com/a.jpg',
      'providerIds': ['google.com'],
    }).toEntity();

    expect(
      entity,
      const AccountEntity(
        id: 'u1',
        isGuest: false,
        email: 'ana@example.com',
        displayName: 'Ana Diaz',
        photoUrl: 'https://example.com/a.jpg',
        signInProvider: SignInProvider.google,
      ),
    );
  });

  test('treats missing data as a guest with no profile', () {
    final entity = AccountModel.fromRawData({}).toEntity();

    expect(entity.isGuest, isTrue);
    expect(entity.displayName, isNull);
    expect(entity.photoUrl, isNull);
  });

  test('a blank display name reads the same as no name at all', () {
    // Seen for real on a device during testing: Firebase returned an empty
    // string, not null, for an account's displayName. Every reader of this
    // field (ProfileHeader, initialsFor, the byline suggestion) treats null
    // as "no name" -- a blank string slipping through instead left the
    // profile title rendering empty next to a working "edit" icon.
    final entity = AccountModel.fromRawData({
      'uid': 'u3',
      'isAnonymous': false,
      'email': 'blank@example.com',
      'displayName': '   ',
    }).toEntity();

    expect(entity.displayName, isNull);
  });

  test('recognizes an email and password account', () {
    final entity = AccountModel.fromRawData({
      'uid': 'u2',
      'isAnonymous': false,
      'providerIds': ['password'],
    }).toEntity();

    expect(entity.signInProvider, SignInProvider.email);
  });
}
