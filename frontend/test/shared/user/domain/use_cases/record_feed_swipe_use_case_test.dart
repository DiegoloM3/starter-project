import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/record_feed_swipe_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late RecordFeedSwipeUseCase useCase;
  late MockUserRepository mockRepository;

  final updatedUser = UserEntity(
    id: 'user_1',
    name: 'Test',
    email: 'test@test.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
    streakDays: 1,
    lastFeedDate: '2024-01-01',
    overallProgress: 0.01,
  );

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = RecordFeedSwipeUseCase(mockRepository);
  });

  group('RecordFeedSwipeUseCase', () {
    test('should_return_updated_user_when_repository_succeeds', () async {
      when(() => mockRepository.recordFeedSwipe('user_1'))
          .thenAnswer((_) async => DataSuccess(updatedUser));

      final result =
          await useCase(const RecordFeedSwipeParams(userId: 'user_1'));

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(updatedUser));
      verify(() => mockRepository.recordFeedSwipe('user_1')).called(1);
    });

    test('should_return_failure_when_repository_throws', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.recordFeedSwipe('user_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result =
          await useCase(const RecordFeedSwipeParams(userId: 'user_1'));

      expect(result, isA<DataFailed<UserEntity>>());
      expect(result.error, equals(exception));
    });
  });
}
