import 'dart:async';

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
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_result.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/publish_article_state.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/article_image_picker.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import '../../support/fake_publish_article_repository.dart';
import '../../support/publication_data_source_fakes.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/repository/publish_article_repository_impl.dart';

import 'publish_article_page_test.dart'
    show FakeArticleImagePicker, imageThumbnail, configurePhoneSize;

class ControlledPublisher extends PublishArticleUseCase {
  final Future<void> Function(int attempt) beforePublish;
  int calls = 0;

  ControlledPublisher(this.beforePublish)
      : super(FakePublishArticleRepository());

  @override
  Future<PublishArticleResult> call({PublishArticleParams? params}) async {
    await beforePublish(++calls);
    return super.call(params: params);
  }
}

class TestPublishCubit extends PublishArticleCubit {
  TestPublishCubit(PublishArticleUseCase useCase) : super(useCase);

  void repeatSuccess() {
    emit(state.copyWith(status: PublishArticleStatus.submitting));
    emit(state.copyWith(status: PublishArticleStatus.success));
  }
}

class FixtureNews implements GetArticleUseCase {
  int calls = 0;

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) async {
    calls++;
    return const DataSuccess([
      ArticleEntity(
          title: 'Existing NewsAPI article',
          description: 'Feed summary',
          urlToImage: '',
          publishedAt: '2026-09-18'),
    ]);
  }
}

class TrackingNewsBloc extends RemoteArticlesBloc {
  TrackingNewsBloc(GetArticleUseCase useCase) : super(useCase);
  int events = 0;

  @override
  void onEvent(RemoteArticlesEvent event) {
    events++;
    super.onEvent(event);
  }
}

class PopObserver extends NavigatorObserver {
  int pops = 0;
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pops++;
    super.didPop(route, previousRoute);
  }
}

const successMessage = 'Article published successfully.';
final submit = find.byKey(const Key('publishArticleSubmitButton'));

// Home's cached-image loading indicator may animate indefinitely in widget tests.
// Advance route, scroll and SnackBar transitions without waiting for network images.
Future<void> pumpTransitions(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> fillForm(WidgetTester tester) async {
  for (final entry in {
    'Title': 'My published title',
    'Author': 'Jane Doe',
    'Description': 'My summary',
    'Content': 'My article content',
  }.entries) {
    final field = find.byKey(Key('publishArticle${entry.key}Field'));
    await tester.ensureVisible(field);
    await tester.enterText(field, entry.value);
  }
  tester.testTextInput.hide();
  final attach = find.byKey(const Key('publishArticleAttachImageButton'));
  await tester.ensureVisible(attach);
  await tester.tap(attach);
  await pumpTransitions(tester);
}

void main() {
  late FixtureNews news;
  late TrackingNewsBloc newsBloc;
  late PopObserver observer;
  late GlobalKey<NavigatorState> navigator;

  setUp(() async {
    await sl.reset();
    news = FixtureNews();
    newsBloc = TrackingNewsBloc(news);
    final loaded =
        newsBloc.stream.firstWhere((state) => state is RemoteArticlesDone);
    newsBloc.add(const GetArticles());
    await loaded;
    observer = PopObserver();
    navigator = GlobalKey<NavigatorState>();
    sl.registerSingleton<ArticleImagePicker>(
        FakeArticleImagePicker()..result = imageThumbnail('selected.png'));
  });

  tearDown(() async {
    await newsBloc.close();
    await sl.reset();
  });

  Future<void> openForm(
    WidgetTester tester,
    PublishArticleCubit cubit, {
    Widget? home,
    Route<dynamic> Function(RouteSettings)? route,
  }) async {
    configurePhoneSize(tester);
    sl.registerFactory<PublishArticleCubit>(() => cubit);
    await tester.pumpWidget(BlocProvider<RemoteArticlesBloc>.value(
      value: newsBloc,
      child: MaterialApp(
          navigatorKey: navigator,
          navigatorObservers: [observer],
          onGenerateRoute: route ?? AppRoutes.onGenerateRoutes,
          home: home ?? const DailyNews()),
    ));
    await pumpTransitions(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await pumpTransitions(tester);
  }

  testWidgets(
      'queued write unlocks navigation and offers same-attempt confirmation',
      (tester) async {
    final events = <String>[];
    final firestore = PublicationFirestoreFake(events)
      ..createGate = Completer<void>();
    final cubit = PublishArticleCubit(PublishArticleUseCase(
        PublishArticleRepositoryImpl(
            firestore, PublicationStorageFake(events))));
    await openForm(tester, cubit);
    await fillForm(tester);
    await tester.tap(submit);
    await tester.pump();
    expect(cubit.state.isSubmitting, isTrue);
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(cubit.state.isConfirmationPending, isTrue);
    expect(find.text(PublishArticleState.confirmationPendingMessage),
        findsOneWidget);
    expect(find.text('Check confirmation'), findsOneWidget);
    expect(find.text('Unable to publish the article. Please try again.'),
        findsNothing);
    expect(find.text(successMessage), findsNothing);
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
    expect(
        tester
            .widget<PopScope>(find.byWidgetPredicate((w) => w is PopScope))
            .canPop,
        isTrue);
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
    await tester.tap(submit);
    await tester.pump();
    await tester.tap(submit);
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
    firestore.createGate!.complete();
    await pumpTransitions(tester);
    expect(observer.pops, 1);
    expect(find.text(successMessage), findsOneWidget);
    expect(firestore.ids, 1);
    expect(events.where((e) => e.startsWith('upload:')), hasLength(1));
    expect(events.where((e) => e.startsWith('create:')), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  for (final systemBack in [false, true]) {
    testWidgets(
        'pending confirmation permits back and retains recovery: system=$systemBack',
        (tester) async {
      final events = <String>[];
      final firestore = PublicationFirestoreFake(events)
        ..createGate = Completer<void>();
      final repository = PublishArticleRepositoryImpl(
          firestore, PublicationStorageFake(events));
      final cubit = PublishArticleCubit(PublishArticleUseCase(repository));
      await openForm(tester, cubit);
      await fillForm(tester);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      if (systemBack) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.byKey(const Key('publishArticleBackButton')));
      }
      await pumpTransitions(tester);
      expect(observer.pops, 1);
      expect(find.byType(PublishArticlePage), findsNothing);
      expect(find.text(successMessage), findsNothing);
      firestore.createGate!.complete();
      await tester.pump();
      expect(
          (await repository.confirmPublication('article-1')).id, 'article-1');
      expect(firestore.ids, 1);
      expect(events.where((e) => e.startsWith('create:')), hasLength(1));
      expect(find.text(successMessage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'valid publication loads, returns true once and confirms on Home without changing feed',
      (tester) async {
    final gate = Completer<void>();
    final publisher = ControlledPublisher((_) => gate.future);
    final cubit = TestPublishCubit(publisher);
    final feedState = newsBloc.state;
    await openForm(tester, cubit);
    await fillForm(tester);
    await tester.tap(submit);
    await tester.pump();
    expect(cubit.state.status, PublishArticleStatus.submitting);
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);
    expect(find.text('Publishing...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(submit);
    expect(publisher.calls, 1);
    gate.complete();
    await tester.pump();
    // Repeated terminal transitions while the route is still animating out.
    cubit.repeatSuccess();
    await pumpTransitions(tester);
    expect(observer.pops, 1);
    expect(find.byType(PublishArticlePage), findsNothing);
    expect(find.byType(DailyNews), findsOneWidget);
    expect(find.text(successMessage), findsOneWidget);
    expect(newsBloc.state, same(feedState));
    expect(newsBloc.events, 1);
    expect(news.calls, 1);
    expect(find.byType(ArticleWidget), findsOneWidget);
    expect(find.text('Existing NewsAPI article'), findsOneWidget);
    expect(find.text('My published title'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await pumpTransitions(tester);
    expect(find.text(successMessage), findsNothing);
  });

  testWidgets('manual back returns no success and Home shows no confirmation',
      (tester) async {
    await openForm(
        tester,
        PublishArticleCubit(
            PublishArticleUseCase(FakePublishArticleRepository())));
    await tester.tap(find.byKey(const Key('publishArticleBackButton')));
    await pumpTransitions(tester);
    expect(observer.pops, 1);
    expect(find.byType(PublishArticlePage), findsNothing);
    expect(find.byType(DailyNews), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
      'validation keeps the route open and scrolls to first visible-order error without SnackBar',
      (tester) async {
    final cubit = PublishArticleCubit(
        PublishArticleUseCase(FakePublishArticleRepository()));
    await openForm(tester, cubit);
    await tester
        .ensureVisible(find.byKey(const Key('publishArticleContentField')));
    await tester.tap(submit);
    await pumpTransitions(tester);
    expect(observer.pops, 0);
    expect(find.byType(PublishArticlePage), findsOneWidget);
    expect(cubit.state.status, PublishArticleStatus.validationFailure);
    expect(find.text('Required.'), findsNWidgets(4));
    expect(find.text('Image bytes are required.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    final title = find.byKey(const Key('publishArticleTitleField'));
    expect(title.hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(title).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.byType(AppBar)).dy));
  });

  testWidgets(
      'failure preserves fields and image, shows message, and permits successful retry',
      (tester) async {
    final publisher = ControlledPublisher((attempt) async {
      if (attempt == 1) throw StateError('Simulated failure');
    });
    final cubit = PublishArticleCubit(publisher);
    await openForm(tester, cubit);
    await fillForm(tester);
    final thumbnail = cubit.state.thumbnail;
    await tester.tap(submit);
    await pumpTransitions(tester);
    expect(observer.pops, 0);
    expect(find.byType(PublishArticlePage), findsOneWidget);
    expect(cubit.state.status, PublishArticleStatus.failure);
    expect(find.text(cubit.state.failureMessage!), findsOneWidget);
    expect(cubit.state.thumbnail, same(thumbnail));
    expect(find.text('selected.png'), findsOneWidget);
    expect(find.byKey(const Key('publishArticleImagePreview')), findsOneWidget);
    for (final entry in {
      'Title': 'My published title',
      'Author': 'Jane Doe',
      'Description': 'My summary',
      'Content': 'My article content'
    }.entries) {
      expect(
          tester
                  .widget<TextField>(
                      find.byKey(Key('publishArticle${entry.key}Field')))
                  .controller
                  ?.text ??
              tester
                  .widget<EditableText>(find.descendant(
                      of: find.byKey(Key('publishArticle${entry.key}Field')),
                      matching: find.byType(EditableText)))
                  .controller
                  .text,
          entry.value);
    }
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
    await tester.tap(submit);
    await pumpTransitions(tester);
    expect(publisher.calls, 2);
    expect(observer.pops, 1);
    expect(find.text(successMessage), findsOneWidget);
    expect(find.text('Unable to publish the article. Please try again.'),
        findsNothing);
  });

  for (final result in <bool?>[true, false, null]) {
    testWidgets('Home confirms only a true route result: $result',
        (tester) async {
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));
      addTearDown(cubit.close);
      await openForm(tester, cubit, route: (settings) {
        expect(settings.name, '/PublishArticle');
        return MaterialPageRoute<bool>(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => Navigator.pop(context, result),
                    child: const Text('Return result'))));
      });
      await tester.tap(find.text('Return result'));
      await pumpTransitions(tester);
      expect(find.text(successMessage),
          result == true ? findsOneWidget : findsNothing);
      expect(newsBloc.events, 1);
      expect(news.calls, 1);
    });
  }

  for (final systemBack in [false, true]) {
    testWidgets(
        'blocks back during submission, then confirms once: system=$systemBack',
        (tester) async {
      final gate = Completer<void>();
      final publisher = ControlledPublisher((_) => gate.future);
      final cubit = PublishArticleCubit(publisher);
      await openForm(tester, cubit);
      await fillForm(tester);
      await tester.tap(submit);
      await tester.pump();
      for (final field
          in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.enabled, isFalse);
      }
      expect(
          tester
              .widget<ElevatedButton>(
                  find.byKey(const Key('publishArticleAttachImageButton')))
              .onPressed,
          isNull);
      expect(
          tester
              .widget<TextButton>(
                  find.byKey(const Key('publishArticleRemoveImageButton')))
              .onPressed,
          isNull);
      if (systemBack) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.byKey(const Key('publishArticleBackButton')));
      }
      await pumpTransitions(tester);
      expect(observer.pops, 0);
      expect(find.byType(PublishArticlePage), findsOneWidget);
      expect(find.text('Publication is in progress. Please wait.'),
          findsOneWidget);
      expect(cubit.state.isSubmitting, isTrue);
      expect(publisher.calls, 1);
      gate.complete();
      await pumpTransitions(tester);
      expect(observer.pops, 1);
      expect(find.byType(PublishArticlePage), findsNothing);
      expect(find.text(successMessage), findsOneWidget);
      expect(publisher.calls, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failure unlocks fields and system back', (tester) async {
    final gate = Completer<void>();
    final cubit = PublishArticleCubit(ControlledPublisher((_) => gate.future));
    await openForm(tester, cubit);
    await fillForm(tester);
    await tester.tap(submit);
    await tester.pump();
    gate.completeError(StateError('Controlled failure'));
    await pumpTransitions(tester);
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isTrue);
    }
    final title = find.byKey(const Key('publishArticleTitleField'));
    await tester.ensureVisible(title);
    await tester.enterText(title, 'Edited after failure');
    expect(cubit.state.title, 'Edited after failure');
    await tester.binding.handlePopRoute();
    await pumpTransitions(tester);
    expect(observer.pops, 1);
    expect(find.byType(PublishArticlePage), findsNothing);
    expect(find.text(successMessage), findsNothing);
  });
  testWidgets('Home ignores success when its context was unmounted',
      (tester) async {
    final showHome = ValueNotifier(true);
    addTearDown(showHome.dispose);
    await openForm(
        tester,
        PublishArticleCubit(
            PublishArticleUseCase(FakePublishArticleRepository())),
        home: ValueListenableBuilder<bool>(
          valueListenable: showHome,
          builder: (_, visible, __) => visible
              ? const DailyNews()
              : const Scaffold(body: Text('Home removed')),
        ));
    showHome.value = false;
    await tester.pump();
    navigator.currentState!.pop(true);
    await pumpTransitions(tester);
    expect(find.text('Home removed'), findsOneWidget);
    expect(find.text(successMessage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
