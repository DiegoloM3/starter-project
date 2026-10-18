import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_current_user.dart';

import 'auth_test_data.dart';

void main() {
  test('emits the users of the repository', () {
    final repository = MockAuthRepository();
    when(() => repository.watchCurrentUser()).thenAnswer((_) => Stream.fromIterable([null, testUser]));

    final users = WatchCurrentUserUseCase(repository).call(const NoParams());

    expect(users, emitsInOrder([null, testUser]));
  });
}
