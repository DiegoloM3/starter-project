import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('signs out through the repository', () async {
    final repository = MockAuthRepository();
    when(() => repository.signOut()).thenAnswer((_) async => const DataSuccess(null));

    final dataState = await SignOutUseCase(repository)();

    expect(dataState, isA<DataSuccess>());
    verify(() => repository.signOut()).called(1);
  });
}
