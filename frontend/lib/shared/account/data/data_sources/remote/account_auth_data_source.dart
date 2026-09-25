import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/shared/account/data/models/account_model.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';

class AccountAuthDataSource {
  static const _existingAccountCodes = {
    'credential-already-in-use',
    'email-already-in-use',
    'account-exists-with-different-credential',
  };

  final FirebaseAuth _auth;

  // Kept from a link attempt that hit an existing account, so switching to
  // it doesn't make the user repeat the Google/email step.
  Future<UserCredential> Function()? _pendingSwitch;

  AccountAuthDataSource(this._auth);

  AccountModel readCurrentAccount() {
    final user = _requireCurrentUser();
    return AccountModel.fromRawData({
      'uid': user.uid,
      'isAnonymous': user.isAnonymous,
      'email': user.email,
      // A guest that links Google keeps its own (empty) profile fields, so
      // fall back to what the linked provider knows about the person.
      'displayName': user.displayName ??
          _firstFromProviders(user, (info) => info.displayName),
      'photoURL':
          user.photoURL ?? _firstFromProviders(user, (info) => info.photoURL),
      'providerIds': [for (final info in user.providerData) info.providerId],
    });
  }

  String? _firstFromProviders(User user, String? Function(UserInfo) field) {
    return user.providerData.map(field).nonNulls.firstOrNull;
  }

  Future<void> linkWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _linkWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    if (displayName != null && displayName.isNotEmpty) {
      await _setDisplayName(displayName);
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _setDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw AccountException(_reasonFor(e.code));
    }
  }

  Future<void> _setDisplayName(String name) async {
    final user = _requireCurrentUser();
    await user.updateDisplayName(name);
    await user.reload();
  }

  Future<void> linkWithGoogleIdToken(String idToken) {
    return _linkWithCredential(GoogleAuthProvider.credential(idToken: idToken));
  }

  Future<void> switchToPendingAccount() async {
    final pendingSwitch = _pendingSwitch;
    if (pendingSwitch == null) {
      throw const AccountException(AccountErrorReason.unknown);
    }
    try {
      await pendingSwitch();
      _pendingSwitch = null;
    } on FirebaseAuthException catch (e) {
      // Still colliding here means the email belongs to an account that
      // uses a different sign-in method -- asking to switch again would loop.
      throw AccountException(_existingAccountCodes.contains(e.code)
          ? AccountErrorReason.otherSignInMethod
          : _reasonFor(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> reauthenticateWithEmail(String password) {
    final email = _requireCurrentUser().email;
    if (email == null) {
      throw const AccountException(AccountErrorReason.unknown);
    }
    return _reauthenticate(
      EmailAuthProvider.credential(email: email, password: password),
    );
  }

  Future<void> reauthenticateWithGoogleIdToken(String idToken) {
    return _reauthenticate(GoogleAuthProvider.credential(idToken: idToken));
  }

  Future<void> deleteCurrentUser() async {
    final user = _requireCurrentUser();
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // A guest can't sign in again to satisfy this. Its content is already
      // gone by now, so signing out leaves only an empty anonymous id behind.
      if (user.isAnonymous && e.code == 'requires-recent-login') {
        await _auth.signOut();
        return;
      }
      throw AccountException(_reasonFor(e.code));
    }
  }

  Future<void> _reauthenticate(AuthCredential credential) async {
    try {
      await _requireCurrentUser().reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AccountException(_reasonFor(e.code));
    }
  }

  Future<void> _linkWithCredential(AuthCredential credential) async {
    try {
      await _requireCurrentUser().linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _rememberPendingSwitch(e, () => _auth.signInWithCredential(credential));
      throw AccountException(_reasonFor(e.code));
    }
  }

  void _rememberPendingSwitch(
    FirebaseAuthException e,
    Future<UserCredential> Function() fallback,
  ) {
    if (!_existingAccountCodes.contains(e.code)) {
      _pendingSwitch = null;
      return;
    }
    final credential = e.credential;
    _pendingSwitch = credential == null
        ? fallback
        : () => _auth.signInWithCredential(credential);
  }

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AccountException(AccountErrorReason.unknown);
    }
    return user;
  }

  AccountErrorReason _reasonFor(String code) {
    if (_existingAccountCodes.contains(code)) {
      return AccountErrorReason.existingAccount;
    }
    return switch (code) {
      'wrong-password' ||
      'invalid-credential' ||
      'user-not-found' =>
        AccountErrorReason.wrongCredentials,
      'user-mismatch' => AccountErrorReason.differentAccount,
      'weak-password' => AccountErrorReason.weakPassword,
      'invalid-email' => AccountErrorReason.invalidEmail,
      'operation-not-allowed' => AccountErrorReason.methodNotAvailable,
      'network-request-failed' => AccountErrorReason.network,
      'too-many-requests' => AccountErrorReason.tooManyAttempts,
      _ => AccountErrorReason.unknown,
    };
  }
}
