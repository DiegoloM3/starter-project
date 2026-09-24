import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/auth_failures.dart';
import '../../../domain/params/request_password_reset_params.dart';
import '../../../domain/use_cases/request_password_reset.dart';
import 'password_reset_state.dart';

/// Drives the "forgot my password" screen.
///
/// It is kept apart from [SessionCubit] because sending a reset email says
/// nothing about who is signed in; folding it in would put a transient screen
/// flag into the app wide session state.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  final RequestPasswordResetUseCase _requestPasswordReset;

  PasswordResetCubit(this._requestPasswordReset)
      : super(const PasswordResetState());

  Future<void> requestReset(String email) async {
    emit(const PasswordResetState(status: PasswordResetStatus.sending));

    final result = await _requestPasswordReset(
      RequestPasswordResetParams(email),
    );

    if (result is DataSuccess) {
      emit(const PasswordResetState(status: PasswordResetStatus.sent));
      return;
    }

    emit(PasswordResetState(
      status: PasswordResetStatus.failure,
      error: result.error,
      validationErrors: result.error is CredentialsValidationException
          ? (result.error as CredentialsValidationException).errors
          : const <CredentialsValidationError>[],
    ));
  }
}
