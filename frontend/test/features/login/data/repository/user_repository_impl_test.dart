import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/login/data/data_sources/remote/users_service.dart';
import 'package:news_app_clean_architecture/features/login/data/models/user.dart';
import 'package:news_app_clean_architecture/features/login/data/repository/user_repository_impl.dart';

class MockUsersService extends Mock implements UsersService {}

void main() {
  late UserRepositoryImpl userRepositoryImpl;
  late MockUsersService mockUsersService;

  setUp(() {
    mockUsersService = MockUsersService();
    userRepositoryImpl = UserRepositoryImpl(mockUsersService);
  });

  const tUserModel = UserModel(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    profilePictureUrl: 'url',
  );

  final tUserEntity = tUserModel.toEntity();

  group('loginStream', () {
    test('should emit UserEntity when UsersService emits UserModel', () async {
      when(() => mockUsersService.loginStream)
          .thenAnswer((_) => Stream.value(tUserModel));

      expect(userRepositoryImpl.loginStream, emits(tUserEntity));
    });

    test('should emit null when UsersService emits null', () async {
      when(() => mockUsersService.loginStream)
          .thenAnswer((_) => Stream.value(null));

      expect(userRepositoryImpl.loginStream, emits(null));
    });
  });

  group('signInWithEmailAndPassword', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';

    test('should return DataSuccess when signIn is successful', () async {
      when(() => mockUsersService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => {});

      final result = await userRepositoryImpl.signInWithEmailAndPassword(
          email: tEmail, password: tPassword);

      expect(result, isA<DataSuccess>());
      verify(() => mockUsersService.signInWithEmailAndPassword(
          email: tEmail, password: tPassword)).called(1);
    });

    test('should return DataFailed when signIn fails', () async {
      when(() => mockUsersService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception());

      final result = await userRepositoryImpl.signInWithEmailAndPassword(
          email: tEmail, password: tPassword);

      expect(result, isA<DataFailed>());
    });
  });

  group('signOut', () {
    test('should return DataSuccess when signOut is successful', () async {
      when(() => mockUsersService.signOut()).thenAnswer((_) async => {});

      final result = await userRepositoryImpl.signOut();

      expect(result, isA<DataSuccess>());
      verify(() => mockUsersService.signOut()).called(1);
    });

    test('should return DataFailed when signOut fails', () async {
      when(() => mockUsersService.signOut()).thenThrow(Exception());

      final result = await userRepositoryImpl.signOut();

      expect(result, isA<DataFailed>());
    });
  });

  group('createUser', () {
    const tPassword = 'password';
    const tUserId = '1';

    setUpAll(() {
      registerFallbackValue(tUserModel);
    });

    test('should return DataSuccess when createUser is successful', () async {
      when(() => mockUsersService.createCredentials(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserId);
      when(() => mockUsersService.createUser(any()))
          .thenAnswer((_) async => {});

      final result = await userRepositoryImpl.createUser(
        user: tUserEntity,
        password: tPassword,
      );

      expect(result, isA<DataSuccess>());
      verify(() => mockUsersService.createCredentials(
          email: tUserEntity.email, password: tPassword)).called(1);
      verify(() => mockUsersService.createUser(any())).called(1);
    });

    test('should return DataFailed when creating credentials fails', () async {
      when(() => mockUsersService.createCredentials(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception());

      final result = await userRepositoryImpl.createUser(
        user: tUserEntity,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
      verifyNever(() => mockUsersService.createUser(any()));
    });

    test('should return DataFailed when creating user fails', () async {
      when(() => mockUsersService.createCredentials(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserId);
      when(() => mockUsersService.createUser(any())).thenThrow(Exception());

      final result = await userRepositoryImpl.createUser(
        user: tUserEntity,
        password: tPassword,
      );

      expect(result, isA<DataFailed>());
    });
  });
}
