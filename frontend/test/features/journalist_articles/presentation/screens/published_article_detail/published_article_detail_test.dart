import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration_progress.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/read_article_aloud.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/stop_reading_aloud.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_narration/article_narration_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/published_article_detail/published_article_detail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/follow_along_text.dart';

import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/accessibility.dart';

class MockReadArticleAloudUseCase extends Mock implements ReadArticleAloudUseCase {}

class MockStopReadingAloudUseCase extends Mock implements StopReadingAloudUseCase {}

final article = PublishedArticleEntity(
  id: 'article-1',
  title: 'Breaking News',
  content: '## Subtitle\n\nThis is **breaking** news. It happened today.',
  description: 'Subtitle This is breaking news. It happened today.',
  author: 'Daily News Staff',
  thumbnailUrl: 'https://example.com/1.jpg',
  publishedAt: DateTime.utc(2026, 9, 28),
);

void main() {
  late MockReadArticleAloudUseCase readAloud;
  late MockStopReadingAloudUseCase stopReading;
  late StreamController<DataState<ArticleNarrationProgressEntity>> reading;

  setUpAll(() => registerFallbackValue(article));

  // Created inside each test body, not in setUp: futures created outside testWidgets' fake-async
  // zone do not resolve while the test pumps frames.
  void stubReadingAloud() {
    readAloud = MockReadArticleAloudUseCase();
    stopReading = MockStopReadingAloudUseCase();
    reading = StreamController();
    when(() => readAloud(params: any(named: 'params'))).thenAnswer((_) => reading.stream);
    when(() => stopReading()).thenAnswer((_) async {
      unawaited(reading.close());
      return const DataSuccess(null);
    });
  }

  Future<void> openArticle(WidgetTester tester, {Locale locale = const Locale('en')}) async {
    stubReadingAloud();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(localizedApp(
      locale: locale,
      home: BlocProvider(
        create: (_) => ArticleNarrationCubit(readAloud, stopReading),
        child: PublishedArticleDetail(article: article),
      ),
    ));
  }

  /// The sentences shown with the read-aloud highlight.
  List<String> highlightedSentences(WidgetTester tester) {
    final highlighted = <String>[];
    for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
      text.text.visitChildren((span) {
        final isHighlighted = span.style?.backgroundColor == readAloudHighlightColor;
        if (isHighlighted && span is TextSpan) highlighted.add(span.text!);
        return true;
      });
    }
    return highlighted;
  }

  Future<void> readSentence(WidgetTester tester, int index) async {
    reading.add(DataSuccess(ArticleNarrationProgressEntity(
      narration: ArticleNarrationEntity.of(article),
      sentenceIndex: index,
    )));
    await tester.pumpAndSettle(); // content transition, scroll and progress bar animations
  }

  testWidgets('renders the Markdown content and the reading time', (tester) async {
    await openArticle(tester);

    expect(find.textContaining('Subtitle', findRichText: true), findsOneWidget);
    expect(find.textContaining('1 min read'), findsOneWidget);
  });

  testWidgets('highlights each sentence while it is read aloud', (tester) async {
    await openArticle(tester);
    await tester.tap(find.text('Listen to this article'));
    await tester.pump();

    await readSentence(tester, 0);
    expect(highlightedSentences(tester), ['Breaking News']);

    await readSentence(tester, 3);
    expect(find.byType(FollowAlongText), findsOneWidget);
    expect(highlightedSentences(tester), ['This is breaking news.']);

    await readSentence(tester, 4);
    expect(highlightedSentences(tester), ['It happened today.']);
    expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value, 1);
  });

  testWidgets('shows the Markdown content again when the reading ends', (tester) async {
    await openArticle(tester);
    await tester.tap(find.text('Listen to this article'));
    await tester.pump();
    await readSentence(tester, 3);

    await reading.close();
    await tester.pumpAndSettle();

    expect(find.byType(FollowAlongText), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(highlightedSentences(tester), isEmpty);
    expect(find.text('Listen to this article'), findsOneWidget);
  });

  testWidgets('listening turns the button into Stop, and stopping turns it back', (tester) async {
    await openArticle(tester);

    await tester.tap(find.text('Listen to this article'));
    await tester.pump();
    expect(find.text('Stop reading'), findsOneWidget);
    verify(() => readAloud(params: article)).called(1);

    await tester.tap(find.text('Stop reading'));
    await tester.pump(); // stop request
    await tester.pump(); // the reading completes and the cubit goes back to idle
    expect(find.text('Listen to this article'), findsOneWidget);
    verify(() => stopReading()).called(1);
  });

  testWidgets('explains when the device cannot read aloud', (tester) async {
    await openArticle(tester);
    reading.add(DataFailed(Exception('no engine')));
    unawaited(reading.close());

    await tester.tap(find.text('Listen to this article'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // snackbar entrance

    expect(find.textContaining('cannot read aloud'), findsOneWidget);
  });

  testWidgets('shows the date, the reading time and the buttons in Spanish', (tester) async {
    await openArticle(tester, locale: const Locale('es'));

    expect(find.textContaining('sept 2026 · 1 min de lectura'), findsOneWidget);
    expect(find.text('Escuchar este artículo'), findsOneWidget);

    await tester.tap(find.text('Escuchar este artículo'));
    await tester.pump();
    expect(find.text('Detener la lectura'), findsOneWidget);
  });

  group('accessibility', () {
    Widget articleScreen() {
      stubReadingAloud();
      return BlocProvider(
        create: (_) => ArticleNarrationCubit(readAloud, stopReading),
        child: PublishedArticleDetail(article: article),
      );
    }

    // No contrast check: the thumbnail is a network image (see expectAccessible).
    testWidgets('has usable, labeled buttons', (tester) async {
      await showInEveryAppearance(tester, articleScreen());

      await expectUsableTapTargets(tester);
    }, variant: appearances);

    testWidgets('fits with the text at 200 %', (tester) async {
      await showInEveryAppearance(tester, articleScreen(), textScale: 2);

      expect(tester.takeException(), isNull);
    }, variant: appearances);
  });
}
