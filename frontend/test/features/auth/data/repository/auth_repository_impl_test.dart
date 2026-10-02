import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  const storedUser = UserModel(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
  const draft = RegistrationDraftEntity(
    name: 'Jane Doe',
    email: 'jane@example.com',
    password: 'a-long-password',
    passwordConfirmation: 'a-long-password',
  );
  const error = AuthException(AuthError.noConnection);

  setUp(() {
    dataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  test('reports the session as entities', () {
    when(() => dataSource.watchSession()).thenAnswer((_) => Stream.fromIterable([storedUser, null]));

    expect(
      repository.watchSession(),
      emitsInOrder([
        isA<UserEntity>().having((user) => user is UserModel, 'is a model', isFalse),
        null,
        emitsDone,
      ]),
    );
  });

  group('signIn', () {
    test('returns the signed-in account as an entity', () async {
      when(() => dataSource.signIn('jane@example.com', 'a-long-password')).thenAnswer((_) async => storedUser);

      final dataState = await repository.signIn('jane@example.com', 'a-long-password');

      expect(dataState, isA<DataSuccess>());
      expect(dataState.data, storedUser.toEntity());
      expect(dataState.data, isNot(isA<UserModel>()));
    });

    test('returns the exception thrown by the data source as a failure', () async {
      when(() => dataSource.signIn(any(), any())).thenThrow(error);

      final dataState = await repository.signIn('jane@example.com', 'a-long-password');

      expect(dataState, isA<DataFailed>());
      expect(dataState.error, error);
    });
  });

  group('register', () {
    test('returns the new account as an entity', () async {
      when(() => dataSource.register(draft)).thenAnswer((_) async => storedUser);

      final dataState = await repository.register(draft);

      expect(dataState.data, storedUser.toEntity());
    });

    test('returns the exception thrown by the data source as a failure', () async {
      when(() => dataSource.register(draft)).thenThrow(error);

      final dataState = await repository.register(draft);

      expect(dataState.error, error);
    });
  });

  group('signOut', () {
    test('signs out through the data source', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      final dataState = await repository.signOut();

      expect(dataState, isA<DataSuccess>());
      verify(() => dataSource.signOut()).called(1);
    });

    test('returns the exception thrown by the data source as a failure', () async {
      when(() => dataSource.signOut()).thenThrow(error);

      final dataState = await repository.signOut();

      expect(dataState.error, error);
    });
  });
}
