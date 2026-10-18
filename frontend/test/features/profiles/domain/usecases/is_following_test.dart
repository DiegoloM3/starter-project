import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/is_following.dart';

import 'profile_test_data.dart';

void main() {
  test('asks the repository whether the signed in user follows the user', () async {
    final repository = MockProfileRepository();
    when(() => repository.isFollowing('user-1')).thenAnswer((_) async => const DataSuccess(true));

    final result = await IsFollowingUseCase(repository).call('user-1');

    expect(result.data, isTrue);
  });
}
