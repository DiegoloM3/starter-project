import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const UserEntity testUser = UserEntity(
  uid: 'user-1',
  firstName: 'Jane',
  lastName: 'Doe',
  bio: '',
  role: UserRole.reader,
);
