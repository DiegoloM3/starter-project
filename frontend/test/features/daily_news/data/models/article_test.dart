import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// The News API is generous with nulls: a headline routinely arrives with no
/// author, no description and no image. The entity above this layer promises
/// strings, so this model is where those nulls stop.
void main() {
  group('fromJson', () {
    test('reads a complete article', () {
      final model = ArticleModel.fromJson(const {
        'author': 'Geneva Post',
        'title': 'Harbour Reopens After Nine Months',
        'description': 'The last crane was lifted on Tuesday.',
        'url': 'https://example.com/harbour',
        'urlToImage': 'https://example.com/harbour.jpg',
        'publishedAt': '2026-09-22T09:00:00Z',
        'content': 'The port authority published a 180 page plan.',
      });

      expect(model.author, 'Geneva Post');
      expect(model.title, 'Harbour Reopens After Nine Months');
      expect(model.urlToImage, 'https://example.com/harbour.jpg');
    });

    test('turns every missing field into an empty string', () {
      final model = ArticleModel.fromJson(const {});

      expect(model.author, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.url, '');
      expect(model.publishedAt, '');
      expect(model.content, '');
    });

    /// A card with no picture at all would leave a hole in the feed, so an
    /// article without one is given the placeholder rather than nothing.
    test('falls back to the placeholder when there is no image', () {
      expect(ArticleModel.fromJson(const {}).urlToImage, kDefaultImage);
      expect(
        ArticleModel.fromJson(const {'urlToImage': null}).urlToImage,
        kDefaultImage,
      );
      expect(
        ArticleModel.fromJson(const {'urlToImage': ''}).urlToImage,
        kDefaultImage,
      );
    });
  });

  group('fromEntity', () {
    test('carries the local id, which is what saving and deleting need', () {
      const entity = ArticleEntity(
        id: 7,
        author: 'Geneva Post',
        title: 'Harbour Reopens After Nine Months',
        description: 'The last crane was lifted on Tuesday.',
        url: 'https://example.com/harbour',
        urlToImage: 'https://example.com/harbour.jpg',
        publishedAt: '2026-09-22T09:00:00Z',
        content: 'The port authority published a 180 page plan.',
      );

      final model = ArticleModel.fromEntity(entity);

      expect(model.id, 7);
      expect(model.url, entity.url);
    });
  });

  test('is an entity, so nothing above the data layer has to know it exists',
      () {
    expect(ArticleModel.fromJson(const {}), isA<ArticleEntity>());
  });

  /// The News API's free tier sends roughly the first 200 characters of an
  /// article and signs off with `… [+2431 chars]`. That is a note to whoever
  /// is integrating the API, and it was being printed at the end of every
  /// story as though a journalist had typed it.
  group('the truncation marker the News API appends', () {
    String bodyOf(String content) =>
        ArticleModel.fromRawData(<String, dynamic>{'content': content})
            .content!;

    test('is taken off the end of the body', () {
      expect(
        bodyOf('The depot doors open at 23:40… [+2431 chars]'),
        'The depot doors open at 23:40…',
      );
    });

    test('is taken off however the API spaced it', () {
      expect(bodyOf('A story [+12 chars]'), 'A story');
      expect(bodyOf('A story [+12chars]'), 'A story');
      expect(bodyOf('A story [+1234 chars] '), 'A story');
    });

    /// The ellipsis stays. It says the text stops mid-sentence, which is
    /// true, and it cannot be told apart from one the journalist wrote.
    test('keeps the ellipsis in front of it', () {
      expect(bodyOf('A story... [+12 chars]'), 'A story...');
      expect(bodyOf('A story… [+12 chars]'), 'A story…');
    });

    test('leaves a body that never had one alone', () {
      expect(bodyOf('A complete little story.'), 'A complete little story.');
    });

    /// Only the API's own sign-off goes. Square brackets are ordinary
    /// punctuation in a news story — an editorial insertion, most often — and
    /// stripping them would be rewriting the article.
    test('leaves the journalist own brackets alone', () {
      expect(
        bodyOf('He said [the minister] had resigned.'),
        'He said [the minister] had resigned.',
      );
      expect(
          bodyOf('A note [+2 pages] follows.'), 'A note [+2 pages] follows.');
    });

    test('a marker in the middle is not the sign-off', () {
      expect(
        bodyOf('First [+10 chars] and then more text.'),
        'First [+10 chars] and then more text.',
      );
    });

    test('a missing body is still an empty one', () {
      expect(bodyOf(''), '');
      expect(
        ArticleModel.fromRawData(const <String, dynamic>{}).content,
        '',
      );
    });

    test('a body that is nothing but the marker comes back empty', () {
      expect(bodyOf('[+2431 chars]'), '');
    });
  });
}
