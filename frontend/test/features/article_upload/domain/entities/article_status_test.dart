import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';

void main() {
  group('ArticleStatus', () {
    test('toApiValue returns lowercase string for each value', () {
      expect(ArticleStatus.draft.toApiValue(), 'draft');
      expect(ArticleStatus.publishing.toApiValue(), 'publishing');
      expect(ArticleStatus.published.toApiValue(), 'published');
    });

    test('fromApiValue round-trips all values', () {
      for (final status in ArticleStatus.values) {
        expect(
          ArticleStatus.fromApiValue(status.toApiValue()),
          status,
        );
      }
    });

    test('fromApiValue throws ArgumentError for unknown value', () {
      expect(
        () => ArticleStatus.fromApiValue('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
