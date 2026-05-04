import 'package:equatable/equatable.dart';

/// Parameters for the sign-up-with-email use case.
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}
