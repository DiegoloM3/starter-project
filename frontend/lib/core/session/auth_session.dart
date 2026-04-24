/// Snapshot of the signed-in user used by the presentation layer.
///
/// Kept in `core/` (not `features/`) because several features consume it.
/// F7 registers a stub [DevAuthSession]; F8 swaps it for a Firebase-backed
/// implementation without any feature code changing.
class AuthUser {
  const AuthUser({required this.id, required this.name});

  final String id;
  final String name;
}

abstract class AuthSession {
  AuthUser? get currentUser;
}

/// Stub used while Firebase Auth isn't wired (pre-F8). Keeps the UI
/// testable end-to-end without pulling in the Firebase SDK for every
/// unit test or widget test.
class DevAuthSession implements AuthSession {
  const DevAuthSession({AuthUser? user})
      : _user = user ??
            const AuthUser(id: 'dev-user', name: 'Dev User');

  final AuthUser _user;

  @override
  AuthUser get currentUser => _user;
}
