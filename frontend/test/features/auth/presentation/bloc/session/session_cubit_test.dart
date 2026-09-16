import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late SessionHarness harness;

  setUp(() => harness = SessionHarness());
  tearDown(() => harness.dispose());

  test('starts unknown until the auth stream answers', () {
    expect(harness.cubit.state, const SessionUnknown());
    expect(harness.cubit.state.isAuthenticated, isFalse);
    expect(harness.cubit.state.user, isNull);
  });

  test('mirrors the auth stream: a user signs in, then out', () async {
    final states = <SessionState>[];
    final subscription = harness.cubit.stream.listen(states.add);

    harness.signIn(user);
    await flush();
    harness.signOutUser();
    await flush();
    await subscription.cancel();

    expect(states, [const SessionAuthenticated(user), const SessionUnauthenticated()]);
    expect(const SessionAuthenticated(user).isAuthenticated, isTrue);
  });

  test('signOut marks the session busy and lets the stream finish it', () async {
    when(() => harness.signOut(any())).thenAnswer((_) async {
      harness.users.add(null);
      return const DataSuccess(null);
    });
    harness.signIn(user);
    await flush();

    final states = <SessionState>[];
    final subscription = harness.cubit.stream.listen(states.add);
    await harness.cubit.signOut();
    await flush();
    await subscription.cancel();

    expect(states, [
      const SessionAuthenticated(user, isBusy: true),
      const SessionUnauthenticated(),
    ]);
    verify(() => harness.signOut(any())).called(1);
  });

  test('a failed sign-out keeps the session and reports the failure', () async {
    const failure = Failure.network();
    when(() => harness.signOut(any())).thenAnswer((_) async => const DataFailed(failure));
    harness.signIn(user);
    await flush();

    await harness.cubit.signOut();

    expect(harness.cubit.state, const SessionAuthenticated(user, failure: failure));
  });

  test('account actions are ignored while signed out', () async {
    harness.signOutUser();
    await flush();

    await harness.cubit.signOut();

    verifyNever(() => harness.signOut(any()));
  });

  test('a second action is ignored while the first is still running', () async {
    final gate = Completer<DataState<void>>();
    when(() => harness.signOut(any())).thenAnswer((_) => gate.future);
    harness.signIn(user);
    await flush();

    final first = harness.cubit.signOut();
    await harness.cubit.signOut();
    gate.complete(const DataSuccess(null));
    await first;

    verify(() => harness.signOut(any())).called(1);
  });

}
