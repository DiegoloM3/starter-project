import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:tortutip/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/use_cases/select_user_categories_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_profile_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_role_use_case.dart';

class MockUpdateUserRoleUseCase extends Mock implements UpdateUserRoleUseCase {}

class MockSelectUserCategoriesUseCase extends Mock
    implements SelectUserCategoriesUseCase {}

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

void main() {
  late OnboardingCubit cubit;
  late MockUpdateUserRoleUseCase mockUpdateUserRole;
  late MockSelectUserCategoriesUseCase mockSelectCategories;
  late MockUpdateUserProfileUseCase mockUpdateUserProfile;

  final testUser = UserEntity(
    id: 'user_1',
    name: 'Test User',
    email: 'test@test.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: 'male',
    ageRange: '25-34',
    createdAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(
        const UpdateUserRoleParams(userId: '', role: ''));
    registerFallbackValue(
        const SelectUserCategoriesParams(userId: '', categoryIds: []));
    registerFallbackValue(UpdateUserProfileParams(user: testUser));
  });

  setUp(() {
    mockUpdateUserRole = MockUpdateUserRoleUseCase();
    mockSelectCategories = MockSelectUserCategoriesUseCase();
    mockUpdateUserProfile = MockUpdateUserProfileUseCase();
    cubit = OnboardingCubit(
      mockUpdateUserRole,
      mockSelectCategories,
      mockUpdateUserProfile,
    );
  });

  tearDown(() => cubit.close());

  group('OnboardingCubit.selectRole', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'should_emit_Loading_then_RoleSelected_when_update_succeeds',
      build: () {
        when(() => mockUpdateUserRole(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      act: (c) => c.selectRole('user_1', 'reader'),
      expect: () => [
        isA<OnboardingLoading>(),
        isA<OnboardingRoleSelected>(),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should_emit_Loading_then_Error_when_update_fails',
      build: () {
        when(() => mockUpdateUserRole(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.selectRole('user_1', 'reader'),
      expect: () => [
        isA<OnboardingLoading>(),
        isA<OnboardingError>(),
      ],
    );
  });

  group('OnboardingCubit.selectCategories', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'should_emit_Loading_then_Complete_when_select_succeeds',
      build: () {
        when(() => mockSelectCategories(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      act: (c) => c.selectCategories('user_1', ['cat_1', 'cat_2']),
      expect: () => [
        isA<OnboardingLoading>(),
        isA<OnboardingComplete>(),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should_emit_Loading_then_Error_when_select_fails',
      build: () {
        when(() => mockSelectCategories(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.selectCategories('user_1', ['cat_1']),
      expect: () => [
        isA<OnboardingLoading>(),
        isA<OnboardingError>(),
      ],
    );
  });

  group('OnboardingCubit.completeOnboarding', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'should_emit_loading_then_complete_when_profile_update_succeeds',
      build: () {
        when(() => mockUpdateUserProfile(any()))
            .thenAnswer((_) async => DataSuccess(testUser));
        return cubit;
      },
      act: (c) => c.completeOnboarding(testUser),
      expect: () => [
        isA<OnboardingLoading>(),
        isA<OnboardingComplete>(),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should_emit_loading_then_error_when_profile_update_fails',
      build: () {
        when(() => mockUpdateUserProfile(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.completeOnboarding(testUser),
      expect: () => [
        isA<OnboardingLoading>(),
        isA<OnboardingError>(),
      ],
    );
  });
}
