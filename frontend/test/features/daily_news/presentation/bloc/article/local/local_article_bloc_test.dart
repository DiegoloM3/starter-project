import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/register_fallback_values.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late LocalArticleBloc bloc;
  late MockGetSavedArticleUseCase mockGetSaved;
  late MockSaveArticleUseCase mockSave;
  late MockRemoveArticleUseCase mockRemove;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockGetSaved = MockGetSavedArticleUseCase();
    mockSave = MockSaveArticleUseCase();
    mockRemove = MockRemoveArticleUseCase();
    bloc = LocalArticleBloc(mockGetSaved, mockSave, mockRemove);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is LocalArticlesLoading', () {
      expect(bloc.state, isA<LocalArticlesLoading>());
    });
  });

  group('GetSavedArticles', () {
    test('emits Done with articles on success', () async {
      final articles = testArticleList();
      when(() => mockGetSaved()).thenAnswer((_) async => articles);

      bloc.add(const GetSavedArticles());
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      final state = bloc.state as LocalArticlesDone;
      expect(state.articles!.length, 3);
      verify(() => mockGetSaved()).called(1);
    });

    test('emits Done with empty list when no saved articles', () async {
      when(() => mockGetSaved()).thenAnswer((_) async => []);

      bloc.add(const GetSavedArticles());
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      final state = bloc.state as LocalArticlesDone;
      expect(state.articles, isEmpty);
    });
  });

  group('SaveArticle', () {
    test('saves article then refreshes list', () async {
      final article = testArticle();
      when(() => mockSave(params: any(named: 'params')))
          .thenAnswer((_) async {});
      when(() => mockGetSaved()).thenAnswer((_) async => [article]);

      bloc.add(SaveArticle(article));
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      verify(() => mockSave(params: any(named: 'params'))).called(1);
      verify(() => mockGetSaved()).called(1);
    });
  });

  group('RemoveArticle', () {
    test('removes article then refreshes list', () async {
      final article = testArticle();
      when(() => mockRemove(params: any(named: 'params')))
          .thenAnswer((_) async {});
      when(() => mockGetSaved()).thenAnswer((_) async => []);

      bloc.add(RemoveArticle(article));
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      final state = bloc.state as LocalArticlesDone;
      expect(state.articles, isEmpty);
      verify(() => mockRemove(params: any(named: 'params'))).called(1);
      verify(() => mockGetSaved()).called(1);
    });
  });
}
