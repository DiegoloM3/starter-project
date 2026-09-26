class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}

class SignUpParams {
  final String email;
  final String password;
  final String displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}
