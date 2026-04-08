import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class _MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

void main() {
  late _MockGetArticleUseCase getArticleUseCase;

  setUp(() {
    getArticleUseCase = _MockGetArticleUseCase();
  });

  test('emits RemoteArticlesDone when use case succeeds with data', () async {
    when(() => getArticleUseCase()).thenAnswer(
      (_) async => const DataSuccess<List<ArticleEntity>>(
        <ArticleEntity>[ArticleEntity(title: 'A')],
      ),
    );
    final bloc = RemoteArticlesBloc(getArticleUseCase);

    bloc.add(const GetArticles());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state, isA<RemoteArticlesDone>());
    final current = bloc.state as RemoteArticlesDone;
    expect(current.articles?.first.title, 'A');

    await bloc.close();
  });
}
