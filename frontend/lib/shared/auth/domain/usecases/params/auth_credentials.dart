class AuthCredentials {
  final String email;
  final String password;
  final String? displayName;

  const AuthCredentials({
    required this.email,
    required this.password,
    this.displayName,
  });
}
