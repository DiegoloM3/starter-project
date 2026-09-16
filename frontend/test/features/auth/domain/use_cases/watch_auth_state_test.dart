import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  test('re-emits the repository stream', () {
    final auth = MockAuthRepository();
    when(() => auth.watchAuthState()).thenAnswer((_) => Stream.fromIterable([null, user, null]));

    final stream = WatchAuthStateUseCase(auth)(const NoParams());

    expect(stream, emitsInOrder([null, user, null, emitsDone]));
  });
}
