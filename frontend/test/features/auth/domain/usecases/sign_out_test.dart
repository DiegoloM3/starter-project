import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';

import '../../../../helpers/mock_classes.dart';

void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockRepository);
  });

  test('returns DataSuccess on success', () async {
    when(() => mockRepository.signOut())
        .thenAnswer((_) async => const DataSuccess(null));

    final result = await useCase();

    expect(result, isA<DataSuccess>());
    verify(() => mockRepository.signOut()).called(1);
  });

  test('returns DataFailed on error', () async {
    const error = AuthException(message: 'Sign out failed', code: 'err');
    when(() => mockRepository.signOut())
        .thenAnswer((_) async => const DataFailed(error));

    final result = await useCase();

    expect(result, isA<DataFailed>());
  });
}
