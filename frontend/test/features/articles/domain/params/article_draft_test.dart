import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';

ArticleDraft buildDraft({
  String title = 'Title',
  String description = 'Description',
  ArticleContent? content,
  Set<ArticleTopic> topics = const {ArticleTopic.gaming},
}) {
  return ArticleDraft(
    title: title,
    description: description,
    content: content ?? ArticleContent.fromPlainText('Content'),
    topics: topics,
  );
}

void main() {
  group('ArticleDraft.validationErrors', () {
    test('is empty for a valid draft', () {
      expect(buildDraft().validationErrors, isEmpty);
    });

    test('reports an empty title, ignoring spaces', () {
      expect(buildDraft(title: '   ').validationErrors, {ArticleValidationError.titleEmpty});
    });

    test('accepts a title of exactly the maximum length', () {
      final title = 'a' * ArticleLimits.titleMaxLength;

      expect(buildDraft(title: title).validationErrors, isEmpty);
    });

    test('reports a title longer than the maximum length', () {
      final title = 'a' * (ArticleLimits.titleMaxLength + 1);

      expect(buildDraft(title: title).validationErrors, {ArticleValidationError.titleTooLong});
    });

    test('reports an empty description', () {
      expect(buildDraft(description: '').validationErrors, {ArticleValidationError.descriptionEmpty});
    });

    test('reports a description longer than the maximum length', () {
      final description = 'a' * (ArticleLimits.descriptionMaxLength + 1);

      expect(buildDraft(description: description).validationErrors, {ArticleValidationError.descriptionTooLong});
    });

    test('reports empty content', () {
      final draft = buildDraft(content: const ArticleContent('[{"insert":"\\n"}]'));

      expect(draft.validationErrors, {ArticleValidationError.contentEmpty});
    });

    test('reports content longer than the maximum length', () {
      final content = ArticleContent.fromPlainText('a' * ArticleLimits.contentMaxLength);

      expect(buildDraft(content: content).validationErrors, {ArticleValidationError.contentTooLong});
    });

    test('reports a draft without topics', () {
      expect(buildDraft(topics: {}).validationErrors, {ArticleValidationError.noTopics});
    });

    test('accepts the maximum number of topics', () {
      final topics = {ArticleTopic.gaming, ArticleTopic.technology, ArticleTopic.culture};

      expect(buildDraft(topics: topics).validationErrors, isEmpty);
    });

    test('reports too many topics', () {
      final topics = {ArticleTopic.gaming, ArticleTopic.technology, ArticleTopic.culture, ArticleTopic.world};

      expect(buildDraft(topics: topics).validationErrors, {ArticleValidationError.tooManyTopics});
    });

    test('reports every error at once', () {
      final draft = buildDraft(title: '', description: '', topics: {});

      expect(draft.validationErrors, {
        ArticleValidationError.titleEmpty,
        ArticleValidationError.descriptionEmpty,
        ArticleValidationError.noTopics,
      });
    });
  });
}
