import 'package:mockito/annotations.dart';

// Auth Feature
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

// User Articles Feature
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Generate mocks for domain layer repositories.
/// Used when testing use cases.
///
/// Run: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  AuthRepository,
  UserArticleRepository,
])
void main() {}
