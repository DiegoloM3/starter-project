import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

// States are built without `const` on purpose: identical const instances would
// short-circuit `==` and never reach `props`, which is what these tests cover.
// ignore_for_file: prefer_const_constructors
void main() {
  group('RemoteArticlesState equality', () {
    test('two done states with the same articles are equal', () {
      const articles = [ArticleEntity(id: 1, title: 'Title')];

      expect(RemoteArticlesDone(articles), RemoteArticlesDone(articles));
    });

    test('two error states with the same error are equal', () {
      final error = Exception('network down');

      expect(RemoteArticlesError(error), RemoteArticlesError(error));
    });

    test('two loading states are equal', () {
      expect(RemoteArticlesLoading(), RemoteArticlesLoading());
    });
  });
}
