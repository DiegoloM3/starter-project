import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/get_published_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/pages/published_articles_page.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/article_image_picker.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import '../../../../publish_article/support/fake_publish_article_repository.dart';
import '../../../../publish_article/support/fake_read_published_articles_repository.dart';

class ControlledNews implements GetArticleUseCase {
  final requests = <Completer<DataState<List<ArticleEntity>>>>[];

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    final request = Completer<DataState<List<ArticleEntity>>>();
    requests.add(request);
    return request.future;
  }
}

class UnusedPicker implements ArticleImagePicker {
  @override
  Future<ArticleThumbnail?> pickImage() async => null;
}

void main() {
  late ControlledNews news;
  late RemoteArticlesBloc bloc;
  setUp(() async {
    await sl.reset();
    news = ControlledNews();
    bloc = RemoteArticlesBloc(news);
    sl.registerFactory<PublishArticleCubit>(() => PublishArticleCubit(
        PublishArticleUseCase(FakePublishArticleRepository())));
    sl.registerSingleton<ArticleImagePicker>(UnusedPicker());
    sl.registerFactory<PublishedArticlesCubit>(() => PublishedArticlesCubit(
          GetPublishedArticlesUseCase(FakeReadPublishedArticlesRepository()),
        ));
  });
  tearDown(() async {
    for (final request in news.requests) {
      if (!request.isCompleted) request.complete(const DataSuccess([]));
    }
    await bloc.close();
    await sl.reset();
  });

  Future<void> openHome(WidgetTester tester) async {
    bloc.add(const GetArticles());
    await tester.pumpWidget(BlocProvider<RemoteArticlesBloc>.value(
      value: bloc,
      child: const MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: DailyNews(),
      ),
    ));
    await tester.pump();
    expect(news.requests, hasLength(1));
  }

  for (final state in ['loading', 'error', 'empty', 'articles']) {
    testWidgets('Home $state keeps one scaffold and navigates to publication',
        (tester) async {
      await openHome(tester);
      if (state == 'error') {
        news.requests.single.complete(DataFailed(
            DioException(requestOptions: RequestOptions(path: '/news'))));
      } else if (state == 'empty') {
        news.requests.single.complete(const DataSuccess([]));
      } else if (state == 'articles') {
        news.requests.single.complete(const DataSuccess([
          ArticleEntity(
              title: 'Existing news',
              description: 'Summary',
              publishedAt: '2026-09-18',
              urlToImage: ''),
        ]));
      }
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pump();
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      if (state == 'loading') {
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      } else if (state == 'error') {
        expect(find.text('Unable to load news. Retry'), findsOneWidget);
      } else if (state == 'empty') {
        expect(bloc.state, isA<RemoteArticlesDone>());
        expect(find.text('No news available.'), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      } else {
        expect(find.byType(ArticleWidget), findsOneWidget);
        expect(find.text('Existing news'), findsOneWidget);
      }
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PublishArticlePage), findsOneWidget);
      expect(
          find.byKey(const Key('publishArticleSubmitButton')), findsOneWidget);
      expect(news.requests, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('retry requests news again and completes with an empty state',
      (tester) async {
    await openHome(tester);
    news.requests.single.complete(DataFailed(
        DioException(requestOptions: RequestOptions(path: '/news'))));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Unable to load news. Retry'));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    await tester.pump();
    expect(news.requests, hasLength(2));
    expect(bloc.state, isA<RemoteArticlesLoading>());
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Unable to load news. Retry'), findsNothing);
    news.requests.last.complete(const DataSuccess([]));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    await tester.pump();
    expect(bloc.state, isA<RemoteArticlesDone>());
    expect(find.text('No news available.'), findsOneWidget);
  });

  testWidgets('Home opens the independent Published Articles section',
      (tester) async {
    await openHome(tester);

    await tester.tap(find.byTooltip('Published Articles'));
    await tester.pumpAndSettle();

    expect(find.byType(PublishedArticlesPage), findsOneWidget);
    expect(find.text('No published articles yet.'), findsOneWidget);
  });
}
