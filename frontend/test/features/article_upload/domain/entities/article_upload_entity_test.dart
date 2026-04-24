import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';

void main() {
  group('ArticleUploadEntity.calculateReadTime', () {
    test('returns 1 for empty string', () {
      expect(ArticleUploadEntity.calculateReadTime(''), 1);
    });

    test('returns 1 for a single word', () {
      expect(ArticleUploadEntity.calculateReadTime('Hello'), 1);
    });

    test('returns 1 for exactly 200 words', () {
      final text = List.generate(200, (i) => 'word').join(' ');
      expect(ArticleUploadEntity.calculateReadTime(text), 1);
    });

    test('returns 2 for 201 words', () {
      final text = List.generate(201, (i) => 'word').join(' ');
      expect(ArticleUploadEntity.calculateReadTime(text), 2);
    });

    test('returns 5 for 1000 words', () {
      final text = List.generate(1000, (i) => 'word').join(' ');
      expect(ArticleUploadEntity.calculateReadTime(text), 5);
    });

    test('clamps result to max 99', () {
      final text = List.generate(20000, (i) => 'word').join(' ');
      expect(ArticleUploadEntity.calculateReadTime(text), 99);
    });
  });
}
