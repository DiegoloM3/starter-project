// Mock data used by the use cases until the data layer connects them to Firebase.

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
