import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';

import '../../../../fakes/fake_firestore_article_repository.dart';

void main() {
  late FakeFirestoreArticleRepository repository;
  late FirestoreArticlesBloc bloc;

  setUp(() {
    repository = FakeFirestoreArticleRepository();
    bloc = FirestoreArticlesBloc(GetFirestoreArticlesUseCase(repository));
  });

  tearDown(() {
    bloc.close();
  });

  group('FirestoreArticlesBloc', () {
    test('initial state is Loading', () {
      expect(bloc.state, isA<FirestoreArticlesLoading>());
    });

    test('emits Done with articles on success', () async {
      const articles = [
        ArticleEntity(
          documentId: 'doc-1',
          title: 'Test Article',
          section: NewsSection.sports,
        ),
      ];
      repository.getResult = const DataSuccess(articles);

      bloc.add(const GetFirestoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<FirestoreArticlesDone>());
      final doneState = bloc.state as FirestoreArticlesDone;
      expect(doneState.articles?.length, 1);
      expect(doneState.articles?.first.title, 'Test Article');
    });

    test('emits Done with empty list when no articles', () async {
      repository.getResult = const DataSuccess([]);

      bloc.add(const GetFirestoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<FirestoreArticlesDone>());
      expect((bloc.state as FirestoreArticlesDone).articles, isEmpty);
    });

    test('emits Error with correct ErrorType on failure', () async {
      repository.getResult = const DataFailed(NetworkFailure());

      bloc.add(const GetFirestoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<FirestoreArticlesError>());
      expect(
          (bloc.state as FirestoreArticlesError).errorType, ErrorType.network);
    });

    test('reloads articles when GetFirestoreArticles dispatched again',
        () async {
      repository.getResult = const DataSuccess([
        ArticleEntity(documentId: 'doc-1', title: 'First'),
      ]);

      bloc.add(const GetFirestoreArticles());
      await Future.delayed(Duration.zero);

      expect(
          (bloc.state as FirestoreArticlesDone).articles?.first.title, 'First');

      repository.getResult = const DataSuccess([
        ArticleEntity(documentId: 'doc-1', title: 'First'),
        ArticleEntity(documentId: 'doc-2', title: 'Second'),
      ]);

      bloc.add(const GetFirestoreArticles());
      await Future.delayed(Duration.zero);

      expect((bloc.state as FirestoreArticlesDone).articles?.length, 2);
    });
  });
}
