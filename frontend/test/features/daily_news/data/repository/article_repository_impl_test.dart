import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

class MockSavedArticlesService extends Mock implements SavedArticlesService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class FakeArticleEntity extends Fake implements ArticleEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeArticleEntity());
  });

  late MockNewsApiService mockApiService;
  late MockSavedArticlesService mockSavedService;
  late MockFirebaseAuth mockAuth;
  late ArticleRepositoryImpl repository;

  setUp(() {
    mockApiService = MockNewsApiService();
    mockSavedService = MockSavedArticlesService();
    mockAuth = MockFirebaseAuth();
    repository = ArticleRepositoryImpl(mockApiService, mockSavedService, mockAuth);

    // Default: an anonymous user is signed in. Individual tests can
    // override this to test the unauthenticated branch.
    final user = MockUser();
    when(() => user.uid).thenReturn('anon-uid');
    when(() => mockAuth.currentUser).thenReturn(user);
  });

  const testModels = [
    ArticleModel(
      author: 'Author',
      title: 'Title',
      description: 'Desc',
      url: 'https://example.com',
      urlToImage: 'https://example.com/img.jpg',
      publishedAt: '2024-01-01',
      content: 'Content',
    ),
  ];

  group('ArticleRepositoryImpl.getNewsArticles', () {
    test('returns DataSuccess with entities on 200', () async {
      final response = Response<List<ArticleModel>>(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 200,
        data: testModels,
      );
      final httpResponse = HttpResponse<List<ArticleModel>>(testModels, response);

      when(() => mockApiService.searchEverything(
            apiKey: any(named: 'apiKey'),
            q: any(named: 'q'),
            language: any(named: 'language'),
            sortBy: any(named: 'sortBy'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, isA<List<ArticleEntity>>());
      expect(result.data, hasLength(testModels.length));
      expect(result.data!.first.title, equals(testModels.first.title));
    });

    test('returns DataFailed with NetworkException when DioError is thrown', () async {
      final dioError = DioError(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioErrorType.other,
        error: 'connection refused',
      );

      when(() => mockApiService.searchEverything(
            apiKey: any(named: 'apiKey'),
            q: any(named: 'q'),
            language: any(named: 'language'),
            sortBy: any(named: 'sortBy'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(dioError);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, isA<NetworkException>());
    });

    test('returns DataFailed with NetworkException when HTTP status is not 200',
        () async {
      final response = Response<List<ArticleModel>>(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 500,
        statusMessage: 'Internal Server Error',
        data: null,
      );
      final httpResponse =
          HttpResponse<List<ArticleModel>>(testModels, response);

      when(() => mockApiService.searchEverything(
            apiKey: any(named: 'apiKey'),
            q: any(named: 'q'),
            language: any(named: 'language'),
            sortBy: any(named: 'sortBy'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, isA<NetworkException>());
      expect(result.error?.code, equals('500'));
    });

    test('returns DataFailed with UnknownException when unexpected error occurs',
        () async {
      when(() => mockApiService.searchEverything(
            apiKey: any(named: 'apiKey'),
            q: any(named: 'q'),
            language: any(named: 'language'),
            sortBy: any(named: 'sortBy'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(Exception('unexpected'));

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, isA<UnknownException>());
    });
  });

  group('ArticleRepositoryImpl saved CRUD (Firestore-backed)', () {
    const entity = ArticleEntity(
      author: 'Author',
      title: 'Title',
      description: 'Desc',
      url: 'https://example.com',
      urlToImage: 'https://example.com/img.jpg',
      publishedAt: '2024-01-01',
      content: 'Content',
    );

    test('getSavedArticles forwards to service with the current uid', () async {
      when(() => mockSavedService.getSavedArticles('anon-uid'))
          .thenAnswer((_) async => const [entity]);

      final result = await repository.getSavedArticles();

      expect(result, hasLength(1));
      expect(result.first.title, equals('Title'));
      verify(() => mockSavedService.getSavedArticles('anon-uid')).called(1);
    });

    test('saveArticle forwards to service with the current uid', () async {
      when(() => mockSavedService.saveArticle('anon-uid', any()))
          .thenAnswer((_) async {});

      await repository.saveArticle(entity);

      verify(() => mockSavedService.saveArticle('anon-uid', entity)).called(1);
    });

    test('removeArticle forwards to service with the current uid', () async {
      when(() => mockSavedService.removeArticle('anon-uid', any()))
          .thenAnswer((_) async {});

      await repository.removeArticle(entity);

      verify(() => mockSavedService.removeArticle('anon-uid', entity)).called(1);
    });

    test('isArticleSaved forwards to service with the current uid', () async {
      when(() => mockSavedService.isSaved('anon-uid', any()))
          .thenAnswer((_) async => true);

      final result = await repository.isArticleSaved(entity);

      expect(result, isTrue);
      verify(() => mockSavedService.isSaved('anon-uid', entity)).called(1);
    });

    test('throws AuthException when no Firebase user is signed in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(() => repository.getSavedArticles(),
          throwsA(isA<AuthException>()));
      expect(() => repository.saveArticle(entity),
          throwsA(isA<AuthException>()));
      expect(() => repository.removeArticle(entity),
          throwsA(isA<AuthException>()));
      expect(() => repository.isArticleSaved(entity),
          throwsA(isA<AuthException>()));
    });
  });
}
