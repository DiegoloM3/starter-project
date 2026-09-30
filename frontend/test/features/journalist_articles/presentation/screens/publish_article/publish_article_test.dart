import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/discard_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_thumbnail_from_gallery.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/resume_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/save_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/publish_article/publish_article.dart';

import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/accessibility.dart';

const _contentHint = 'Add article here… Use the toolbar for **bold** text and ## subtitles.';
const _contentHintInSpanish = 'Escribe aquí tu artículo… Usa la barra para texto en **negrita** y ## subtítulos.';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockPickThumbnailFromGalleryUseCase extends Mock implements PickThumbnailFromGalleryUseCase {}

class MockResumeDraftUseCase extends Mock implements ResumeDraftUseCase {}

class MockSaveDraftUseCase extends Mock implements SaveDraftUseCase {}

class MockDiscardDraftUseCase extends Mock implements DiscardDraftUseCase {}

void main() {
  late MockPublishArticleUseCase publishArticle;
  late MockPickThumbnailFromGalleryUseCase pickThumbnail;
  late MockResumeDraftUseCase resumeDraft;
  late MockSaveDraftUseCase saveDraft;
  late MockDiscardDraftUseCase discardDraft;

  setUpAll(() => registerFallbackValue(const ArticleDraftEntity()));

  void givenDraftToResume(ArticleDraftEntity draft) {
    when(() => resumeDraft()).thenAnswer((_) async => DataSuccess(draft));
  }

  setUp(() {
    publishArticle = MockPublishArticleUseCase();
    pickThumbnail = MockPickThumbnailFromGalleryUseCase();
    resumeDraft = MockResumeDraftUseCase();
    saveDraft = MockSaveDraftUseCase();
    discardDraft = MockDiscardDraftUseCase();
    givenDraftToResume(const ArticleDraftEntity());
    when(() => saveDraft(params: any(named: 'params'))).thenAnswer((_) async => const DataSuccess(null));
    when(() => discardDraft()).thenAnswer((_) async => const DataSuccess(null));
    when(() => pickThumbnail()).thenAnswer(
      (_) async => const DataSuccess(ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024)),
    );
  });

  /// Opens the publish form from a home screen and returns what the form popped with.
  Future<Future<Object?>> openPublishForm(WidgetTester tester, {Locale locale = const Locale('en')}) async {
    // A phone-sized surface, so the whole form is built without scrolling.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late Future<Object?> result;
    await tester.pumpWidget(localizedApp(
      locale: locale,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => result = Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => PublishArticleCubit(publishArticle, pickThumbnail, resumeDraft, saveDraft, discardDraft)
                  ..resumeDraft(),
                child: const PublishArticleForm(),
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  Future<void> fillInTheForm(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Breaking News!');
    await tester.enterText(find.widgetWithText(TextField, 'Written by'), 'Daily News Staff');
    await tester.enterText(find.widgetWithText(TextField, _contentHint), 'This is **breaking** news.');
    await tester.tap(find.text('Attach Image'));
    await tester.pumpAndSettle();
  }

  Future<void> tapPublish(WidgetTester tester) async {
    await tester.tap(find.text('Publish Article').last);
    await tester.pump();
  }

  testWidgets('publishing an empty article shows what is missing in every field', (tester) async {
    await openPublishForm(tester);

    await tapPublish(tester);
    await tester.pumpAndSettle();

    expect(find.text('Add a title for your article.'), findsOneWidget);
    expect(find.text('Sign the article with your name.'), findsOneWidget);
    expect(find.text('Attach an image to illustrate your article.'), findsOneWidget);
    expect(find.text('Write your article before publishing it.'), findsOneWidget);
    verifyNever(() => publishArticle(params: any(named: 'params')));
  });

  testWidgets('prefills the signature of the previous article', (tester) async {
    givenDraftToResume(const ArticleDraftEntity(author: 'Daily News Staff'));

    await openPublishForm(tester);

    expect(find.widgetWithText(TextField, 'Daily News Staff'), findsOneWidget);
  });

  testWidgets('the title counter counts an emoji as 2, like the backend', (tester) async {
    await openPublishForm(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Hi 😀');
    await tester.pump();

    expect(find.text('5/100'), findsOneWidget);
  });

  testWidgets('attaching an image shows it instead of the button', (tester) async {
    await openPublishForm(tester);

    await tester.tap(find.text('Attach Image'));
    await tester.pumpAndSettle();

    expect(find.text('Change image'), findsOneWidget);
    expect(find.text('Attach Image'), findsNothing);
  });

  testWidgets('shows progress and blocks the button while publishing', (tester) async {
    final pendingPublish = Completer<DataState<void>>();
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) => pendingPublish.future);
    await openPublishForm(tester);
    await fillInTheForm(tester);

    await tapPublish(tester);

    expect(find.text('Publishing…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Publishing…'));
    verify(() => publishArticle(params: any(named: 'params'))).called(1);
    pendingPublish.complete(const DataSuccess(null));
    await tester.pumpAndSettle();
  });

  testWidgets('goes back to the home screen with a success result once published', (tester) async {
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) async => const DataSuccess(null));
    final result = await openPublishForm(tester);
    await fillInTheForm(tester);

    await tapPublish(tester);
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(find.byType(PublishArticleForm), findsNothing);
  });

  testWidgets('offers to retry when publishing fails', (tester) async {
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) async => DataFailed(Exception('offline')));
    await openPublishForm(tester);
    await fillInTheForm(tester);

    await tapPublish(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('could not be published'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  Future<void> leaveHalfWrittenArticle(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Draft');
    await tester.pump();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
  }

  testWidgets('restores the article left unfinished', (tester) async {
    givenDraftToResume(const ArticleDraftEntity(title: 'Half written', content: 'The story so far', author: 'Local Desk'));

    await openPublishForm(tester);

    expect(find.widgetWithText(TextField, 'Half written'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'The story so far'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Local Desk'), findsOneWidget);
    expect(find.textContaining('restored the article'), findsOneWidget);
  });

  testWidgets('starting over empties the form but keeps the signature', (tester) async {
    givenDraftToResume(const ArticleDraftEntity(title: 'Half written', content: 'The story so far', author: 'Local Desk'));
    await openPublishForm(tester);

    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();

    verify(() => discardDraft()).called(1);
    expect(find.text('Half written'), findsNothing);
    expect(find.text('The story so far'), findsNothing);
    expect(find.widgetWithText(TextField, 'Local Desk'), findsOneWidget);
  });

  testWidgets('does not show the restored message for a new article', (tester) async {
    await openPublishForm(tester);

    expect(find.textContaining('restored the article'), findsNothing);
  });

  testWidgets('asks what to do with a half-written article when leaving', (tester) async {
    await openPublishForm(tester);

    await leaveHalfWrittenArticle(tester);

    expect(find.text('Save this article as a draft?'), findsOneWidget);
    expect(find.text('Keep writing'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Save draft'), findsOneWidget);
  });

  testWidgets('saving the draft leaves the form with the draft saved', (tester) async {
    await openPublishForm(tester);
    await leaveHalfWrittenArticle(tester);

    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();

    expect(find.byType(PublishArticleForm), findsNothing);
    verify(() => saveDraft(params: const ArticleDraftEntity(title: 'Draft'))).called(1);
    verifyNever(() => discardDraft());
  });

  testWidgets('discarding leaves the form and deletes the draft', (tester) async {
    await openPublishForm(tester);
    await leaveHalfWrittenArticle(tester);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.byType(PublishArticleForm), findsNothing);
    verify(() => discardDraft()).called(1);
    verifyNever(() => saveDraft(params: any(named: 'params')));
  });

  testWidgets('keep writing stays in the form', (tester) async {
    await openPublishForm(tester);
    await leaveHalfWrittenArticle(tester);

    await tester.tap(find.text('Keep writing'));
    await tester.pumpAndSettle();

    expect(find.byType(PublishArticleForm), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Draft'), findsOneWidget);
  });

  testWidgets('speaks Spanish on a phone in Spanish', (tester) async {
    await openPublishForm(tester, locale: const Locale('es'));

    await tester.tap(find.text('Publicar artículo').last);
    await tester.pumpAndSettle();

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Escrito por'), findsOneWidget);
    expect(find.text('Adjuntar imagen'), findsOneWidget);
    expect(find.text('Añade un título a tu artículo.'), findsOneWidget);
    expect(find.text('Adjunta una imagen para ilustrar tu artículo.'), findsOneWidget);
  });

  testWidgets('shows the words and reading time while writing', (tester) async {
    await openPublishForm(tester);
    expect(find.textContaining('min read'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, _contentHint), '## Hello\n\nA **short** story.');
    await tester.pump();

    expect(find.text('4 words · 1 min read'), findsOneWidget);
  });

  testWidgets('shows the writing statistics in Spanish, with the singular', (tester) async {
    await openPublishForm(tester, locale: const Locale('es'));

    await tester.enterText(find.widgetWithText(TextField, _contentHintInSpanish), 'Hola');
    await tester.pump();

    expect(find.text('1 palabra · 1 min de lectura'), findsOneWidget);
  });

  group('accessibility', () {
    Widget form() {
      return BlocProvider(
        create: (_) => PublishArticleCubit(publishArticle, pickThumbnail, resumeDraft, saveDraft, discardDraft)
          ..resumeDraft(),
        child: const PublishArticleForm(),
      );
    }

    testWidgets('meets the guidelines', (tester) async {
      await showInEveryAppearance(tester, form());

      await expectAccessible(tester);
    }, variant: appearances);

    testWidgets('meets the guidelines while showing every field error', (tester) async {
      await showInEveryAppearance(tester, form());
      await tester.tap(find.byIcon(Icons.login)); // Publish Article
      await pumpFrames(tester);

      await expectAccessible(tester);
    }, variant: appearances);

    testWidgets('fits with the text at 200 %', (tester) async {
      await showInEveryAppearance(tester, form(), textScale: 2);

      expect(tester.takeException(), isNull);
    }, variant: appearances);
  });
}
