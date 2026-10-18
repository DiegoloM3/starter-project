import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';

import 'auth_test_data.dart';

void main() {
  test('signs out through the repository', () async {
    final repository = MockAuthRepository();
    when(() => repository.signOut()).thenAnswer((_) async => const DataSuccess(null));

    final result = await SignOutUseCase(repository).call(const NoParams());

    expect(result, isA<DataSuccess>());
    verify(() => repository.signOut()).called(1);
  });
}
