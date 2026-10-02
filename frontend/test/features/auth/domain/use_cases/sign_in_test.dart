import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SignInUseCase signIn;

  const user = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
  const validParams = SignInParams(email: ' jane@example.com ', password: 'a-long-password');

  setUp(() {
    repository = MockAuthRepository();
    signIn = SignInUseCase(repository);
  });

  group('SignInParams', () {
    test('are valid with an email and a password', () {
      expect(validParams.isValid, isTrue);
    });

    test('need a valid email and a password', () {
      const params = SignInParams(email: 'jane@', password: '');

      expect(params.emailError, CredentialsError.invalidEmail);
      expect(params.passwordError, CredentialsError.blank);
      expect(params.isValid, isFalse);
    });

    test('copyWith changes only the given field', () {
      expect(validParams.copyWith(password: 'other'), const SignInParams(email: ' jane@example.com ', password: 'other'));
    });
  });

  test('signs in through the repository with the email without spaces', () async {
    when(() => repository.signIn('jane@example.com', 'a-long-password'))
        .thenAnswer((_) async => const DataSuccess(user));

    final dataState = await signIn(params: validParams);

    expect(dataState, isA<DataSuccess>());
    expect(dataState.data, user);
  });

  test('does not reach the repository with invalid params', () async {
    const params = SignInParams(email: 'jane');

    final dataState = await signIn(params: params);

    expect(dataState, isA<DataFailed>());
    expect((dataState.error! as InvalidSignInException).params, params);
    verifyNever(() => repository.signIn(any(), any()));
  });

  test('returns the failure of the repository', () async {
    const error = AuthException(AuthError.wrongEmailOrPassword);
    when(() => repository.signIn(any(), any())).thenAnswer((_) async => const DataFailed(error));

    final dataState = await signIn(params: validParams);

    expect(dataState.error, error);
  });
}
