import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_session.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_state.dart';

class MockWatchSessionUseCase extends Mock implements WatchSessionUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late StreamController<UserEntity?> session;
  late MockSignOutUseCase signOut;
  late SessionCubit cubit;

  const user = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');

  setUp(() {
    session = StreamController<UserEntity?>();
    final watchSession = MockWatchSessionUseCase();
    when(() => watchSession()).thenAnswer((_) => session.stream);
    signOut = MockSignOutUseCase();
    cubit = SessionCubit(watchSession, signOut);
  });

  tearDown(() async {
    await cubit.close();
    // Not awaited: closing a stream that nobody listened to never finishes.
    session.close();
  });

  test('does not know the session before reading it', () {
    expect(cubit.state, const SessionUnknown());
  });

  test('finishes loading once the session kept on the phone is known', () async {
    var isLoaded = false;
    cubit.watchSession().then((_) => isLoaded = true);
    await pumpEventQueue();
    expect(isLoaded, isFalse);

    session.add(user);
    await pumpEventQueue();

    expect(isLoaded, isTrue);
    expect(cubit.state, const SessionSignedIn(user));
  });

  test('follows every sign-in and sign-out', () async {
    final watching = cubit.watchSession();
    session.add(null);
    await watching;

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const SessionSignedIn(user), const SessionSignedOut()]),
    );
    session
      ..add(user)
      ..add(null);
    await states;
  });

  test('signs out through its use case', () async {
    when(() => signOut()).thenAnswer((_) async => const DataSuccess(null));

    await cubit.signOut();

    verify(() => signOut()).called(1);
  });
}
