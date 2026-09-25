sealed class SignInMethod {
  const SignInMethod();
}

final class EmailSignInMethod extends SignInMethod {
  final String email;
  final String password;

  /// Only set when creating a brand-new account -- email/password sign-in
  /// has no profile of its own for Firebase to read a name from (unlike
  /// Google), so this is the only chance to ask for one.
  final String? displayName;

  const EmailSignInMethod({
    required this.email,
    required this.password,
    this.displayName,
  });
}

final class GoogleSignInMethod extends SignInMethod {
  const GoogleSignInMethod();
}
