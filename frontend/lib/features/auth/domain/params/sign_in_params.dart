import 'package:equatable/equatable.dart';

/// Parameters for the sign-in-with-email use case.
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
