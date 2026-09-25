enum AccountErrorReason {
  cancelled,
  existingAccount,
  otherSignInMethod,
  wrongCredentials,
  differentAccount,
  weakPassword,
  invalidEmail,
  methodNotAvailable,
  network,
  tooManyAttempts,
  unknown,
}

class AccountException implements Exception {
  final AccountErrorReason reason;

  const AccountException(this.reason);

  @override
  String toString() => 'AccountException($reason)';
}
