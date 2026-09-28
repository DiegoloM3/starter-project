import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/news/data/models/news_api_response.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/news_api_response.entity.dart';

void main() {
  group('NewsApiResponse (1.3.1-1.3.3)', () {
    test('extends NewsApiResponseEntity', () {
      const response = NewsApiResponse(status: 'ok', totalResults: 1);

      expect(response, isA<NewsApiResponseEntity>());
    });

    test('fromRawData parses external API shape', () {
      final raw = {
        'status': 'ok',
        'totalResults': 1,
        'articles': [
          {
            'author': 'Jane',
            'title': 'T',
            'urlToImage': 'https://example.com/i.jpg',
            'publishedAt': '2024-01-01T00:00:00Z',
            'content': 'C',
          },
        ],
      };

      final result = NewsApiResponse.fromRawData(raw);

      expect(result.status, 'ok');
      expect(result.articles!.length, 1);
      expect(result.articles!.first.authorDisplayName, 'Jane');
    });

    test('toEntity maps nested models to entities', () {
      final response = NewsApiResponse.fromRawData({
        'status': 'ok',
        'totalResults': 1,
        'articles': [
          {
            'author': 'Jane',
            'title': 'T',
            'publishedAt': '2024-01-01T00:00:00Z',
            'content': 'C',
          },
        ],
      });

      final entity = response.toEntity();

      expect(entity, isA<NewsApiResponseEntity>());
      expect(entity.articles!.first, isA<ArticleEntity>());
      expect(entity.articles!.first.runtimeType, ArticleEntity);
    });
  });
}
