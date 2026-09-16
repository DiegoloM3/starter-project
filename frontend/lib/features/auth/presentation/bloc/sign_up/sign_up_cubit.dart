import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/credential_errors.dart';

part 'sign_up_state.dart';

/// Holds the create-account form. Typing in a field clears that field's
/// error; the other fields keep theirs until the next submit.
class SignUpCubit extends Cubit<SignUpState> {
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;

  SignUpCubit(this._signUpWithEmail, this._signInWithGoogle)
      : super(const SignUpState());

  void displayNameChanged(String value) {
    emit(state.copyWith(
      displayName: value,
      status: SignUpStatus.editing,
      emailError: state.emailError,
      passwordError: state.passwordError,
    ));
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: value,
      status: SignUpStatus.editing,
      displayNameError: state.displayNameError,
      passwordError: state.passwordError,
    ));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: value,
      status: SignUpStatus.editing,
      displayNameError: state.displayNameError,
      emailError: state.emailError,
    ));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(
      obscurePassword: !state.obscurePassword,
      displayNameError: state.displayNameError,
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
        status: SignUpStatus.failure,
        displayNameError: CredentialErrors.forDisplayName(errors),
        emailError: CredentialErrors.forEmail(errors),
        passwordError: CredentialErrors.forPassword(errors),
      ));
      return;
    }

    emit(state.copyWith(status: SignUpStatus.submitting));
    _finish(await _signUpWithEmail(state.params));
  }

  Future<void> signInWithGoogle() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: SignUpStatus.submitting));
    _finish(await _signInWithGoogle(const NoParams()));
  }

  void _finish(DataState<UserEntity> result) {
    if (isClosed) return;
    switch (result) {
      case DataSuccess():
        emit(state.copyWith(status: SignUpStatus.success));
      case DataFailed(:final failure):
        emit(state.copyWith(status: SignUpStatus.failure, failure: failure));
    }
  }
}
