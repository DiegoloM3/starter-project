import 'package:mockito/annotations.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Auth Feature Use Cases
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/change_password.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/forgot_password.dart';

// User Articles Feature Use Cases
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_articles_by_category.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/upload_image.dart';

/// Generate mocks for use cases.
/// Used when testing BLoCs and Cubits.
///
/// Run: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  // Auth Use Cases
  SignInUseCase,
  SignUpUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
  GetAuthStateChangesUseCase,
  ChangePasswordUseCase,
  ForgotPasswordUseCase,

  // User Articles Use Cases
  GetUserArticlesUseCase,
  GetPublishedArticlesUseCase,
  GetArticlesByCategoryUseCase,
  CreateArticleUseCase,
  UpdateArticleUseCase,
  DeleteArticleUseCase,
  PublishArticleUseCase,
  UploadImageUseCase,

  // External Dependencies
  FlutterTts,
])
void main() {}
