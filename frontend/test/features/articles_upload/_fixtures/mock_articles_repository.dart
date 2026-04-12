import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class MockArticlesUploadRepository extends Mock
    implements ArticlesUploadRepository {}

/// Register fallback values so mocktail can match `any<T>()` for types
/// it cannot construct by reflection. Call once in `setUpAll`.
void registerArticleFallbacks() {
  registerFallbackValue(
    CreateArticleParams(
      title: 'fallback',
      description: 'fallback',
      content: 'fallback',
      author: 'fallback',
      thumbnailFile: File('/tmp/fallback.jpg'),
      publishedAt: DateTime(2000),
    ),
  );
}
