import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/register.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late RegisterUseCase register;

  const user = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
  const validDraft = RegistrationDraftEntity(
    name: 'Jane Doe',
    email: 'jane@example.com',
    password: 'a-long-password',
    passwordConfirmation: 'a-long-password',
  );

  setUpAll(() => registerFallbackValue(const RegistrationDraftEntity()));

  setUp(() {
    repository = MockAuthRepository();
    register = RegisterUseCase(repository);
  });

  test('creates the account of a valid draft through the repository', () async {
    when(() => repository.register(validDraft)).thenAnswer((_) async => const DataSuccess(user));

    final dataState = await register(params: validDraft);

    expect(dataState, isA<DataSuccess>());
    expect(dataState.data, user);
  });

  test('does not reach the repository with an invalid draft', () async {
    final draft = validDraft.copyWith(passwordConfirmation: 'another-password');

    final dataState = await register(params: draft);

    expect(dataState, isA<DataFailed>());
    expect((dataState.error! as InvalidRegistrationException).draft, draft);
    verifyNever(() => repository.register(any()));
  });

  test('returns the failure of the repository', () async {
    const error = AuthException(AuthError.emailAlreadyInUse);
    when(() => repository.register(validDraft)).thenAnswer((_) async => const DataFailed(error));

    final dataState = await register(params: validDraft);

    expect(dataState.error, error);
  });
}
