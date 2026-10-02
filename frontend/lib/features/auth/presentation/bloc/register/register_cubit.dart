import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/register.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterEditing(RegistrationDraftEntity()));

  void updateName(String name) => _updateDraft(state.draft.copyWith(name: name));

  void updateEmail(String email) => _updateDraft(state.draft.copyWith(email: email));

  void updatePassword(String password) => _updateDraft(state.draft.copyWith(password: password));

  void updatePasswordConfirmation(String passwordConfirmation) =>
      _updateDraft(state.draft.copyWith(passwordConfirmation: passwordConfirmation));

  Future<void> register() async {
    emit(RegisterInProgress(state.draft));
    final dataState = await _registerUseCase(params: state.draft);
    if (dataState is DataSuccess) {
      emit(RegisterSuccess(state.draft, dataState.data!));
      return;
    }
    _emitRegisterFailure(dataState.error!);
  }

  void _emitRegisterFailure(Exception error) {
    if (error is InvalidRegistrationException) {
      emit(RegisterEditing(state.draft, showsValidationErrors: true));
      return;
    }
    emit(RegisterFailure(state.draft, error));
  }

  void _updateDraft(RegistrationDraftEntity draft) {
    emit(RegisterEditing(draft, showsValidationErrors: _showsValidationErrors));
  }

  bool get _showsValidationErrors {
    final state = this.state;
    return state is RegisterEditing && state.showsValidationErrors;
  }
}
