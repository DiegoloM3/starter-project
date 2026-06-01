import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_profile_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_role_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/select_user_categories_use_case.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final UpdateUserRoleUseCase _updateUserRole;
  final SelectUserCategoriesUseCase _selectCategories;
  final UpdateUserProfileUseCase _updateUserProfile;

  UserEntity? currentUser;

  OnboardingCubit(
    this._updateUserRole,
    this._selectCategories,
    this._updateUserProfile,
  ) : super(const OnboardingInitial());

  Future<void> selectRole(String userId, String role) async {
    if (state is OnboardingLoading) return;
    emit(const OnboardingLoading());
    final result = await _updateUserRole(
        UpdateUserRoleParams(userId: userId, role: role));
    if (result.isSuccess) {
      emit(OnboardingRoleSelected(role));
    } else {
      emit(OnboardingError(_mapErrorToMessage(result.error!)));
    }
  }

  Future<void> selectCategories(String userId, List<String> categoryIds) async {
    if (state is OnboardingLoading || state is OnboardingComplete) return;
    emit(const OnboardingLoading());
    final result = await _selectCategories(
        SelectUserCategoriesParams(userId: userId, categoryIds: categoryIds));
    if (result.isSuccess) {
      emit(const OnboardingComplete());
    } else {
      emit(OnboardingError(_mapErrorToMessage(result.error!)));
    }
  }

  Future<void> completeOnboarding(UserEntity user) async {
    if (state is OnboardingLoading) return;
    emit(const OnboardingLoading());
    final result = await _updateUserProfile(UpdateUserProfileParams(user: user));
    if (result.isSuccess) {
      emit(const OnboardingComplete());
    } else {
      emit(OnboardingError(_mapErrorToMessage(result.error!)));
    }
  }

  String _mapErrorToMessage(Exception error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => 'No tienes permiso para realizar esta acción',
        'unavailable'       => 'Sin conexión. Inténtalo de nuevo',
        _                   => 'Algo salió mal. Inténtalo de nuevo',
      };
    }
    return 'Algo salió mal. Inténtalo de nuevo';
  }
}
