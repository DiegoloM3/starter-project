import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/search_history_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_recent_searches.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_search.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_search.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/search/search_screen.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

class _FakeSearch implements SearchArticlesUseCase {
  SearchQuery? lastQuery;

  @override
  Future<DataState<NewsPage>> call({SearchQuery? params}) async {
    lastQuery = params;
    return DataSuccess(NewsPage(
      articles: params!.text == 'nothing'
          ? const []
          : const [ArticleEntity(url: 'u', title: 'Climate summit ends')],
      hasMore: false,
    ));
  }
}

class _NoSavedArticles implements ArticleRepository {
  @override
  Future<List<ArticleEntity>> getSavedArticles() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryHistory implements SearchHistoryRepository {
  final searches = <String>[];

  @override
  Future<List<SearchHistoryEntity>> getRecentSearches() async =>
      [for (final text in searches) SearchHistoryEntity(text: text)];

  @override
  Future<void> saveSearch(String text) async => searches
    ..remove(text)
    ..insert(0, text);

  @override
  Future<void> removeSearch(String text) async => searches.remove(text);
}

Widget _app(
  _FakeSearch search, {
  Locale locale = const Locale('en'),
  _MemoryHistory? history,
}) {
  final saved = _NoSavedArticles();
  final recent = history ?? _MemoryHistory();
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => SearchCubit(
          search,
          GetRecentSearchesUseCase(recent),
          SaveSearchUseCase(recent),
          RemoveSearchUseCase(recent),
        )..showHistory(),
      ),
      BlocProvider(
        create: (_) => LocalArticleBloc(
          GetSavedArticleUseCase(saved),
          SaveArticleUseCase(saved),
          RemoveArticleUseCase(saved),
        ),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const SearchScreen(),
    ),
  );
}

void main() {
  testWidgets('searching shows the stories found', (tester) async {
    final search = _FakeSearch();
    await tester.pumpWidget(_app(search));

    await tester.enterText(find.byType(TextField), 'climate');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Climate summit ends'), findsOneWidget);
  });

  testWidgets('searches in the language the app is in', (tester) async {
    final search = _FakeSearch();
    await tester.pumpWidget(_app(search, locale: const Locale('es')));

    await tester.enterText(find.byType(TextField), 'clima');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(search.lastQuery!.languageCode, 'es');
  });

  testWidgets('says so when nothing matches', (tester) async {
    await tester.pumpWidget(_app(_FakeSearch()));

    await tester.enterText(find.byType(TextField), 'nothing');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('No results for “nothing”'), findsOneWidget);
  });

  testWidgets('shows recent searches and removes one with its X',
      (tester) async {
    final history = _MemoryHistory()..searches.addAll(['climate', 'budget']);
    await tester.pumpWidget(_app(_FakeSearch(), history: history));
    await tester.pumpAndSettle();
    expect(find.text('climate'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from history').first);
    await tester.pumpAndSettle();

    expect(find.text('climate'), findsNothing);
    expect(find.text('budget'), findsOneWidget);
  });

  testWidgets('tapping a recent search runs it again', (tester) async {
    final search = _FakeSearch();
    final history = _MemoryHistory()..searches.add('climate');
    await tester.pumpWidget(_app(search, history: history));
    await tester.pumpAndSettle();

    await tester.tap(find.text('climate'));
    await tester.pumpAndSettle();

    expect(search.lastQuery!.text, 'climate');
    expect(find.text('Climate summit ends'), findsOneWidget);
  });
}
