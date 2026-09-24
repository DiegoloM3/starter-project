import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/app_user.dart';

void main() {
  test('publishes under the chosen display name', () {
    const user = AppUserEntity(
      id: 'journalist-1',
      email: 'alex@example.com',
      displayName: 'Alex Rivera',
    );

    expect(user.authorName, 'Alex Rivera');
  });

  test('publishes anonymously when no name was chosen', () {
    const user = AppUserEntity(id: 'journalist-1', email: 'alex@example.com');

    expect(user.authorName, AppUserEntity.anonymousName);
  });

  test('ignores a display name that is only whitespace', () {
    const user = AppUserEntity(
      id: 'journalist-1',
      email: 'alex@example.com',
      displayName: '   ',
    );

    expect(user.authorName, AppUserEntity.anonymousName);
  });

  test('never publishes any part of the email address', () {
    const user = AppUserEntity(id: 'journalist-1', email: 'alex@example.com');

    // Leaving the optional name blank used to publish "alex" — a piece of
    // somebody's address, shown to every reader, from a field they were told
    // they could skip.
    expect(user.authorName, isNot(contains('alex')));
    expect(user.authorName, isNot(contains('@')));
  });
}
