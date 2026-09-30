import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_state.dart';

const errors = {ArticleDraftError.titleEmpty};

void main() {
  group('visibleErrors', () {
    test('are hidden while the journalist writes, before trying to publish', () {
      expect(const PublishArticleEditing(ArticleDraftEntity()).visibleErrors, isEmpty);
      expect(const PublishArticleDraftLoaded(ArticleDraftEntity(), isRestored: true).visibleErrors, isEmpty);
    });

    test('are shown once publishing was refused', () {
      expect(const PublishArticleInvalid(ArticleDraftEntity(), errors).visibleErrors, errors);
    });
  });

  group('hasStartedWriting', () {
    test('ignores the prefilled signature', () {
      expect(const PublishArticleEditing(ArticleDraftEntity(author: 'Me')).hasStartedWriting, isFalse);
    });

    test('is true with a title, content or thumbnail', () {
      expect(const PublishArticleEditing(ArticleDraftEntity(content: 'A')).hasStartedWriting, isTrue);
    });
  });

  test('states with different reasons or restoration are different', () {
    expect(
      const PublishArticleDraftLoaded(ArticleDraftEntity(), isRestored: true),
      isNot(const PublishArticleDraftLoaded(ArticleDraftEntity(), isRestored: false)),
    );
    expect(
      const PublishArticleFailure(ArticleDraftEntity(), PublishArticleFailureReason.publishFailed),
      isNot(const PublishArticleFailure(ArticleDraftEntity(), PublishArticleFailureReason.galleryUnavailable)),
    );
  });
}
