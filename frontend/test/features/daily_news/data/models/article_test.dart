import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  final rawData = {
    'author': 'Jane Doe',
    'title': 'Steelers trade Joey Porter Jr. to the Cowboys',
    'description': 'The cornerback moves to Dallas.',
    'url': 'https://example.com/steelers',
    'urlToImage': 'https://example.com/steelers.jpg',
    'publishedAt': '2026-10-01T03:55:00Z',
    'content': 'The Steelers traded their cornerback on Tuesday.',
  };

  test('reads an article from the NewsAPI response', () {
    final model = ArticleModel.fromRawData(rawData);

    expect(model.title, 'Steelers trade Joey Porter Jr. to the Cowboys');
    expect(model.url, 'https://example.com/steelers');
    expect(model.urlToImage, 'https://example.com/steelers.jpg');
  });

  test('leaves the image empty when NewsAPI sends none, so the app shows a placeholder', () {
    expect(ArticleModel.fromRawData({...rawData, 'urlToImage': null}).urlToImage, '');
    expect(ArticleModel.fromRawData({...rawData, 'urlToImage': ''}).urlToImage, '');
  });

  test('uses empty texts for the fields NewsAPI leaves out', () {
    final model = ArticleModel.fromRawData({'url': 'https://example.com/steelers'});

    expect(model.author, '');
    expect(model.content, '');
  });

  test('converts to an entity with the same fields', () {
    final entity = ArticleModel.fromRawData(rawData).toEntity();

    expect(entity, isNot(isA<ArticleModel>()));
    expect(entity, ArticleModel.fromEntity(entity).toEntity());
    expect(entity.publishedAt, '2026-10-01T03:55:00Z');
  });

  test('is built from an entity, keeping its local ID', () {
    const entity = ArticleEntity(id: 7, url: 'https://example.com/steelers');

    expect(ArticleModel.fromEntity(entity).id, 7);
  });
}
