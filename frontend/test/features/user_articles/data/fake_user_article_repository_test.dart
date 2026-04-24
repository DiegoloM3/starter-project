import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/fake/fake_user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';

const _longContent =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

PublishArticleParams _publish({String title = 'Hello world'}) {
  return PublishArticleParams(
    authorId: 'u1',
    authorName: 'Author',
    title: title,
    description: 'desc',
    content: _longContent,
    thumbnailURL: 'https://cdn.test/thumb.jpg',
  );
}

void main() {
  late FakeUserArticleRepository repository;

  setUp(() {
    repository = FakeUserArticleRepository(
      now: () => DateTime(2026, 4, 24),
    );
  });

  test('publishArticle + getMyArticles round-trip', () async {
    final published = await repository.publishArticle(_publish());
    final list = await repository.getMyArticles('u1');

    expect(published.isRight(), isTrue);
    expect(list.isRight(), isTrue);
    list.fold((_) => fail('expected right'), (entities) {
      expect(entities, hasLength(1));
      expect(entities.single.title, 'Hello world');
    });
  });

  test('updateArticle rewrites the stored copy', () async {
    final published = await repository.publishArticle(_publish());
    final id = published.fold((_) => '', (e) => e.id);

    await repository.updateArticle(
      UpdateArticleParams(
        id: id,
        title: 'Renamed',
        description: 'new desc',
        content: _longContent,
        thumbnailURL: 'https://cdn.test/new.jpg',
      ),
    );

    final list = await repository.getMyArticles('u1');
    list.fold((_) => fail('expected right'), (entities) {
      expect(entities.single.title, 'Renamed');
      expect(entities.single.thumbnailURL, 'https://cdn.test/new.jpg');
    });
  });

  test('updateArticle fails when id is unknown', () async {
    final result = await repository.updateArticle(
      const UpdateArticleParams(
        id: 'missing',
        title: 'Hello',
        description: '',
        content: _longContent,
        thumbnailURL: 'https://cdn.test/x.jpg',
      ),
    );
    expect(result.isLeft(), isTrue);
  });

  test('deleteArticle removes the stored copy', () async {
    final published = await repository.publishArticle(_publish());
    final id = published.fold((_) => '', (e) => e.id);

    final result = await repository.deleteArticle(DeleteArticleParams(id: id));
    expect(result.isRight(), isTrue);

    final list = await repository.getMyArticles('u1');
    list.fold((_) => fail('expected right'), (entities) {
      expect(entities, isEmpty);
    });
  });

  test('uploadThumbnail returns a URL under the expected path', () async {
    final result = await repository.uploadThumbnail(
      const UploadThumbnailParams(
        authorId: 'u1',
        articleId: 'a1',
        fileName: 'thumb.jpg',
        bytes: [1, 2, 3],
        contentType: 'image/jpeg',
      ),
    );

    result.fold((_) => fail('expected right'), (url) {
      expect(url, contains('/media/articles/u1/a1/thumb.jpg'));
    });
  });
}
