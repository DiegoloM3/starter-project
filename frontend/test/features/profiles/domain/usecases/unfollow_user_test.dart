import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/unfollow_user.dart';

import 'profile_test_data.dart';

void main() {
  test('unfollows the user through the repository', () async {
    final repository = MockProfileRepository();
    when(() => repository.unfollow('user-1')).thenAnswer((_) async => const DataSuccess(null));

    final result = await UnfollowUserUseCase(repository).call('user-1');

    expect(result, isA<DataSuccess>());
    verify(() => repository.unfollow('user-1')).called(1);
  });
}
