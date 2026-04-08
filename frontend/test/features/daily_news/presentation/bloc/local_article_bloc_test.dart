import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class _MockGetSavedArticleUseCase extends Mock implements GetSavedArticleUseCase {}

class _MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class _MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

void main() {
  late _MockGetSavedArticleUseCase getSavedArticleUseCase;
  late _MockSaveArticleUseCase saveArticleUseCase;
  late _MockRemoveArticleUseCase removeArticleUseCase;

  const article = ArticleEntity(title: 'A');

  setUp(() {
    getSavedArticleUseCase = _MockGetSavedArticleUseCase();
    saveArticleUseCase = _MockSaveArticleUseCase();
    removeArticleUseCase = _MockRemoveArticleUseCase();
  });

  test('loads saved articles', () async {
    when(() => getSavedArticleUseCase()).thenAnswer((_) async => <ArticleEntity>[article]);
    final bloc = LocalArticleBloc(getSavedArticleUseCase, saveArticleUseCase, removeArticleUseCase);

    expectLater(
      bloc.stream,
      emitsInOrder(<Object>[const LocalArticlesDone(<ArticleEntity>[article])]),
    );

    bloc.add(const GetSavedArticles());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await bloc.close();
  });

  test('saves article then emits updated list', () async {
    when(() => saveArticleUseCase(params: article)).thenAnswer((_) async {});
    when(() => getSavedArticleUseCase()).thenAnswer((_) async => <ArticleEntity>[article]);
    final bloc = LocalArticleBloc(getSavedArticleUseCase, saveArticleUseCase, removeArticleUseCase);

    expectLater(
      bloc.stream,
      emitsInOrder(<Object>[const LocalArticlesDone(<ArticleEntity>[article])]),
    );

    bloc.add(const SaveArticle(article));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await bloc.close();
  });
}
