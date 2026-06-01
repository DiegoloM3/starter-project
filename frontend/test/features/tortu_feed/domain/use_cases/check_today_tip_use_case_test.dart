import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';
import 'package:tortutip/features/tortu_feed/domain/use_cases/check_today_tip_use_case.dart';

class MockTortuFeedRepository extends Mock implements TortuFeedRepository {}

void main() {
  late CheckTodayTipUseCase useCase;
  late MockTortuFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockTortuFeedRepository();
    useCase = CheckTodayTipUseCase(mockRepository);
  });

  const params = CheckTodayTipParams(userId: 'user_1', date: '2026-06-01');

  group('CheckTodayTipUseCase', () {
    test('should_return_DataSuccess_true_when_tip_exists', () async {
      when(() => mockRepository.checkTodayTip(params))
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
      verify(() => mockRepository.checkTodayTip(params)).called(1);
    });

    test('should_return_DataSuccess_false_when_no_tip', () async {
      when(() => mockRepository.checkTodayTip(params))
          .thenAnswer((_) async => const DataSuccess(false));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isFalse);
    });

    test('should_return_DataFailed_when_repository_throws', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.checkTodayTip(params))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<bool>>());
      expect(result.error, equals(exception));
    });
  });
}
