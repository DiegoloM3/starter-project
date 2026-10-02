import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  /// The signed-in user every time it changes (`null` when nobody is signed in).
  /// It starts with the session kept on the phone, so users do not sign in every time they open the app.
  Stream<UserEntity?> watchSession();

  Future<DataState<UserEntity>> signIn(String email, String password);

  Future<DataState<UserEntity>> register(RegistrationDraftEntity draft);

  Future<DataState<void>> signOut();
}
