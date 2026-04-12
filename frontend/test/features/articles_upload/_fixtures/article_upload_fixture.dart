import 'dart:io';

import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';

/// Shared test fixtures for the articles_upload feature.
///
/// Keeping these in one place prevents test bodies from duplicating
/// long constructor calls and makes it cheap to tweak field values
/// (for example when we start testing size-limit rejection cases).
class ArticleUploadFixture {
  static ArticleUploadEntity sample({
    String? id = 'fixture-1',
    String title = 'Fixture title',
    String description = 'Fixture description',
    String content = 'Fixture content body',
    String author = 'Fixture Author',
    String authorUid = 'fixture-uid',
    String thumbnailURL = 'https://example.com/thumb.jpg',
    DateTime? publishedAt,
  }) {
    final now = publishedAt ?? DateTime.utc(2026, 4, 9, 12);
    return ArticleUploadEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      author: author,
      authorUid: authorUid,
      thumbnailURL: thumbnailURL,
      publishedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  static CreateArticleParams sampleParams({
    String title = 'New article',
    String description = 'New description',
    String content = 'New content',
    String author = 'Reporter',
  }) {
    return CreateArticleParams(
      title: title,
      description: description,
      content: content,
      author: author,
      // We never touch the file in tests — the repository is mocked
      // and the mock ignores its content. A fake path is enough for
      // equality / propagation checks.
      thumbnailFile: File('/tmp/nonexistent-fixture.jpg'),
      publishedAt: DateTime.utc(2026, 4, 9, 12),
    );
  }
}
