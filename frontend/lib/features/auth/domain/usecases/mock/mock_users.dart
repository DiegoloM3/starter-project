// Mock data used by the use cases until the data layer connects them to Firebase.

import 'dart:async';

import '../../entities/user.dart';

/// Signing in with this email returns a journalist, any other email returns a reader.
const String mockJournalistEmail = 'journalist@symmetry.com';

const Duration mockNetworkDelay = Duration(milliseconds: 300);

const UserEntity mockJournalist = UserEntity(
  uid: 'mock-journalist',
  firstName: 'Jane',
  lastName: 'Doe',
  bio: 'Technology and video games journalist.',
  role: UserRole.journalist,
);

const UserEntity mockReader = UserEntity(
  uid: 'mock-reader',
  firstName: 'Rita',
  lastName: 'Reader',
  bio: '',
  role: UserRole.reader,
);

final MockSession mockSession = MockSession();

/// Mimics the session of Firebase Authentication: the sign in, sign up and
/// sign out mocks change it, and every listener receives the current user first.
class MockSession {
  final StreamController<UserEntity?> _changes = StreamController.broadcast();
  UserEntity? _currentUser;

  Stream<UserEntity?> watch() async* {
    yield _currentUser;
    yield* _changes.stream;
  }

  void change(UserEntity? user) {
    _currentUser = user;
    _changes.add(user);
  }
}
