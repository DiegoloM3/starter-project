import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/exceptions/profile_exceptions.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/params/update_profile_params.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/update_profile.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

import 'profile_test_data.dart';

void main() {
  late MockProfileRepository repository;

  setUpAll(() => registerFallbackValue(UpdateProfileParams(firstName: '', lastName: '', bio: '')));

  setUp(() => repository = MockProfileRepository());

  test('updates a valid profile through the repository', () async {
    const user = UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.reader);
    final params = UpdateProfileParams(firstName: 'Jane', lastName: 'Doe', bio: '');
    when(() => repository.updateProfile(params)).thenAnswer((_) async => const DataSuccess(user));

    final result = await UpdateProfileUseCase(repository).call(params);

    expect(result.data, user);
  });

  test('fails with the validation errors without calling the repository', () async {
    final result = await UpdateProfileUseCase(
      repository,
    ).call(UpdateProfileParams(firstName: '', lastName: 'Doe', bio: ''));

    final error = result.error as ProfileValidationException;
    expect(error.errors, {ProfileValidationError.firstNameEmpty});
    verifyNever(() => repository.updateProfile(any()));
  });
}
