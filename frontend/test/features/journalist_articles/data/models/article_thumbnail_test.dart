import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

void main() {
  test('turns the picked file into a thumbnail entity', () {
    final model = ArticleThumbnailModel.fromRawData(localPath: '/cache/photo.JPEG', sizeInBytes: 2048);

    final entity = model.toEntity();

    expect(entity, const ArticleThumbnailEntity(localPath: '/cache/photo.JPEG', sizeInBytes: 2048));
    expect(entity, isNot(isA<ArticleThumbnailModel>()));
    expect(entity.extension, 'jpg');
  });
}
