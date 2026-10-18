import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/exceptions/auth_exceptions.dart';
import '../../../domain/params/auth_validation.dart';
import '../../../domain/params/sign_in_params.dart';
import '../../../domain/params/sign_up_params.dart';
import '../../../domain/usecases/sign_in.dart';
import '../../../domain/usecases/sign_up.dart';
import 'auth_form_state.dart';

/// Submits the sign in and sign up forms. The signed in user reaches the app through the AuthCubit.
class AuthFormCubit extends Cubit<AuthFormState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;

  AuthFormCubit(this._signInUseCase, this._signUpUseCase) : super(const AuthFormState());

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

  Future<void> _submit(Future<DataState<UserEntity>> Function() request) async {
    emit(const AuthFormState(status: AuthFormStatus.submitting));
    final result = await request();
    emit(_stateFor(result));
  }

  AuthFormState _stateFor(DataState<UserEntity> result) {
    final error = result.error;
    if (error == null) return const AuthFormState(status: AuthFormStatus.success);
    final validationErrors = error is AuthValidationException ? error.errors : <AuthValidationError>{};
    return AuthFormState(status: AuthFormStatus.failure, validationErrors: validationErrors);
  }
}
