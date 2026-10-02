import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';

import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final SignInUseCase _signInUseCase;

  SignInCubit(this._signInUseCase) : super(const SignInEditing(SignInParams()));

  void updateEmail(String email) => _updateParams(state.params.copyWith(email: email));

  void updatePassword(String password) => _updateParams(state.params.copyWith(password: password));

  Future<void> signIn() async {
    emit(SignInInProgress(state.params));
    final dataState = await _signInUseCase(params: state.params);
    if (dataState is DataSuccess) {
      emit(SignInSuccess(state.params, dataState.data!));
      return;
    }
    _emitSignInFailure(dataState.error!);
  }

  void _emitSignInFailure(Exception error) {
    if (error is InvalidSignInException) {
      emit(SignInEditing(state.params, showsValidationErrors: true));
      return;
    }
    emit(SignInFailure(state.params, error));
  }

  void _updateParams(SignInParams params) {
    emit(SignInEditing(params, showsValidationErrors: _showsValidationErrors));
  }

  bool get _showsValidationErrors {
    final state = this.state;
    return state is SignInEditing && state.showsValidationErrors;
  }
}
