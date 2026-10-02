import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth auth;
  late MockUser firebaseUser;
  late AuthRemoteDataSourceImpl dataSource;

  const expectedUser = UserModel(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');

  setUp(() {
    auth = MockFirebaseAuth();
    firebaseUser = MockUser();
    dataSource = AuthRemoteDataSourceImpl(auth: auth);
    when(() => firebaseUser.uid).thenReturn('janeDoeUid');
    when(() => firebaseUser.displayName).thenReturn('Jane Doe');
    when(() => firebaseUser.email).thenReturn('jane@example.com');
  });

  UserCredential credentialOf(User user) {
    final credential = MockUserCredential();
    when(() => credential.user).thenReturn(user);
    return credential;
  }

  test('reports every change of the signed-in account', () {
    when(() => auth.userChanges()).thenAnswer((_) => Stream.fromIterable([null, firebaseUser]));

    expect(dataSource.watchSession(), emitsInOrder([null, expectedUser, emitsDone]));
  });

  test('signs in with the email and password', () async {
    when(() => auth.signInWithEmailAndPassword(email: 'jane@example.com', password: 'a-long-password'))
        .thenAnswer((_) async => credentialOf(firebaseUser));

    expect(await dataSource.signIn('jane@example.com', 'a-long-password'), expectedUser);
  });

  test('registers the account with its name and refreshes the token so the rules can read it', () async {
    const draft = RegistrationDraftEntity(
      name: ' Jane Doe ',
      email: ' jane@example.com ',
      password: 'a-long-password',
      passwordConfirmation: 'a-long-password',
    );
    when(() => auth.createUserWithEmailAndPassword(email: 'jane@example.com', password: 'a-long-password'))
        .thenAnswer((_) async => credentialOf(firebaseUser));
    when(() => firebaseUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => firebaseUser.getIdToken(true)).thenAnswer((_) async => 'token-with-the-name');
    when(() => auth.currentUser).thenReturn(firebaseUser);

    final user = await dataSource.register(draft);

    expect(user, expectedUser);
    verifyInOrder([
      () => firebaseUser.updateDisplayName('Jane Doe'),
      () => firebaseUser.getIdToken(true),
    ]);
  });

  test('signs out', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});

    await dataSource.signOut();

    verify(() => auth.signOut()).called(1);
  });

  group('translates the errors of Firebase Authentication', () {
    final errorsByCode = {
      'invalid-credential': AuthError.wrongEmailOrPassword,
      'wrong-password': AuthError.wrongEmailOrPassword,
      'user-not-found': AuthError.wrongEmailOrPassword,
      'user-disabled': AuthError.wrongEmailOrPassword,
      'email-already-in-use': AuthError.emailAlreadyInUse,
      'weak-password': AuthError.weakPassword,
      'invalid-email': AuthError.invalidEmail,
      'too-many-requests': AuthError.tooManyAttempts,
      'network-request-failed': AuthError.noConnection,
      'internal-error': AuthError.unknown,
    };

    errorsByCode.forEach((code, error) {
      test('$code → ${error.name}', () async {
        when(() => auth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
            .thenThrow(FirebaseAuthException(code: code));

        expect(
          () => dataSource.signIn('jane@example.com', 'a-long-password'),
          throwsA(isA<AuthException>().having((exception) => exception.error, 'error', error)),
        );
      });
    });
  });
}
