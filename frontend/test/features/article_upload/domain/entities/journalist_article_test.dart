import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';

void main() {
  group('JournalistArticleEntity.estimateReadingTime', () {
    test('empty string returns 1', () {
      expect(JournalistArticleEntity.estimateReadingTime(''), 1);
    });

    test('199-word content returns 1', () {
      final content = List.filled(199, 'word').join(' ');
      expect(JournalistArticleEntity.estimateReadingTime(content), 1);
    });

    test('200-word content returns 1', () {
      final content = List.filled(200, 'word').join(' ');
      expect(JournalistArticleEntity.estimateReadingTime(content), 1);
    });

    test('201-word content returns 2', () {
      final content = List.filled(201, 'word').join(' ');
      expect(JournalistArticleEntity.estimateReadingTime(content), 2);
    });

    test('1000-word content returns 5', () {
      final content = List.filled(1000, 'word').join(' ');
      expect(JournalistArticleEntity.estimateReadingTime(content), 5);
    });
  });
}
