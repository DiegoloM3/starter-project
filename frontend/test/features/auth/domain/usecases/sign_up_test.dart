import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockRepository);
  });

  test('returns DataSuccess with new AuthUserEntity', () async {
    final user = testAuthUser();
    when(() => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => DataSuccess(user));

    final result = await useCase(
      params: const SignUpParams(email: tEmail, password: tPassword),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data, user);
  });

  test('returns DataFailed when email already in use', () async {
    const error = AuthException(
      message: 'An account already exists',
      code: 'email-already-in-use',
    );
    when(() => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(
      params: const SignUpParams(email: tEmail, password: tPassword),
    );

    expect(result, isA<DataFailed>());
    expect(result.error!.code, 'email-already-in-use');
  });
}
