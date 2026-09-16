import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/credential_errors.dart';

part 'sign_in_state.dart';

/// Holds the sign-in form. Validation rules come from [SignInParams] so the
/// form and the use case never disagree.
class SignInCubit extends Cubit<SignInState> {
  final SignInWithEmailUseCase _signInWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;

  SignInCubit(this._signInWithEmail, this._signInWithGoogle)
      : super(const SignInState());

  void emailChanged(String value) {
    emit(state.copyWith(
      email: value,
      status: SignInStatus.editing,
      passwordError: state.passwordError,
    ));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: value,
      status: SignInStatus.editing,
      emailError: state.emailError,
    ));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(
      obscurePassword: !state.obscurePassword,
      emailError: state.emailError,
      passwordError: state.passwordError,
      failure: state.failure,
    ));
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final errors = state.params.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        status: SignInStatus.failure,
        emailError: CredentialErrors.forEmail(errors),
        passwordError: CredentialErrors.forPassword(errors),
      ));
      return;
    }

    emit(state.copyWith(status: SignInStatus.submitting));
    _finish(await _signInWithEmail(state.params));
  }

  Future<void> signInWithGoogle() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: SignInStatus.submitting));
    _finish(await _signInWithGoogle(const NoParams()));
  }

  void _finish(DataState<UserEntity> result) {
    if (isClosed) return;
    switch (result) {
      case DataSuccess():
        emit(state.copyWith(status: SignInStatus.success));
      case DataFailed(:final failure):
        emit(state.copyWith(status: SignInStatus.failure, failure: failure));
    }
  }
}
