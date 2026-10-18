import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../domain/exceptions/auth_exceptions.dart';
import '../../../domain/params/sign_in_params.dart';
import '../../../domain/params/sign_up_params.dart';
import '../../../domain/usecases/delete_account.dart';
import '../../../domain/usecases/sign_in.dart';
import '../../../domain/usecases/sign_up.dart';
import 'auth_form_state.dart';

/// Submits the sign in, sign up and delete account forms. The signed in user reaches the app through the AuthCubit.
class AuthFormCubit extends Cubit<AuthFormState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  AuthFormCubit(this._signInUseCase, this._signUpUseCase, this._deleteAccountUseCase) : super(const AuthFormState());

  Future<void> signIn({required String email, required String password}) {
    return _submit(() => _signInUseCase(SignInParams(email: email, password: password)));
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    final params = SignUpParams(firstName: firstName, lastName: lastName, email: email, password: password);
    return _submit(() => _signUpUseCase(params));
  }

  /// The signed out session reaches the app through the AuthCubit too.
  Future<void> deleteAccount(String password) => _submit(() => _deleteAccountUseCase(password));

  Future<void> _submit(Future<DataState<Object?>> Function() request) async {
    emit(const AuthFormState(status: AuthFormStatus.submitting));
    final result = await request();
    emit(_stateFor(result));
  }

  AuthFormState _stateFor(DataState<Object?> result) {
    return switch (result.error) {
      null => const AuthFormState(status: AuthFormStatus.success),
      AuthValidationException(:final errors) => AuthFormState(status: AuthFormStatus.failure, validationErrors: errors),
      InvalidCredentialsException() => _failure(AuthFormFailure.invalidCredentials),
      EmailAlreadyInUseException() => _failure(AuthFormFailure.emailAlreadyInUse),
      _ => _failure(AuthFormFailure.unexpected),
    };
  }

  AuthFormState _failure(AuthFormFailure failure) => AuthFormState(status: AuthFormStatus.failure, failure: failure);
}
