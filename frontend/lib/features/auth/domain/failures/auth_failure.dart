/// A domain-level failure type for authentication errors.
/// Stored in [DataFailed.error.error] throughout the auth feature.
class AuthFailure {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}
