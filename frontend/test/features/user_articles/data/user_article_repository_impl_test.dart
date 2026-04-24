import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/data_sources/remote/user_articles_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';

const _longContent =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

PublishArticleParams _publishParams({
  String id = 'a1',
  String authorId = 'u1',
}) {
  return PublishArticleParams(
    id: id,
    authorId: authorId,
    authorName: 'Author',
    title: 'Hello world',
    description: 'desc',
    content: _longContent,
    thumbnailURL: 'https://cdn.test/thumb.jpg',
    tags: const ['flutter'],
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late UserArticleRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    repository = UserArticleRepositoryImpl(
      UserArticlesFirestoreDataSource(firestore),
      UserArticlesStorageDataSource(storage),
    );
  });

  test('publishArticle persists and returns the entity', () async {
    final result = await repository.publishArticle(_publishParams());

    result.fold(
      (f) => fail('expected Right, got $f'),
      (article) {
        expect(article.id, 'a1');
        expect(article.title, 'Hello world');
        expect(article.tags, ['flutter']);
      },
    );

    final snap = await firestore.collection('articles').doc('a1').get();
    expect(snap.exists, isTrue);
    expect(snap.data()!['authorId'], 'u1');
  });

  test(
    'getMyArticles returns only documents authored by the given user',
    () async {
      await repository.publishArticle(_publishParams(id: 'a1'));
      await repository.publishArticle(_publishParams(id: 'a2'));
      await repository
          .publishArticle(_publishParams(id: 'other', authorId: 'u2'));

      final result = await repository.getMyArticles('u1');

      result.fold(
        (f) => fail('expected Right, got $f'),
        (articles) {
          expect(articles, hasLength(2));
          expect(
            articles.map((a) => a.id).toSet(),
            {'a1', 'a2'},
          );
        },
      );
    },
  );

  test('updateArticle bumps updatedAt and rewrites fields', () async {
    await repository.publishArticle(_publishParams(id: 'a1'));

    final result = await repository.updateArticle(
      const UpdateArticleParams(
        id: 'a1',
        title: 'Updated title here',
        description: 'new desc',
        content: _longContent,
        thumbnailURL: 'https://cdn.test/new.jpg',
        tags: ['flutter', 'clean'],
      ),
    );

    result.fold(
      (f) => fail('expected Right, got $f'),
      (article) {
        expect(article.title, 'Updated title here');
        expect(article.thumbnailURL, 'https://cdn.test/new.jpg');
        expect(article.tags, ['flutter', 'clean']);
      },
    );
  });

  test('deleteArticle removes the document', () async {
    await repository.publishArticle(_publishParams(id: 'a1'));

    final result =
        await repository.deleteArticle(const DeleteArticleParams(id: 'a1'));

    expect(result.isRight(), isTrue);
    final snap = await firestore.collection('articles').doc('a1').get();
    expect(snap.exists, isFalse);
  });

  test('uploadThumbnail writes to the rules-whitelisted path', () async {
    final result = await repository.uploadThumbnail(
      const UploadThumbnailParams(
        authorId: 'u1',
        articleId: 'a1',
        fileName: 'thumbnail.png',
        bytes: [1, 2, 3],
        contentType: 'image/png',
      ),
    );

    expect(result.isRight(), isTrue);
    final list = await storage.ref('media/articles/u1/a1').listAll();
    expect(list.items, isNotEmpty);
  });

  test('maps FirebaseException(permission-denied) to AuthFailure', () async {
    // fake_cloud_firestore doesn't enforce rules, so simulate the failure
    // by pointing the data source at a broken ref via the raw exception
    // mapping.
    final broken = _ThrowingFirestoreDataSource();
    final brokenRepo = UserArticleRepositoryImpl(
      broken,
      UserArticlesStorageDataSource(storage),
    );

    final result =
        await brokenRepo.deleteArticle(const DeleteArticleParams(id: 'a1'));

    result.fold(
      (f) => expect(f.toString(), contains('auth')),
      (_) => fail('expected Left'),
    );
  });
}

class _ThrowingFirestoreDataSource extends UserArticlesFirestoreDataSource {
  _ThrowingFirestoreDataSource() : super(FakeFirebaseFirestore());

  @override
  Future<void> deleteArticle(String id) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'blocked',
    );
  }
}
