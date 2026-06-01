import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';
import 'package:tortutip/features/tortu_feed/domain/use_cases/feed_tortu_use_case.dart';

class MockTortuFeedRepository extends Mock implements TortuFeedRepository {}

void main() {
  late FeedTortuUseCase useCase;
  late MockTortuFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockTortuFeedRepository();
    useCase = FeedTortuUseCase(mockRepository);
  });

  const params = FeedTortuParams(
    userId: 'user_1',
    articleId: 'article_1',
    categoryId: 'cat_1',
    date: '2026-06-01',
  );

  group('FeedTortuUseCase', () {
    test('should_return_DataSuccess_void_when_repository_succeeds', () async {
      when(() => mockRepository.feedTortu(params))
          .thenAnswer((_) async => const DataSuccess(false));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      verify(() => mockRepository.feedTortu(params)).called(1);
    });

    test('should_return_DataFailed_when_repository_throws', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.feedTortu(params))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<void>>());
      expect(result.error, equals(exception));
    });
  });
}
