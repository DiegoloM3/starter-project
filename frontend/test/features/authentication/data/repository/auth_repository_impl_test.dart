import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/data/models/app_user_model.dart';
import 'package:news_app_clean_architecture/features/authentication/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';

import '../../../../helpers/fake_firebase_auth_service.dart';

/// This repository is where the provider's error codes stop existing. These
/// tests are about that translation, and about the two promises the app makes
/// on top of it: a name just written wins, and a password reset never reveals
/// who has an account.
void main() {
  late FakeFirebaseAuthService service;
  late AuthRepositoryImpl repository;

  setUp(() {
    service = FakeFirebaseAuthService();
    repository = AuthRepositoryImpl(service);
  });

  group('failure translation', () {
    /// Each of these is a provider code the domain has its own name for.
    /// Anything above this layer only ever sees the name on the right.
    const mappings = <String, Type>{
      'email-already-in-use': EmailAlreadyRegisteredException,
      'invalid-credential': InvalidCredentialsException,
      'wrong-password': InvalidCredentialsException,
      'user-not-found': InvalidCredentialsException,
      'invalid-email': InvalidCredentialsException,
      'user-disabled': InvalidCredentialsException,
      'weak-password': CredentialsValidationException,
      'too-many-requests': TooManyAttemptsException,
    };

    mappings.forEach((code, failure) {
      test('$code is reported as $failure', () async {
        service.errorToThrow = authError(code);

        final result = await repository.signIn(
          email: 'alex@example.com',
          password: 'correct horse',
        );

        expect(result, isA<DataFailed>());
        expect(result.error.runtimeType, failure);
      });
    });

    test('weak-password says which rule was broken', () async {
      service.errorToThrow = authError('weak-password');

      final result = await repository.signUp(
        email: 'alex@example.com',
        password: 'short',
        displayName: 'Alex Rivera',
      );

      expect(
        (result.error as CredentialsValidationException).errors,
        [CredentialsValidationError.passwordTooShort],
      );
    });

    /// A code nobody anticipated is passed through rather than flattened into
    /// a failure that would be wrong.
    test('an unrecognised code is passed through as it came', () async {
      service.errorToThrow = authError('operation-not-allowed');

      final result = await repository.signIn(
        email: 'alex@example.com',
        password: 'correct horse',
      );

      expect(result.error, isA<RemoteException>());
    });

    /// Without the broad catch this would not surface as an error at all: it
    /// would leave the caller's `await` hanging and the screen spinning.
    test('an error that is not a RemoteException still comes back', () async {
      service.errorToThrow = StateError('something nobody anticipated');

      final result = await repository.signOut();

      expect(result, isA<DataFailed>());
      expect(result.error, isA<StateError>());
    });
  });

  group('signUp', () {
    test('returns the account as an entity', () async {
      final result = await repository.signUp(
        email: 'alex@example.com',
        password: 'correct horse',
        displayName: 'Alex Rivera',
      );

      expect(result, isA<DataSuccess>());
      expect(result.data!.id, 'user-1');
      expect(result.data!.email, 'alex@example.com');
    });

    /// Firebase does not necessarily refresh its cached user after the name
    /// is written, and re-reading it is what used to hang, so the name the
    /// caller just asked for wins.
    test('the name just written wins over the cached one', () async {
      service.user = const AppUserModel(
        id: 'user-1',
        email: 'alex@example.com',
        displayName: '',
      );

      final result = await repository.signUp(
        email: 'alex@example.com',
        password: 'correct horse',
        displayName: 'Alex Rivera',
      );

      expect(result.data!.displayName, 'Alex Rivera');
    });

    test('an account signed up without a name keeps what Firebase has',
        () async {
      final result = await repository.signUp(
        email: 'alex@example.com',
        password: 'correct horse',
        displayName: '',
      );

      expect(result.data!.displayName, 'Alex Rivera');
    });
  });

  group('updateDisplayName', () {
    test('writes the name and answers with it', () async {
      service.user = const AppUserModel(
        id: 'user-1',
        email: 'alex@example.com',
        displayName: 'Old Name',
      );

      final result = await repository.updateDisplayName('Alex Rivera');

      expect(service.lastDisplayNameWritten, 'Alex Rivera');
      expect(result.data!.displayName, 'Alex Rivera');
    });
  });

  group('getCurrentUser', () {
    test('reports nobody signed in as a success with nothing in it', () async {
      service.user = null;

      final result = await repository.getCurrentUser();

      expect(result, isA<DataSuccess>());
      expect(result.data, isNull);
    });

    test('returns whoever is signed in', () async {
      final result = await repository.getCurrentUser();

      expect(result.data!.id, 'user-1');
    });
  });

  group('requestPasswordReset', () {
    test('asks Firebase to send the email', () async {
      final result = await repository.requestPasswordReset('alex@example.com');

      expect(result, isA<DataSuccess>());
      expect(service.lastPasswordResetEmail, 'alex@example.com');
    });

    /// The contract on purpose: an address nobody uses is reported exactly
    /// like one that exists, so the app cannot be used to discover who is
    /// registered here.
    test('an unknown address is reported as a success', () async {
      service.errorToThrow = authError('user-not-found');

      final result =
          await repository.requestPasswordReset('nobody@example.com');

      expect(result, isA<DataSuccess>());
    });

    test('a rate limit is still reported as a failure', () async {
      service.errorToThrow = authError('too-many-requests');

      final result = await repository.requestPasswordReset('alex@example.com');

      expect(result, isA<DataFailed>());
      expect(result.error, isA<TooManyAttemptsException>());
    });
  });

  test('signOut goes through to Firebase', () async {
    final result = await repository.signOut();

    expect(result, isA<DataSuccess>());
    expect(service.signOutCallCount, 1);
  });
}
