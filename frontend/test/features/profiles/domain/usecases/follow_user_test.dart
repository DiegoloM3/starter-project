import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/follow_user.dart';

import 'profile_test_data.dart';

void main() {
  test('follows the user through the repository', () async {
    final repository = MockProfileRepository();
    when(() => repository.follow('user-1')).thenAnswer((_) async => const DataSuccess(null));

    final result = await FollowUserUseCase(repository).call('user-1');

    expect(result, isA<DataSuccess>());
    verify(() => repository.follow('user-1')).called(1);
  });
}
