import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('follows the session reported by the repository', () {
    const user = UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com');
    final repository = MockAuthRepository();
    when(() => repository.watchSession()).thenAnswer((_) => Stream.fromIterable([null, user, null]));

    expect(WatchSessionUseCase(repository)(), emitsInOrder([null, user, null, emitsDone]));
  });
}
