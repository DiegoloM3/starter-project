import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service_impl.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late GoogleSignInService service;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    service = GoogleSignInServiceImpl(mockGoogleSignIn);
  });

  group('GoogleSignInService', () {
    test('signIn returns GoogleSignInAccount on success', () async {
      final mockAccount = MockGoogleSignInAccount();
      when(() => mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockAccount);

      final result = await service.signIn();

      expect(result, equals(mockAccount));
    });

    test('signIn returns null when user cancels', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await service.signIn();

      expect(result, isNull);
    });

    test('getAuthentication returns GoogleSignInAuthentication', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();
      when(() => mockAccount.authentication)
          .thenAnswer((_) async => mockAuth);

      final result = await service.getAuthentication(mockAccount);

      expect(result, equals(mockAuth));
    });

    test('signOut completes successfully', () async {
      when(() => mockGoogleSignIn.signOut())
          .thenAnswer((_) async => null);

      await expectLater(service.signOut(), completes);
    });
  });
}
