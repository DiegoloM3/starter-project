import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  test('returns DataSuccess with AuthUserEntity on success', () async {
    final user = testAuthUser();
    when(() => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => DataSuccess(user));

    final result = await useCase(
      params: const SignInParams(email: tEmail, password: tPassword),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data, user);
    verify(() => mockRepository.signIn(
          email: tEmail,
          password: tPassword,
        )).called(1);
  });

  test('returns DataFailed on invalid credentials', () async {
    const error = AuthException(
      message: 'No account found',
      code: 'user-not-found',
    );
    when(() => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(
      params: const SignInParams(email: tEmail, password: tPassword),
    );

    expect(result, isA<DataFailed>());
    expect(result.error, isA<AuthException>());
  });
}
