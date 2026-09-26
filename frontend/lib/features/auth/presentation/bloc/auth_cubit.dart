import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user_identity.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

sealed class AuthState {
  const AuthState();

  UserIdentity? get user => null;
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthLoading extends AuthState {
  @override
  final UserIdentity? user;

  const AuthLoading([this.user]);
}

class AuthSignedIn extends AuthState {
  @override
  final UserIdentity user;
  const AuthSignedIn(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  @override
  final UserIdentity? user;

  const AuthFailure(this.message, {this.user});
}

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;

  AuthCubit(
      AuthRepository repository, this._signIn, this._signUp, this._signOut)
      : super(_initialState(repository));

  static AuthState _initialState(AuthRepository repository) {
    final user = repository.currentUser;
    return user == null ? const AuthSignedOut() : AuthSignedIn(user);
  }

  Future<void> signIn(String email, String password) async {
    final previousUser = state.user;
    emit(AuthLoading(previousUser));
    final result =
        await _signIn(SignInParams(email: email, password: password));
    _emitResult(result, previousUser: previousUser);
  }

  Future<void> signUp(String email, String password, String displayName) async {
    final previousUser = state.user;
    emit(AuthLoading(previousUser));
    final result = await _signUp(SignUpParams(
      email: email,
      password: password,
      displayName: displayName,
    ));
    _emitResult(result, previousUser: previousUser);
  }

  Future<void> signOut() async {
    final previousUser = state.user;
    emit(AuthLoading(previousUser));
    final result = await _signOut();
    if (result is DataSuccess<void>) {
      emit(const AuthSignedOut());
    } else {
      emit(AuthFailure(
        result.error?.message ?? 'Unable to sign out.',
        user: previousUser,
      ));
    }
  }

  void _emitResult(
    DataState<UserIdentity> result, {
    UserIdentity? previousUser,
  }) {
    if (result is DataSuccess<UserIdentity> && result.data != null) {
      emit(AuthSignedIn(result.data!));
    } else {
      emit(AuthFailure(
        result.error?.message ?? 'Authentication failed.',
        user: previousUser,
      ));
    }
  }
}
