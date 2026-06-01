import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';
import 'package:tortutip/features/tortu_feed/domain/use_cases/update_category_progress_use_case.dart';

class MockTortuFeedRepository extends Mock implements TortuFeedRepository {}

void main() {
  late UpdateCategoryProgressUseCase useCase;
  late MockTortuFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockTortuFeedRepository();
    useCase = UpdateCategoryProgressUseCase(mockRepository);
  });

  const params =
      UpdateCategoryProgressParams(userId: 'user_1', categoryId: 'cat_1');

  group('UpdateCategoryProgressUseCase', () {
    test('should_return_DataSuccess_with_new_progress_when_succeeds',
        () async {
      when(() => mockRepository.updateCategoryProgress(params))
          .thenAnswer((_) async => const DataSuccess(0.02));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<double>>());
      expect(result.data, equals(0.02));
      verify(() => mockRepository.updateCategoryProgress(params)).called(1);
    });

    test('should_return_DataFailed_when_throws', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.updateCategoryProgress(params))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<double>>());
      expect(result.error, equals(exception));
    });
  });
}
