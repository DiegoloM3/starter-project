import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockGoogleSignInService extends Mock implements GoogleSignInService {}

class MockUserDocumentService extends Mock implements UserDocumentService {}

class MockUser extends Mock implements User {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  late MockFirebaseAuthService mockAuthService;
  late MockGoogleSignInService mockGoogleService;
  late MockUserDocumentService mockDocService;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AuthUserEntity(
      uid: 'fallback',
      providerId: 'anonymous',
      isAnonymous: true,
    ));
    registerFallbackValue(GoogleAuthProvider.credential(
      idToken: 'fake-id-token',
    ));
  });

  setUp(() {
    mockAuthService = MockFirebaseAuthService();
    mockGoogleService = MockGoogleSignInService();
    mockDocService = MockUserDocumentService();
    repository = AuthRepositoryImpl(
      mockAuthService,
      mockGoogleService,
      mockDocService,
    );
    // Provide a default stub for authStateChanges so watchAuthState tests work.
    when(() => mockAuthService.authStateChanges())
        .thenAnswer((_) => Stream<User?>.empty());
  });

  MockUser buildMockUser({
    String uid = 'uid-123',
    String? email = 'user@example.com',
    String? displayName = 'Test User',
    String? photoURL,
    bool isAnonymous = false,
    List<UserInfo> providerData = const [],
  }) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn(email);
    when(() => user.displayName).thenReturn(displayName);
    when(() => user.photoURL).thenReturn(photoURL);
    when(() => user.isAnonymous).thenReturn(isAnonymous);
    when(() => user.providerData).thenReturn(providerData);
    return user;
  }

  group('AuthRepositoryImpl', () {
    // -------------------------------------------------------------------
    // signInAnonymously
    // -------------------------------------------------------------------
    group('signInAnonymously', () {
      test('returns DataSuccess with anonymous AuthUserEntity', () async {
        final mockUser =
            buildMockUser(uid: 'anon-uid', isAnonymous: true, email: null);
        when(() => mockAuthService.signInAnonymously())
            .thenAnswer((_) async => mockUser);

        final result = await repository.signInAnonymously();

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        expect(result.data!.isAnonymous, isTrue);
      });

      test('returns DataFailed on AuthException', () async {
        when(() => mockAuthService.signInAnonymously()).thenThrow(
          const AuthException(message: 'error', code: 'network-request-failed'),
        );

        final result = await repository.signInAnonymously();

        expect(result, isA<DataFailed<AuthUserEntity>>());
      });

      test('returns DataFailed(UnknownException) on unexpected error', () async {
        when(() => mockAuthService.signInAnonymously())
            .thenThrow(Exception('unexpected'));

        final result = await repository.signInAnonymously();

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<UnknownException>());
      });
    });

    // -------------------------------------------------------------------
    // signInWithEmail
    // -------------------------------------------------------------------
    group('signInWithEmail', () {
      const params =
          SignInParams(email: 'user@example.com', password: 'pass123');

      test('returns DataSuccess and does NOT upsert user doc on success',
          () async {
        // sign-in does NOT write the user doc — only sign-up and Google do
        final mockUser = buildMockUser();
        when(() => mockAuthService.signInWithEmail(params.email, params.password))
            .thenAnswer((_) async => mockUser);

        final result = await repository.signInWithEmail(params);

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        verifyNever(() => mockDocService.upsertUser(any()));
      });

      test('returns DataFailed on wrong password', () async {
        when(() => mockAuthService.signInWithEmail(params.email, params.password))
            .thenThrow(
          const AuthException(message: 'wrong', code: 'wrong-password'),
        );

        final result = await repository.signInWithEmail(params);

        expect(result, isA<DataFailed<AuthUserEntity>>());
      });

      test('returns DataFailed(UnknownException) on unexpected error', () async {
        when(() => mockAuthService.signInWithEmail(params.email, params.password))
            .thenThrow(Exception('network timeout'));

        final result = await repository.signInWithEmail(params);

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<UnknownException>());
      });
    });

    // -------------------------------------------------------------------
    // signUpWithEmail
    // -------------------------------------------------------------------
    group('signUpWithEmail', () {
      const params = SignUpParams(
        email: 'new@example.com',
        password: 'pass123',
        displayName: 'Alice',
      );

      test('returns DataSuccess and upserts user document', () async {
        final mockUser = buildMockUser(email: params.email);
        final updatedUser = buildMockUser(
          email: params.email,
          displayName: params.displayName,
        );
        when(() => mockAuthService.signUpWithEmail(params.email, params.password))
            .thenAnswer((_) async => mockUser);
        when(() => mockAuthService.updateDisplayName(mockUser, params.displayName))
            .thenAnswer((_) async => updatedUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.signUpWithEmail(params);

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        verify(() => mockAuthService.updateDisplayName(mockUser, params.displayName))
            .called(1);
        verify(() => mockDocService.upsertUser(any())).called(1);
      });

      test('persists displayName from params on the upserted entity', () async {
        final mockUser = buildMockUser(email: params.email);
        final updatedUser = buildMockUser(
          email: params.email,
          displayName: params.displayName,
        );
        when(() => mockAuthService.signUpWithEmail(params.email, params.password))
            .thenAnswer((_) async => mockUser);
        when(() => mockAuthService.updateDisplayName(mockUser, params.displayName))
            .thenAnswer((_) async => updatedUser);
        AuthUserEntity? captured;
        when(() => mockDocService.upsertUser(any())).thenAnswer((invocation) async {
          captured = invocation.positionalArguments.first as AuthUserEntity;
        });

        final result = await repository.signUpWithEmail(params);

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        expect(captured, isNotNull);
        expect(captured!.displayName, equals(params.displayName));
      });

      test('returns DataFailed on email-already-in-use', () async {
        when(() => mockAuthService.signUpWithEmail(params.email, params.password))
            .thenThrow(
          const AuthException(
            message: 'email-in-use',
            code: 'email-already-in-use',
          ),
        );

        final result = await repository.signUpWithEmail(params);

        expect(result, isA<DataFailed<AuthUserEntity>>());
      });

      test('returns DataFailed(UnknownException) on unexpected error', () async {
        when(() => mockAuthService.signUpWithEmail(params.email, params.password))
            .thenThrow(Exception('quota exceeded'));

        final result = await repository.signUpWithEmail(params);

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<UnknownException>());
      });
    });

    // -------------------------------------------------------------------
    // signInWithGoogle — 5-step orchestration (design D5)
    // -------------------------------------------------------------------
    group('signInWithGoogle', () {
      test('executes full 5-step orchestration and returns DataSuccess',
          () async {
        final mockAccount = MockGoogleSignInAccount();
        final mockAuth = MockGoogleSignInAuthentication();
        when(() => mockAuth.idToken).thenReturn('id-token');
        when(() => mockAuth.accessToken).thenReturn('access-token');

        final mockUser = buildMockUser();
        when(() => mockGoogleService.signIn())
            .thenAnswer((_) async => mockAccount);
        when(() => mockGoogleService.getAuthentication(mockAccount))
            .thenAnswer((_) async => mockAuth);
        when(() => mockAuthService.signInWithCredential(any()))
            .thenAnswer((_) async => mockUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.signInWithGoogle();

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        verify(() => mockGoogleService.signIn()).called(1);
        verify(() => mockGoogleService.getAuthentication(mockAccount)).called(1);
        verify(() => mockAuthService.signInWithCredential(any())).called(1);
        verify(() => mockDocService.upsertUser(any())).called(1);
      });

      test('returns DataFailed when user cancels Google sign-in', () async {
        when(() => mockGoogleService.signIn()).thenAnswer((_) async => null);

        final result = await repository.signInWithGoogle();

        expect(result, isA<DataFailed<AuthUserEntity>>());
        verifyNever(() => mockAuthService.signInWithCredential(any()));
      });

      test('returns DataFailed(AuthException) when Google signIn throws AuthException',
          () async {
        when(() => mockGoogleService.signIn()).thenThrow(
          const AuthException(
            message: 'cancelled',
            code: 'popup-closed-by-user',
          ),
        );

        final result = await repository.signInWithGoogle();

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<AuthException>());
      });

      test('returns DataFailed(UnknownException) on unexpected Google error',
          () async {
        when(() => mockGoogleService.signIn())
            .thenThrow(Exception('network error'));

        final result = await repository.signInWithGoogle();

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<UnknownException>());
      });
    });

    // -------------------------------------------------------------------
    // signOut
    // -------------------------------------------------------------------
    group('signOut', () {
      test('calls firebaseAuthService.signOut and googleService.signOut',
          () async {
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});
        when(() => mockGoogleService.signOut()).thenAnswer((_) async {});

        final result = await repository.signOut();

        expect(result, isA<DataSuccess<void>>());
        verify(() => mockAuthService.signOut()).called(1);
        verify(() => mockGoogleService.signOut()).called(1);
      });

      test('returns DataFailed(AuthException) when signOut throws AuthException',
          () async {
        when(() => mockAuthService.signOut()).thenThrow(
          const AuthException(message: 'error', code: 'network-request-failed'),
        );

        final result = await repository.signOut();

        expect(result, isA<DataFailed<void>>());
        expect(result.error, isA<AuthException>());
      });

      test('returns DataFailed(UnknownException) on unexpected sign-out error',
          () async {
        when(() => mockAuthService.signOut())
            .thenThrow(Exception('signOut failed'));

        final result = await repository.signOut();

        expect(result, isA<DataFailed<void>>());
        expect(result.error, isA<UnknownException>());
      });
    });

    // -------------------------------------------------------------------
    // sendPasswordResetEmail
    // -------------------------------------------------------------------
    group('sendPasswordResetEmail', () {
      test('returns DataSuccess on success', () async {
        when(() => mockAuthService.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {});

        final result =
            await repository.sendPasswordResetEmail('reset@example.com');

        expect(result, isA<DataSuccess<void>>());
      });

      test('returns DataFailed(AuthException) on AuthException', () async {
        when(() => mockAuthService.sendPasswordResetEmail(any())).thenThrow(
          const AuthException(message: 'not found', code: 'user-not-found'),
        );

        final result =
            await repository.sendPasswordResetEmail('missing@example.com');

        expect(result, isA<DataFailed<void>>());
        expect(result.error, isA<AuthException>());
      });

      test('returns DataFailed(UnknownException) on unexpected error', () async {
        when(() => mockAuthService.sendPasswordResetEmail(any()))
            .thenThrow(Exception('smtp error'));

        final result =
            await repository.sendPasswordResetEmail('user@example.com');

        expect(result, isA<DataFailed<void>>());
        expect(result.error, isA<UnknownException>());
      });
    });

    // -------------------------------------------------------------------
    // watchAuthState
    // -------------------------------------------------------------------
    group('watchAuthState', () {
      test('returns a Stream from authService.authStateChanges', () {
        // watchAuthState delegates to authService.authStateChanges.
        final stream = repository.watchAuthState();

        expect(stream, isA<Stream<AuthUserEntity?>>());
        verify(() => mockAuthService.authStateChanges()).called(1);
      });

      test('maps non-null User to AuthUserEntity in stream', () async {
        final mockUser = buildMockUser();
        when(() => mockAuthService.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        final stream = repository.watchAuthState();
        final entity = await stream.first;

        expect(entity, isA<AuthUserEntity>());
        expect(entity!.uid, equals('uid-123'));
      });

      test('maps null User to null in stream', () async {
        when(() => mockAuthService.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        final stream = repository.watchAuthState();
        final entity = await stream.first;

        expect(entity, isNull);
      });
    });

    group('currentUser', () {
      test('returns null when no current user', () {
        when(() => mockAuthService.currentUser).thenReturn(null);

        expect(repository.currentUser, isNull);
      });

      test('returns AuthUserEntity when user is signed in', () {
        final mockUser = buildMockUser();
        when(() => mockAuthService.currentUser).thenReturn(mockUser);

        final entity = repository.currentUser;

        expect(entity, isA<AuthUserEntity>());
        expect(entity!.uid, equals('uid-123'));
      });
    });

    // -------------------------------------------------------------------
    // linkAnonymousWithEmail
    // -------------------------------------------------------------------
    group('linkAnonymousWithEmail', () {
      const params = SignUpParams(
        email: 'link@example.com',
        password: 'pass123',
        displayName: 'Alice',
      );

      test('happy path: links user, upserts doc, returns DataSuccess',
          () async {
        final mockUser = buildMockUser(uid: 'anon-uid', isAnonymous: true);
        final updatedUser = buildMockUser(
          uid: 'anon-uid',
          displayName: params.displayName,
          isAnonymous: false,
        );
        when(() => mockAuthService.linkAnonymousWithEmailAndPassword(
              email: params.email,
              password: params.password,
            )).thenAnswer((_) async => mockUser);
        when(() => mockAuthService.updateDisplayName(mockUser, params.displayName))
            .thenAnswer((_) async => updatedUser);
        when(() => mockAuthService.currentUser).thenReturn(updatedUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.linkAnonymousWithEmail(params);

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        verify(() => mockAuthService.linkAnonymousWithEmailAndPassword(
              email: params.email,
              password: params.password,
            )).called(1);
        verify(() => mockDocService.upsertUser(any())).called(1);
      });

      test('calls updateDisplayName when displayName is non-empty', () async {
        final mockUser = buildMockUser(uid: 'anon-uid', isAnonymous: true);
        final updatedUser = buildMockUser(
          uid: 'anon-uid',
          displayName: params.displayName,
          isAnonymous: false,
        );
        when(() => mockAuthService.linkAnonymousWithEmailAndPassword(
              email: params.email,
              password: params.password,
            )).thenAnswer((_) async => mockUser);
        when(() => mockAuthService.updateDisplayName(mockUser, params.displayName))
            .thenAnswer((_) async => updatedUser);
        when(() => mockAuthService.currentUser).thenReturn(updatedUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.linkAnonymousWithEmail(params);

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        verify(() =>
                mockAuthService.updateDisplayName(mockUser, params.displayName))
            .called(1);
      });

      test(
          'email-already-in-use: signOut + signInWithEmail fallback returns DataFailed(merge-required)',
          () async {
        // Use params without displayName to keep the fallback path simple.
        const fallbackParams = SignUpParams(
          email: 'link@example.com',
          password: 'pass123',
          displayName: '',
        );
        final freshUser = buildMockUser(uid: 'new-uid', isAnonymous: false);
        when(() => mockAuthService.linkAnonymousWithEmailAndPassword(
              email: fallbackParams.email,
              password: fallbackParams.password,
            )).thenThrow(const AuthException(
          message: 'email-in-use',
          code: 'email-already-in-use',
        ));
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});
        when(() => mockAuthService.signInWithEmail(
                fallbackParams.email, fallbackParams.password))
            .thenAnswer((_) async => freshUser);
        when(() => mockAuthService.currentUser).thenReturn(freshUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.linkAnonymousWithEmail(fallbackParams);

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<AuthException>());
        expect((result.error as AuthException).code, equals('merge-required'));
        verify(() => mockAuthService.signOut()).called(1);
        verify(() => mockAuthService.signInWithEmail(
                fallbackParams.email, fallbackParams.password))
            .called(1);
        verify(() => mockDocService.upsertUser(any())).called(1);
      });

      test('weak-password: returns DataFailed(AuthException)', () async {
        when(() => mockAuthService.linkAnonymousWithEmailAndPassword(
              email: params.email,
              password: params.password,
            )).thenThrow(const AuthException(
          message: 'weak',
          code: 'weak-password',
        ));

        final result = await repository.linkAnonymousWithEmail(params);

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<AuthException>());
        expect((result.error as AuthException).code, equals('weak-password'));
      });
    });

    // -------------------------------------------------------------------
    // linkAnonymousWithGoogle
    // -------------------------------------------------------------------
    group('linkAnonymousWithGoogle', () {
      test('happy path: links credential, upserts doc, returns DataSuccess',
          () async {
        final mockAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockUser = buildMockUser(uid: 'linked-uid', isAnonymous: false);

        when(() => mockGoogleAuth.idToken).thenReturn('id-token');
        when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
        when(() => mockGoogleService.signIn())
            .thenAnswer((_) async => mockAccount);
        when(() => mockGoogleService.getAuthentication(mockAccount))
            .thenAnswer((_) async => mockGoogleAuth);
        when(() => mockAuthService.linkAnonymousWithGoogleCredential(any()))
            .thenAnswer((_) async => mockUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.linkAnonymousWithGoogle();

        expect(result, isA<DataSuccess<AuthUserEntity>>());
        verify(() => mockAuthService.linkAnonymousWithGoogleCredential(any()))
            .called(1);
        verify(() => mockDocService.upsertUser(any())).called(1);
      });

      test(
          'credential-already-in-use: signOut + signInWithCredential fallback returns DataFailed(merge-required)',
          () async {
        final mockAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final freshUser = buildMockUser(uid: 'fresh-uid', isAnonymous: false);

        when(() => mockGoogleAuth.idToken).thenReturn('id-token');
        when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
        when(() => mockGoogleService.signIn())
            .thenAnswer((_) async => mockAccount);
        when(() => mockGoogleService.getAuthentication(mockAccount))
            .thenAnswer((_) async => mockGoogleAuth);
        when(() => mockAuthService.linkAnonymousWithGoogleCredential(any()))
            .thenThrow(const AuthException(
          message: 'already-in-use',
          code: 'credential-already-in-use',
        ));
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});
        when(() => mockAuthService.signInWithCredential(any()))
            .thenAnswer((_) async => freshUser);
        when(() => mockDocService.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.linkAnonymousWithGoogle();

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<AuthException>());
        expect((result.error as AuthException).code, equals('merge-required'));
        verify(() => mockAuthService.signOut()).called(1);
        verify(() => mockAuthService.signInWithCredential(any())).called(1);
        verify(() => mockDocService.upsertUser(any())).called(1);
      });

      test('cancelled (signIn returns null): returns DataFailed', () async {
        when(() => mockGoogleService.signIn()).thenAnswer((_) async => null);

        final result = await repository.linkAnonymousWithGoogle();

        expect(result, isA<DataFailed<AuthUserEntity>>());
        expect(result.error, isA<AuthException>());
        expect((result.error as AuthException).code, equals('cancelled'));
      });
    });
  });
}
