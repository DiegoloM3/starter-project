import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

const draft = ArticleDraftEntity(
  title: 'Half written',
  content: '## Subtitle',
  author: 'Local Desk',
  thumbnail: ArticleThumbnailEntity(localPath: '/drafts/thumbnail-1.jpg', sizeInBytes: 2048),
);

void main() {
  test('stores every field and reads them back', () {
    final rawData = ArticleDraftModel.rawDataOf(draft);

    expect(ArticleDraftModel.fromRawData(rawData).toEntity(), draft);
  });

  test('reads a draft without a thumbnail', () {
    final rawData = ArticleDraftModel.rawDataOf(const ArticleDraftEntity(title: 'Only a title'));

    expect(ArticleDraftModel.fromRawData(rawData).toEntity(), const ArticleDraftEntity(title: 'Only a title'));
  });

  test('rejects stored data without the text fields', () {
    expect(() => ArticleDraftModel.fromRawData(const {'title': 'T'}), throwsFormatException);
  });
}
