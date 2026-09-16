import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/editor_assistant/editor_assistant_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/listen/listen_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reader_lens/reader_lens_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:provider/single_child_widget.dart';

import 'fixtures.dart';
import 'in_memory_speech_repository.dart';
import 'mocks.dart';
import 'pump_app.dart';

/// Everything the Home shell needs: session, settings and the app-wide
/// cubits (saved, feed, my articles), plus a PublishCubit factory in the
/// service locator. Create it inside the test body and pass [providers] to
/// the pump helpers.

class ShellHarness {
  final SessionHarness session = SessionHarness();
  final SettingsHarness settings = SettingsHarness();
  final MockGetFeedUseCase getFeed = MockGetFeedUseCase();
  final MockGetSavedArticlesUseCase getSaved = MockGetSavedArticlesUseCase();
  final MockSaveArticleUseCase save = MockSaveArticleUseCase();
  final MockRemoveSavedArticleUseCase remove = MockRemoveSavedArticleUseCase();
  final MockGetMyArticlesUseCase getMyArticles = MockGetMyArticlesUseCase();
  final MockDeleteArticleUseCase deleteArticle = MockDeleteArticleUseCase();
  final MockPublishArticleUseCase publishArticle = MockPublishArticleUseCase();
  final MockUpdateArticleUseCase updateArticle = MockUpdateArticleUseCase();
  final MockPickImageUseCase pickImage = MockPickImageUseCase();
  final MockLoadDraftUseCase loadDraft = MockLoadDraftUseCase();
  final MockSaveDraftUseCase saveDraft = MockSaveDraftUseCase();
  final MockClearDraftUseCase clearDraft = MockClearDraftUseCase();
  late final SavedArticlesCubit savedCubit;
  late final FeedCubit feedCubit;
  final MockGetTopHeadlinesUseCase getTopHeadlines = MockGetTopHeadlinesUseCase();
  final MockSearchArticlesUseCase searchArticles = MockSearchArticlesUseCase();
  late final MyArticlesCubit myArticlesCubit;
  late final BriefCubit briefCubit;
  final MockSuggestArticleEditsUseCase suggestEdits = MockSuggestArticleEditsUseCase();
  final MockApplyArticleLensUseCase applyLens = MockApplyArticleLensUseCase();
  final InMemorySpeechRepository speech = InMemorySpeechRepository();
  late final ListenCubit listenCubit;

  ShellHarness({FeedEntity feed = FeedEntity.empty, List<ArticleEntity> myArticles = const []}) {
    registerFallbackValue(const NewsQuery());
    registerFallbackValue(buildArticle());
    registerFallbackValue(PublishArticleParams(draft: buildDraft()));
    registerFallbackValue(UpdateArticleParams(article: buildArticle(), draft: buildDraft()));
    when(() => getFeed(any())).thenAnswer((_) async => DataSuccess(feed));
    when(() => getSaved(any())).thenAnswer((_) async => const DataSuccess([]));
    when(() => save(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => remove(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => getMyArticles(any())).thenAnswer((_) async => DataSuccess(myArticles));
    when(() => deleteArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => pickImage(any())).thenAnswer((_) async => DataSuccess(buildImage()));
    when(() => loadDraft(any())).thenAnswer((_) async => null);
    when(() => saveDraft(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => clearDraft(any())).thenAnswer((_) async => const DataSuccess(null));
    savedCubit = SavedArticlesCubit(getSaved, save, remove);
    feedCubit = FeedCubit(getFeed);
    myArticlesCubit = MyArticlesCubit(getMyArticles, deleteArticle);
    when(() => getTopHeadlines(any())).thenAnswer((_) async => DataSuccess(feed.articles));
    when(() => searchArticles(any())).thenAnswer((_) async => DataSuccess(feed));
    briefCubit = BriefCubit(getTopHeadlines);
    registerFallbackValue(buildDraft());
    registerFallbackValue(ApplyArticleLensParams(lens: ArticleLens.brief, article: buildArticle()));
    when(() => suggestEdits(any())).thenAnswer((_) async => const DataSuccess(EditorSuggestions(
          headlines: ['Headline one', 'Headline two', 'Headline three'],
          summary: 'A short summary.',
        )));
    when(() => applyLens(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.single as ApplyArticleLensParams;
      return DataSuccess(params.lens == ArticleLens.brief
          ? ArticleLensResult(lens: params.lens, bullets: const ['First fact', 'Second fact', 'Third fact'])
          : ArticleLensResult(lens: params.lens, text: 'Rewritten body'));
    });
    listenCubit = ListenCubit(
      ReadAloudUseCase(speech),
      PauseReadingUseCase(speech),
      ResumeReadingUseCase(speech),
      StopReadingUseCase(speech),
      WatchReadingStatusUseCase(speech),
    );
    if (sl.isRegistered<EditorAssistantCubit>()) sl.unregister<EditorAssistantCubit>();
    sl.registerFactory<EditorAssistantCubit>(() => EditorAssistantCubit(suggestEdits));
    if (sl.isRegistered<ReaderLensCubit>()) sl.unregister<ReaderLensCubit>();
    sl.registerFactoryParam<ReaderLensCubit, ArticleEntity, void>(
      (article, _) => ReaderLensCubit(applyLens, article: article),
    );
    if (sl.isRegistered<SearchCubit>()) sl.unregister<SearchCubit>();
    sl.registerFactory<SearchCubit>(() => SearchCubit(searchArticles, debounce: Duration.zero));
    if (sl.isRegistered<PublishCubit>()) sl.unregister<PublishCubit>();
    sl.registerFactoryParam<PublishCubit, ArticleEntity?, void>(
      (original, _) => PublishCubit(
        publishArticle,
        updateArticle,
        pickImage,
        loadDraft: loadDraft,
        saveDraft: saveDraft,
        clearDraft: clearDraft,
        original: original,
        autosaveDelay: Duration.zero,
      ),
    );
    session.signIn(user);
    addTearDown(() async {
      sl.unregister<PublishCubit>();
      sl.unregister<SearchCubit>();
      sl.unregister<EditorAssistantCubit>();
      sl.unregister<ReaderLensCubit>();
      await briefCubit.close();
      await listenCubit.close();
      await speech.dispose();
      await savedCubit.close();
      await feedCubit.close();
      await myArticlesCubit.close();
      await session.dispose();
      await settings.dispose();
    });
  }

  List<SingleChildWidget> get providers => [
        BlocProvider.value(value: session.cubit),
        BlocProvider.value(value: settings.cubit),
        BlocProvider.value(value: savedCubit),
        BlocProvider.value(value: feedCubit),
        BlocProvider.value(value: myArticlesCubit),
        BlocProvider.value(value: briefCubit),
        BlocProvider.value(value: listenCubit),
      ];
}
