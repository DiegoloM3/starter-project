import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/get_all_articles.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_bloc.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_event.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_state.dart';

import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

import '../../_fixtures/article_upload_fixture.dart';

class _MockGetAllArticles extends Mock implements GetAllArticlesUseCase {}

class _MockDeleteArticle extends Mock implements DeleteArticleUseCase {}

void main() {
  late _MockGetAllArticles getAll;
  late _MockDeleteArticle deleteArticle;

  setUp(() {
    getAll = _MockGetAllArticles();
    deleteArticle = _MockDeleteArticle();
  });

  group('ArticlesListBloc', () {
    test('starts in ArticlesListInitial state', () {
      expect(
        ArticlesListBloc(getAll, deleteArticle).state,
        const ArticlesListInitial(),
      );
    });

    blocTest<ArticlesListBloc, ArticlesListState>(
      'emits [Loading, Loaded] on FetchArticles success',
      build: () {
        final articles = [
          ArticleUploadFixture.sample(id: 'a'),
          ArticleUploadFixture.sample(id: 'b'),
        ];
        when(() => getAll()).thenAnswer((_) async => DataSuccess(articles));
        return ArticlesListBloc(getAll, deleteArticle);
      },
      act: (bloc) => bloc.add(const FetchArticles()),
      expect: () => [
        const ArticlesListLoading(),
        isA<ArticlesListLoaded>()
            .having((s) => s.allArticles.length, 'allArticles.length', 2)
            .having((s) => s.visibleArticles.length, 'visible.length', 2)
            .having((s) => s.query, 'query', ''),
      ],
      verify: (_) => verify(() => getAll()).called(1),
    );

    blocTest<ArticlesListBloc, ArticlesListState>(
      'filters visibleArticles on SearchQueryChanged by title',
      build: () {
        final articles = <ArticleUploadEntity>[
          ArticleUploadFixture.sample(id: 'a', title: 'Symmetry launches'),
          ArticleUploadFixture.sample(id: 'b', title: 'Flutter 4 beta'),
        ];
        when(() => getAll()).thenAnswer((_) async => DataSuccess(articles));
        return ArticlesListBloc(getAll, deleteArticle);
      },
      act: (bloc) async {
        bloc.add(const FetchArticles());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SearchQueryChanged('Symmetry'));
      },
      skip: 2, // Loading + Loaded(empty query)
      expect: () => [
        isA<ArticlesListLoaded>()
            .having((s) => s.query, 'query', 'Symmetry')
            .having((s) => s.visibleArticles.length, 'visible.length', 1)
            .having((s) => s.visibleArticles.first.id, 'first.id', 'a'),
      ],
    );

    blocTest<ArticlesListBloc, ArticlesListState>(
      'ignores SearchQueryChanged while not in Loaded state',
      build: () => ArticlesListBloc(getAll, deleteArticle),
      act: (bloc) => bloc.add(const SearchQueryChanged('anything')),
      expect: () => <ArticlesListState>[],
    );

    blocTest<ArticlesListBloc, ArticlesListState>(
      'emits [Loading, Error] when the use case returns DataFailed',
      build: () {
        when(() => getAll())
            .thenAnswer((_) async => DataFailed(Exception('offline')));
        return ArticlesListBloc(getAll, deleteArticle);
      },
      act: (bloc) => bloc.add(const FetchArticles()),
      expect: () => [
        const ArticlesListLoading(),
        isA<ArticlesListError>(),
      ],
    );

    blocTest<ArticlesListBloc, ArticlesListState>(
      'refetches after a successful delete',
      build: () {
        when(() => deleteArticle(params: 'a'))
            .thenAnswer((_) async => const DataSuccess(null));
        when(() => getAll()).thenAnswer((_) async => const DataSuccess([]));
        return ArticlesListBloc(getAll, deleteArticle);
      },
      act: (bloc) => bloc.add(const DeleteArticleRequested('a')),
      expect: () => [
        const ArticlesListLoading(),
        isA<ArticlesListLoaded>()
            .having((s) => s.allArticles, 'allArticles', <Object>[]),
      ],
      verify: (_) {
        verify(() => deleteArticle(params: 'a')).called(1);
        verify(() => getAll()).called(1);
      },
    );
  });
}
