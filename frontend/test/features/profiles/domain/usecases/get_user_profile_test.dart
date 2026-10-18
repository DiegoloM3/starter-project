import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/get_user_profile.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

import 'profile_test_data.dart';

void main() {
  test('gets the profile from the repository', () async {
    const user = UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.reader);
    final repository = MockProfileRepository();
    when(() => repository.getProfile('user-1')).thenAnswer((_) async => const DataSuccess(user));

    final result = await GetUserProfileUseCase(repository).call('user-1');

    expect(result.data, user);
  });
}
