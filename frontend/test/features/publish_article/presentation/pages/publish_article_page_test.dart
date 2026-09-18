import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/article_image_picker.dart';

import '../../support/fake_publish_article_repository.dart';

class FakeArticleImagePicker implements ArticleImagePicker {
  ArticleThumbnail? result;
  bool throwsError = false;
  int calls = 0;
  Completer<ArticleThumbnail?>? pending;

  @override
  Future<ArticleThumbnail?> pickImage() async {
    calls++;
    if (throwsError) throw StateError('Picker failed');
    if (pending != null) return pending!.future;
    return result;
  }
}

ArticleThumbnail imageThumbnail(String name) => ArticleThumbnail(
      fileName: name,
      mimeType: 'image/png',
      bytes: base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4AWMAAQAABQABDQottAAAAABJRU5ErkJggg=='),
    );

Widget buildPage(PublishArticleCubit cubit, {ArticleImagePicker? picker}) {
  return MaterialApp(
    home: BlocProvider<PublishArticleCubit>.value(
      value: cubit,
      child:
          PublishArticlePage(imagePicker: picker ?? FakeArticleImagePicker()),
    ),
  );
}

void configurePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('PublishArticlePage', () {
    testWidgets('selects, previews, replaces and removes an image',
        (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));
      addTearDown(cubit.close);
      final picker = FakeArticleImagePicker()
        ..result = imageThumbnail('first.png');
      await tester.pumpWidget(buildPage(cubit, picker: picker));
      final attach = find.byKey(const Key('publishArticleAttachImageButton'));
      final preview = find.byKey(const Key('publishArticleImagePreview'));
      await tester.tap(attach);
      await tester.pumpAndSettle();
      expect(picker.calls, 1);
      expect(cubit.state.thumbnail, same(picker.result));
      expect(find.text('first.png'), findsOneWidget);
      expect(tester.widget<Image>(preview).image, isA<MemoryImage>());
      expect((tester.widget<Image>(preview).image as MemoryImage).bytes,
          picker.result!.bytes);

      picker.result = imageThumbnail('replacement.png');
      await tester.tap(attach);
      await tester.pumpAndSettle();
      expect(picker.calls, 2);
      expect(cubit.state.thumbnail, same(picker.result));
      expect(find.text('first.png'), findsNothing);
      expect(find.text('replacement.png'), findsOneWidget);
      expect((tester.widget<Image>(preview).image as MemoryImage).bytes,
          picker.result!.bytes);

      final remove = find.byKey(const Key('publishArticleRemoveImageButton'));
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(cubit.state.thumbnail, isNull);
      expect(preview, findsNothing);
      expect(find.text('replacement.png'), findsNothing);
    });

    testWidgets('cancellation preserves the existing selection and state',
        (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()))
        ..thumbnailSelected(imageThumbnail('existing.png'));
      addTearDown(cubit.close);
      final initial = cubit.state;
      await tester.pumpWidget(buildPage(cubit));
      await tester
          .tap(find.byKey(const Key('publishArticleAttachImageButton')));
      await tester.pumpAndSettle();
      expect(cubit.state, same(initial));
      expect(find.text('existing.png'), findsOneWidget);
    });

    testWidgets(
        'picker failure shows feedback without changing publication state',
        (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()))
        ..thumbnailSelected(imageThumbnail('existing.png'));
      addTearDown(cubit.close);
      final initial = cubit.state;
      final picker = FakeArticleImagePicker()..throwsError = true;
      await tester.pumpWidget(buildPage(cubit, picker: picker));
      await tester
          .tap(find.byKey(const Key('publishArticleAttachImageButton')));
      await tester.pumpAndSettle();
      expect(find.text('Unable to select an image. Please try again.'),
          findsOneWidget);
      expect(cubit.state, same(initial));
      expect(find.text('existing.png'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'unsupported image remains selected and domain error appears below preview',
        (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));
      addTearDown(cubit.close);
      final picker = FakeArticleImagePicker()
        ..result = ArticleThumbnail(
            fileName: 'photo.gif', mimeType: 'image/gif', bytes: [1, 2, 3]);
      await tester.pumpWidget(buildPage(cubit, picker: picker));
      await tester
          .tap(find.byKey(const Key('publishArticleAttachImageButton')));
      await tester.pumpAndSettle();
      expect(cubit.state.thumbnail, same(picker.result));
      expect(find.text('Preview unavailable for this image.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('publishArticleSubmitButton')));
      await tester.pumpAndSettle();
      expect(find.text('Use JPEG, PNG or WebP.'), findsOneWidget);
      expect(
          tester
              .getTopLeft(find.byKey(const Key('publishArticleThumbnailError')))
              .dy,
          greaterThan(tester
              .getBottomLeft(
                  find.byKey(const Key('publishArticleImagePreview')))
              .dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'prevents repeated picker requests and ignores completion after disposal',
        (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));
      addTearDown(cubit.close);
      final picker = FakeArticleImagePicker()
        ..pending = Completer<ArticleThumbnail?>();
      await tester.pumpWidget(buildPage(cubit, picker: picker));
      final attach = find.byKey(const Key('publishArticleAttachImageButton'));
      await tester.tap(attach);
      await tester.pump();
      expect(tester.widget<ElevatedButton>(attach).onPressed, isNull);
      expect(picker.calls, 1);
      await tester.pumpWidget(const SizedBox());
      picker.pending!.complete(imageThumbnail('late.png'));
      await tester.pumpAndSettle();
      expect(cubit.state.thumbnail, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the publication form', (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      await tester.pumpWidget(buildPage(cubit));

      expect(
        find.byKey(const Key('publishArticleTitleField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('publishArticleAuthorField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('publishArticleDescriptionField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('publishArticleContentField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('publishArticleAttachImageButton')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('publishArticleSubmitButton')),
        findsOneWidget,
      );
      expect(find.text('Publish Article'), findsOneWidget);

      final attachButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('publishArticleAttachImageButton')),
      );
      expect(attachButton.onPressed, isNotNull);

      await cubit.close();
    });

    testWidgets('sends text field changes to the cubit', (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      await tester.pumpWidget(buildPage(cubit));

      await tester.enterText(
        find.byKey(const Key('publishArticleTitleField')),
        'Article title',
      );
      await tester.enterText(
        find.byKey(const Key('publishArticleAuthorField')),
        'Jane Doe',
      );
      await tester.enterText(
        find.byKey(const Key('publishArticleDescriptionField')),
        'Article summary',
      );

      final contentField = find.byKey(const Key('publishArticleContentField'));
      await tester.ensureVisible(contentField);
      await tester.enterText(contentField, 'Article content');

      expect(cubit.state.title, 'Article title');
      expect(cubit.state.author, 'Jane Doe');
      expect(cubit.state.description, 'Article summary');
      expect(cubit.state.content, 'Article content');

      await cubit.close();
    });

    testWidgets('shows domain validation errors after an empty submission',
        (tester) async {
      configurePhoneSize(tester);
      final cubit = PublishArticleCubit(
          PublishArticleUseCase(FakePublishArticleRepository()));

      await tester.pumpWidget(buildPage(cubit));

      await tester.tap(
        find.byKey(const Key('publishArticleSubmitButton')),
      );
      await tester.pumpAndSettle();

      expect(cubit.state.validationErrors, hasLength(7));
      expect(find.text('Required.'), findsNWidgets(4));
      expect(find.text('Image bytes are required.'), findsOneWidget);

      await cubit.close();
    });
  });

  group('PublishArticle route', () {
    setUp(() async {
      await sl.reset();
      sl.registerSingleton<ArticleImagePicker>(FakeArticleImagePicker());
      sl.registerFactory<PublishArticleCubit>(
        () => PublishArticleCubit(
            PublishArticleUseCase(FakePublishArticleRepository())),
      );
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('opens the publication page and returns with the back button',
        (tester) async {
      configurePhoneSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const Key('openPublishArticleButton'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/PublishArticle');
                    },
                    child: const Text('Open publication form'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(
        find.byKey(const Key('openPublishArticleButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PublishArticlePage), findsOneWidget);
      expect(
        find.byKey(const Key('publishArticleTitleField')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('publishArticleBackButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PublishArticlePage), findsNothing);
      expect(find.text('Open publication form'), findsOneWidget);
    });
  });
}
