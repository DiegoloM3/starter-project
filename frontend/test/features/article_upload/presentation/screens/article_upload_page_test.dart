import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_state.dart';
import 'dart:typed_data';

import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/screens/article_upload/article_upload_page.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockUploadArticleBloc
    extends MockBloc<UploadArticleEvent, UploadArticleState>
    implements UploadArticleBloc {}

Widget _buildPage(UploadArticleBloc bloc) {
  final router = GoRouter(
    initialLocation: '/article/upload',
    routes: [
      GoRoute(
        path: '/article/upload',
        builder: (_, __) => BlocProvider<UploadArticleBloc>.value(
          value: bloc,
          child: const ArticleUploadPage(),
        ),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  late MockUploadArticleBloc bloc;

  setUpAll(() {
    registerFallbackValue(const PublishEvent());
    registerFallbackValue(const TitleChangedEvent(''));
    registerFallbackValue(const DescriptionChangedEvent(''));
    registerFallbackValue(const ContentChangedEvent(''));
    registerFallbackValue(const SaveDraftManuallyEvent());
  });

  setUp(() {
    bloc = MockUploadArticleBloc();
    when(() => bloc.state).thenReturn(const UploadArticleState());
  });

  tearDown(() => bloc.close());

  group('ArticleUploadPage', () {
    testWidgets('shows Pick a thumbnail in initial state', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.text('Pick a thumbnail'), findsOneWidget);
    });

    testWidgets('Publish FAB is always enabled and dispatches on tap',
        (tester) async {
      when(() => bloc.state).thenReturn(const UploadArticleState());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNotNull);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      verify(() => bloc.add(const PublishEvent())).called(1);
    });

    testWidgets('Publish FAB dispatches PublishEvent when canPublish is true',
        (tester) async {
      // 1x1 transparent PNG — valid image bytes for Image.memory.
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
        0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82,
      ]);
      final validState = UploadArticleState(
        title: 'A valid title here',
        description: 'A valid description that is long enough to pass the 20 char minimum',
        content: 'A valid content body that is well over fifty characters long for testing',
        category: ArticleCategory.news,
        compressedBytes: pngBytes,
      );
      when(() => bloc.state).thenReturn(validState);

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      verify(() => bloc.add(const PublishEvent())).called(1);
    });

    testWidgets('shows SnackBar when state has an error', (tester) async {
      const error = ValidationException(
        message: 'Thumbnail is required to publish.',
        code: 'thumbnail-required',
      );
      whenListen(
        bloc,
        Stream.fromIterable([
          const UploadArticleState(),
          const UploadArticleState(error: error),
        ]),
        initialState: const UploadArticleState(),
      );

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Thumbnail'), findsOneWidget);
    });

    testWidgets('entering title fires TitleChangedEvent', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('upload_title_field')), 'My Title');
      await tester.pump();

      verify(() => bloc.add(any(that: isA<TitleChangedEvent>()))).called(greaterThan(0));
    });
  });
}
