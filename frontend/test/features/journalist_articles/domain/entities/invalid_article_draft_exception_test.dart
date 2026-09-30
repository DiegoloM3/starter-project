import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/invalid_article_draft_exception.dart';

void main() {
  test('carries every error of the rejected draft', () {
    const exception = InvalidArticleDraftException({ArticleDraftError.titleEmpty, ArticleDraftError.thumbnailMissing});

    expect(exception.errors, {ArticleDraftError.titleEmpty, ArticleDraftError.thumbnailMissing});
    expect(exception, isA<Exception>());
    expect(exception.toString(), contains('titleEmpty'));
  });
}
