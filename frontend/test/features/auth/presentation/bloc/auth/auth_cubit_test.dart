import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_state.dart';

class MockWatchCurrentUserUseCase extends Mock implements WatchCurrentUserUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

const testUser = UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.reader);

void main() {
  late MockWatchCurrentUserUseCase watchCurrentUser;
  late MockSignOutUseCase signOut;
  late StreamController<UserEntity?> currentUser;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    watchCurrentUser = MockWatchCurrentUserUseCase();
    signOut = MockSignOutUseCase();
    currentUser = StreamController();
    when(() => watchCurrentUser(any())).thenAnswer((_) => currentUser.stream);
    when(() => signOut(any())).thenAnswer((_) async => const DataSuccess(null));
  });

  tearDown(() => currentUser.close());

  AuthCubit buildCubit() => AuthCubit(watchCurrentUser, signOut);

  test('starts without knowing the session', () {
    expect(buildCubit().state, const AuthUnknown());
  });

  blocTest<AuthCubit, AuthState>(
    'is unauthenticated when nobody is signed in',
    build: buildCubit,
    act: (_) => currentUser.add(null),
    expect: () => [const AuthUnauthenticated()],
  );

  blocTest<AuthCubit, AuthState>(
    'is authenticated with the signed in user',
    build: buildCubit,
    act: (_) => currentUser.add(testUser),
    expect: () => [const AuthAuthenticated(testUser)],
  );

  blocTest<AuthCubit, AuthState>(
    'signs out through the use case',
    build: buildCubit,
    act: (cubit) => cubit.signOut(),
    verify: (_) => verify(() => signOut(any())).called(1),
  );
}
