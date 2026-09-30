import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';

PublishedArticleEntity articleWith({required String title, required String content}) {
  return PublishedArticleEntity(
    id: 'article-1',
    title: title,
    content: content,
    description: '',
    author: 'Daily News Staff',
    thumbnailUrl: 'https://example.com/1.jpg',
    publishedAt: DateTime.utc(2026, 9, 28),
  );
}

void main() {
  group('sentences', () {
    test('reads the title, the byline and then the content', () {
      final narration = ArticleNarrationEntity.of(articleWith(title: 'Breaking News', content: 'The body.'));

      expect(narration.sentences, ['Breaking News', 'Written by Daily News Staff', 'The body.']);
    });

    test('splits paragraphs into sentences, keeping their punctuation', () {
      final narration = ArticleNarrationEntity.of(
        articleWith(title: 'Is it true?', content: 'Yes! It happened today. Really… Indeed.'),
      );

      expect(narration.sentences.skip(2), ['Yes!', 'It happened today.', 'Really…', 'Indeed.']);
    });

    test('reads link texts but not image descriptions', () {
      final narration = ArticleNarrationEntity.of(
        articleWith(title: 'T', content: 'See [the report](https://example.com) ![chart](https://example.com/c.png)'),
      );

      expect(narration.sentences.last, 'See the report');
    });
  });

  group('parts', () {
    test('keeps the structure of the Markdown content without its syntax', () {
      const content = '## A newsroom in your pocket\n\n'
          'Starting today, **any journalist** can publish. It is free.\n\n'
          '1. Tap the button\n'
          '- Write your story\n\n'
          '> "It is easy", said the editor';

      final narration = ArticleNarrationEntity.of(articleWith(title: 'Title', content: content));

      expect(narration.parts, const [
        NarrationPart(NarrationPartKind.title, ['Title']),
        NarrationPart(NarrationPartKind.byline, ['Written by Daily News Staff']),
        NarrationPart(NarrationPartKind.heading, ['A newsroom in your pocket']),
        NarrationPart(NarrationPartKind.paragraph, ['Starting today, any journalist can publish.', 'It is free.']),
        NarrationPart(NarrationPartKind.numberedItem, ['Tap the button']),
        NarrationPart(NarrationPartKind.bulletedItem, ['Write your story']),
        NarrationPart(NarrationPartKind.paragraph, ['"It is easy", said the editor']),
      ]);
    });
  });

  group('languageTag', () {
    test('is Spanish for Spanish articles', () {
      final narration = ArticleNarrationEntity.of(articleWith(
        title: 'Vecinos convierten un solar en un huerto',
        content: 'Lo que antes era un aparcamiento abandonado es ahora un huerto para los niños del barrio.',
      ));

      expect(narration.languageTag, 'es-ES');
    });

    test('reads the byline in the language of the article', () {
      final narration = ArticleNarrationEntity.of(articleWith(
        title: 'Vecinos convierten un solar en un huerto',
        content: 'Lo que antes era un aparcamiento es ahora un huerto para los niños.',
      ));

      expect(narration.sentences[1], 'Escrito por Daily News Staff');
    });

    test('is English for English articles', () {
      final narration = ArticleNarrationEntity.of(articleWith(
        title: 'Neighbours turn an empty lot into a garden',
        content: 'What used to be an abandoned parking lot is now home to the trees of the neighbourhood.',
      ));

      expect(narration.languageTag, 'en-US');
    });

    test('defaults to English when there is nothing to tell them apart', () {
      expect(ArticleNarrationEntity.of(articleWith(title: 'OK', content: '1234')).languageTag, 'en-US');
    });
  });
}
