import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/local_database_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_status.dart';

class MockGetSavedArticlesUseCase extends Mock
    implements GetSavedArticlesUseCase {}

class MockGetSavedArticleUseCase extends Mock
    implements GetSavedArticleUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

class FakeArticleEntity extends Fake implements ArticleEntity {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockGetSavedArticlesUseCase mockGetSavedArticlesUseCase;
  late MockSaveArticleUseCase mockSaveArticleUseCase;
  late MockRemoveArticleUseCase mockRemoveArticleUseCase;
  late MockGetSavedArticleUseCase mockGetSavedArticleUseCase;

  setUpAll(() {
    registerFallbackValue(FakeArticleEntity());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetSavedArticlesUseCase = MockGetSavedArticlesUseCase();
    mockSaveArticleUseCase = MockSaveArticleUseCase();
    mockRemoveArticleUseCase = MockRemoveArticleUseCase();
    mockGetSavedArticleUseCase = MockGetSavedArticleUseCase();
  });

  LocalArticleBloc createBloc() {
    return LocalArticleBloc(
      mockGetSavedArticlesUseCase,
      mockSaveArticleUseCase,
      mockRemoveArticleUseCase,
      mockGetSavedArticleUseCase,
    );
  }

  const testArticle = ArticleEntity(
    id: '1',
    title: 'Test Title',
    author: 'Test Author',
    description: 'Test Description',
  );

  final testArticles = [testArticle];
  const dbError = LocalDatabaseUnknownException(message: 'DB Error');

  group('Initialization (GetSavedArticles)', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticlesDone] when initialized with data',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => DataSuccess(testArticles));
        return createBloc();
      },
      expect: () => [
        LocalArticlesDone(
          articles: testArticles,
          status: LocalArticleStatus.none,
          isSaved: false,
        ),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticleEmpty] when initialized with no data',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        return createBloc();
      },
      expect: () => [
        const LocalArticleEmpty(status: LocalArticleStatus.none),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticlesError] when initialization fails',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => const DataFailed(dbError));
        return createBloc();
      },
      expect: () => [
        const LocalArticlesError(dbError),
      ],
    );
  });

  group('SaveArticle', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits status savedSuccess then none when saving is successful',
      build: () {
        int count = 0;
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async {
          if (count == 0) {
            count++;
            return const DataSuccess([]);
          }
          return DataSuccess(testArticles);
        });
        when(() => mockSaveArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const SaveArticle(testArticle)),
      expect: () => [
        LocalArticlesDone(
            articles: testArticles,
            status: LocalArticleStatus.savedSuccess,
            isSaved: true),
        LocalArticlesDone(
            articles: testArticles,
            status: LocalArticleStatus.none,
            isSaved: true),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits status genericError then none when refresh fails after saving and state was Done',
      build: () {
        int count = 0;
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async {
          if (count == 0) {
            count++;
            return DataSuccess(testArticles);
          }
          return const DataFailed(dbError);
        });
        when(() => mockSaveArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const SaveArticle(testArticle)),
      expect: () => [
        LocalArticlesDone(
            articles: testArticles,
            status: LocalArticleStatus.genericError,
            isSaved: false),
        LocalArticlesDone(
            articles: testArticles,
            status: LocalArticleStatus.none,
            isSaved: false),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits LocalArticlesError when refresh fails after saving and state was Empty',
      build: () {
        int count = 0;
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async {
          if (count == 0) {
            count++;
            return const DataSuccess([]);
          }
          return const DataFailed(dbError);
        });
        when(() => mockSaveArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const SaveArticle(testArticle)),
      expect: () => [
        const LocalArticlesError(dbError),
      ],
    );
  });

  group('RemoveArticle', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits status deletedSuccess then none when removal is successful',
      build: () {
        int count = 0;
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async {
          if (count == 0) {
            count++;
            return DataSuccess(testArticles);
          }
          return const DataSuccess([]);
        });
        when(() => mockRemoveArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const RemoveArticle(testArticle)),
      expect: () => [
        const LocalArticleEmpty(status: LocalArticleStatus.deletedSuccess),
        const LocalArticleEmpty(status: LocalArticleStatus.none),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits status genericError then none when refresh fails after removal and state was Done',
      build: () {
        int count = 0;
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async {
          if (count == 0) {
            count++;
            return DataSuccess(testArticles);
          }
          return const DataFailed(dbError);
        });
        when(() => mockRemoveArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const RemoveArticle(testArticle)),
      expect: () => [
        LocalArticlesDone(
            articles: testArticles,
            status: LocalArticleStatus.genericError,
            isSaved: false),
        LocalArticlesDone(
            articles: testArticles,
            status: LocalArticleStatus.none,
            isSaved: false),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits LocalArticlesError when refresh fails after removal and state was Empty',
      build: () {
        int count = 0;
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async {
          if (count == 0) {
            count++;
            return const DataSuccess([]);
          }
          return const DataFailed(dbError);
        });
        when(() => mockRemoveArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const RemoveArticle(testArticle)),
      expect: () => [
        const LocalArticlesError(dbError),
      ],
    );
  });

  group('GetSavedArticle', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits clearSave then LocalArticlesDone with isSaved true when article exists',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => DataSuccess(testArticles));
        when(() => mockGetSavedArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(testArticle));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const GetSavedArticle('1')),
      expect: () => [
        LocalArticlesDone(
          articles: testArticles,
          status: LocalArticleStatus.none,
          isSaved: null,
        ),
        LocalArticlesDone(
          articles: testArticles,
          status: LocalArticleStatus.none,
          isSaved: true,
        ),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits clearSave then LocalArticlesDone with isSaved false when article does not exist',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => DataSuccess(testArticles));
        when(() => mockGetSavedArticleUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess(null));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const GetSavedArticle('1')),
      expect: () => [
        LocalArticlesDone(
          articles: testArticles,
          status: LocalArticleStatus.none,
          isSaved: null,
        ),
        LocalArticlesDone(
          articles: testArticles,
          status: LocalArticleStatus.none,
          isSaved: false,
        ),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'does nothing when state is not LocalArticlesDone',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const GetSavedArticle('1')),
      expect: () => [],
    );
  });

  group('ClearBookmark', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits clearSave when state is LocalArticlesDone',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => DataSuccess(testArticles));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const ClearBookmark()),
      expect: () => [
        LocalArticlesDone(
          articles: testArticles,
          status: LocalArticleStatus.none,
          isSaved: null,
        ),
      ],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'does nothing when state is not LocalArticlesDone',
      build: () {
        when(() => mockGetSavedArticlesUseCase.call(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        return createBloc();
      },
      skip: 1, 
      act: (bloc) => bloc.add(const ClearBookmark()),
      expect: () => [],
    );
  });
}
