import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

UserArticleEntity _withContent(String content) => UserArticleEntity(
      id: 'a1',
      authorId: 'u1',
      authorName: 'Ana',
      title: 'Title',
      description: 'Description',
      content: content,
      thumbnailURL: '',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('readingMinutes', () {
    test('a short piece still reads as one minute, never zero', () {
      expect(_withContent('Just a few words.').readingMinutes, 1);
      expect(_withContent('').readingMinutes, 1);
    });

    test('rounds up at 200 words a minute', () {
      expect(_withContent(List.filled(200, 'word').join(' ')).readingMinutes, 1);
      expect(_withContent(List.filled(201, 'word').join(' ')).readingMinutes, 2);
    });

    test('formatting markers are not counted as words', () {
      final formatted = [
        for (var i = 0; i < 200; i++) '- **word**',
        '## ',
        '> ',
      ].join('\n');

      expect(_withContent(formatted).readingMinutes, 1);
    });
  });
}
