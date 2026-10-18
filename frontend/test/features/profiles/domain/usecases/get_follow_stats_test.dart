import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/entities/follow_stats.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/get_follow_stats.dart';

import 'profile_test_data.dart';

void main() {
  test('gets the follow stats from the repository', () async {
    const stats = FollowStats(followers: 3, following: 5);
    final repository = MockProfileRepository();
    when(() => repository.getFollowStats('user-1')).thenAnswer((_) async => const DataSuccess(stats));

    final result = await GetFollowStatsUseCase(repository).call('user-1');

    expect(result.data, stats);
  });
}
