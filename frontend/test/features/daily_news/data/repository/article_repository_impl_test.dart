import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

import '../../../../helpers/fake_article_repository.dart';

/// Stand in for the News API.
///
/// It is a fake of `NewsRemoteDataSource` rather than of the Retrofit client:
/// the HTTP vocabulary now stops inside the data source, so what the
/// repository has to cope with is a list of models or a [RemoteException].
class _FakeNewsRemoteDataSource implements NewsRemoteDataSource {
  Object? errorToThrow;
  List<ArticleModel> articles = const [];

  NewsCategory? lastRequestedCategory;

  @override
  Future<List<ArticleModel>> getNewsArticles(NewsCategory category) async {
    final error = errorToThrow;

    if (error != null) {
      throw error;
    }

    lastRequestedCategory = category;

    return articles;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

/// Stand in for the saved-articles table.
///
/// It keeps rows rather than counting calls, because what these tests are
/// about — not saving the same article twice, and deleting the stored copy
/// rather than the one handed in — can only be seen in what ends up in there.
class _FakeArticleDao implements ArticleDao {
  final List<ArticleModel> rows = [];

  /// Set to make the device's database misbehave.
  Object? errorToThrow;

  int _nextId = 1;

  void _throwIfArmed() {
    final error = errorToThrow;

    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> insertArticle(ArticleModel article) async {
    _throwIfArmed();
    // Floor generates the primary key on insert, which is why an article
    // straight from the API has none until it lands here.
    rows.add(ArticleModel(
      id: _nextId++,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      content: article.content,
    ));
  }

  @override
  Future<void> deleteArticle(ArticleModel article) async {
    // Floor deletes by primary key, so a row with no id matches nothing.
    rows.removeWhere((row) => row.id != null && row.id == article.id);
  }

  @override
  Future<List<ArticleModel>> getArticles() async {
    _throwIfArmed();

    return List.of(rows);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not faked',
      );
}

class _FakeAppDatabase implements AppDatabase {
  @override
  final ArticleDao articleDAO;

  _FakeAppDatabase(this.articleDAO);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not faked',
      );
}

void main() {
  late _FakeNewsRemoteDataSource api;
  late _FakeArticleDao dao;
  late ArticleRepositoryImpl repository;

  setUp(() {
    api = _FakeNewsRemoteDataSource();
    dao = _FakeArticleDao();
    repository = ArticleRepositoryImpl(api, _FakeAppDatabase(dao));
  });

  group('getNewsArticles', () {
    test('asks the api for the section it was given', () async {
      await repository.getNewsArticles(category: NewsCategory.technology);

      expect(api.lastRequestedCategory, NewsCategory.technology);
    });

    test('reports the headlines as a success', () async {
      api.articles = [
        ArticleModel.fromRawData(const {'title': 'Harbour Reopens'}),
      ];

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess>());
      expect(result.data, hasLength(1));
      // Entities, never models: nothing above the data layer knows the model
      // exists (rule 2.4.2).
      expect(result.data!.single.runtimeType, ArticleEntity);
    });

    /// A refused request has to come back as a failure rather than as an empty
    /// feed, which would tell the reader there is no news when in fact nobody
    /// asked properly.
    test('a refused request is a failure, not an empty feed', () async {
      api.errorToThrow = const RemoteException('401');

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed>());
      expect(result.error, isA<RemoteException>());
    });

    test('a network error is reported rather than thrown', () async {
      api.errorToThrow = const RemoteException('connectionTimeout');

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed>());
    });
  });

  group('saveArticle', () {
    test('stores an article the reader kept', () async {
      await repository.saveArticle(newsArticle());

      expect(dao.rows, hasLength(1));
      expect(dao.rows.single.title, newsArticle().title);
    });

    /// The guard is here because the id is generated on insert, so nothing
    /// else stops the same article growing a second row.
    test('saving the same article twice leaves one row', () async {
      await repository.saveArticle(newsArticle());
      await repository.saveArticle(newsArticle());

      expect(dao.rows, hasLength(1));
    });

    test('two different articles are both kept', () async {
      await repository.saveArticle(newsArticle());
      await repository.saveArticle(
        newsArticle(
          title: 'City Council Approves Transit Plan',
          url: 'https://example.com/transit',
        ),
      );

      expect(dao.rows, hasLength(2));
    });
  });

  group('removeArticle', () {
    /// The article the reader taps came from the API and has no id, while
    /// Floor deletes by primary key. Passing it straight through used to
    /// delete nothing at all, which is what this guards.
    test('deletes the stored copy, not the idless one it was handed', () async {
      await repository.saveArticle(newsArticle());
      expect(dao.rows.single.id, isNotNull);

      await repository.removeArticle(newsArticle());

      expect(dao.rows, isEmpty);
    });

    test('leaves an article that was never saved alone', () async {
      await repository.saveArticle(newsArticle());

      await repository.removeArticle(
        newsArticle(url: 'https://example.com/something-else'),
      );

      expect(dao.rows, hasLength(1));
    });
  });

  test('getSavedArticles hands back what is stored', () async {
    await repository.saveArticle(newsArticle());

    final result = await repository.getSavedArticles();

    expect(result, isA<DataSuccess>());
    expect(result.data, hasLength(1));
    expect(result.data!.single.title, newsArticle().title);
  });

  /// The local database can fail just as the network can, and a caller handed
  /// a bare Future has nowhere to put that — it would wait forever.
  test('a database that throws is reported, not left hanging', () async {
    dao.errorToThrow = StateError('the database file is gone');

    final result = await repository.getSavedArticles();

    expect(result, isA<DataFailed>());
    expect(result.error, isA<StateError>());
  });
}
