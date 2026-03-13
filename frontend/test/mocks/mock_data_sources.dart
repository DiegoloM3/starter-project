import 'package:mockito/annotations.dart';

// Auth Feature
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';

// User Articles Feature
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/cloudinary_service.dart';

/// Generate mocks for data layer data sources.
/// Used when testing repository implementations.
///
/// Run: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  AuthRemoteDataSource,
  ArticleRemoteDataSource,
  CloudinaryService,
])
void main() {}
