import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/exceptions/profile_exceptions.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/params/update_profile_params.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/update_profile.dart';
import 'package:news_app_clean_architecture/features/profiles/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/profiles/presentation/bloc/edit_profile/edit_profile_state.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  late MockUpdateProfileUseCase updateProfile;
  const user = UserEntity(uid: 'user-1', firstName: 'Janet', lastName: 'Doe', bio: '', role: UserRole.reader);

  setUpAll(() => registerFallbackValue(UpdateProfileParams(firstName: '', lastName: '', bio: '')));

  setUp(() => updateProfile = MockUpdateProfileUseCase());

  Future<void> save(EditProfileCubit cubit) => cubit.save(firstName: 'Janet', lastName: 'Doe', bio: '');

  blocTest<EditProfileCubit, EditProfileState>(
    'saves the profile',
    setUp: () => when(() => updateProfile(any())).thenAnswer((_) async => const DataSuccess(user)),
    build: () => EditProfileCubit(updateProfile),
    act: save,
    expect:
        () => const [
          EditProfileState(status: EditProfileStatus.saving),
          EditProfileState(status: EditProfileStatus.success),
        ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'shows the validation errors',
    setUp:
        () => when(() => updateProfile(any())).thenAnswer(
          (_) async => const DataFailed(ProfileValidationException({ProfileValidationError.firstNameEmpty})),
        ),
    build: () => EditProfileCubit(updateProfile),
    act: save,
    expect:
        () => const [
          EditProfileState(status: EditProfileStatus.saving),
          EditProfileState(
            status: EditProfileStatus.failure,
            validationErrors: {ProfileValidationError.firstNameEmpty},
          ),
        ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'reports an unexpected failure without validation errors',
    setUp: () => when(() => updateProfile(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: () => EditProfileCubit(updateProfile),
    act: save,
    expect:
        () => const [
          EditProfileState(status: EditProfileStatus.saving),
          EditProfileState(status: EditProfileStatus.failure),
        ],
  );
}
