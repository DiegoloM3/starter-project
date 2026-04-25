/// Snapshot of the signed-in user used by the presentation layer.
///
/// Kept in `core/` (not `features/`) because several features consume it.
class AuthUser {
  const AuthUser({required this.id, required this.name});

  final String id;
  final String name;
}

/// Read-only port consumed by features that need the current user.
///
/// `changes` is a broadcast stream so that go_router's `refreshListenable`
/// can re-evaluate `redirect` when the user signs in/out.
abstract class AuthSession {
  AuthUser? get currentUser;
  Stream<AuthUser?> get changes;
}

/// Stub used in tests and as a fallback when Firebase isn't initialized.
///
/// Always reports the same user and never emits a change. Real auth flows
/// (login / register / logout) live in `FirebaseAuthSession`.
class DevAuthSession implements AuthSession {
  DevAuthSession({AuthUser? user})
      : _user = user ?? const AuthUser(id: 'dev-user', name: 'Dev User');

  final AuthUser _user;

  @override
  AuthUser get currentUser => _user;

  @override
  Stream<AuthUser?> get changes => Stream<AuthUser?>.value(_user);
}
