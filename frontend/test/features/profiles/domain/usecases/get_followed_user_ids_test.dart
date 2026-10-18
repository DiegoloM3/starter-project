import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/get_followed_user_ids.dart';

import 'profile_test_data.dart';

void main() {
  test('gets the ids of the followed users from the repository', () async {
    final repository = MockProfileRepository();
    when(() => repository.getFollowedUserIds()).thenAnswer((_) async => const DataSuccess(['user-1']));

    final result = await GetFollowedUserIdsUseCase(repository).call(const NoParams());

    expect(result.data, ['user-1']);
  });
}
