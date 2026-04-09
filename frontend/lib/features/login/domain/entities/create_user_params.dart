import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';

class CreateUserParams {
  final UserEntity user;
  final String password;

  const CreateUserParams({
    required this.user,
    required this.password,
  });
}
