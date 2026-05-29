import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/create_article/create_article_page.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

// Regression: the create-article AppBar's Preview OutlinedButton inherited the
// global OutlinedButtonTheme.minimumSize = Size(double.infinity, 52). In the
// AppBar `actions` slot (measured with unbounded width during overlay/route
// layout) that forced an infinite width, the button stayed NEEDS-LAYOUT and the
// new semantics engine asserted '!semantics.parentDataDirty' every frame. The
// page must lay out and accept typing with semantics enabled and throw nothing.
void main() {
  late MockCreateArticleUseCase mockCreate;
  late MockUpdateArticleUseCase mockUpdate;
  late MockUploadThumbnailUseCase mockUpload;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockCreate = MockCreateArticleUseCase();
    mockUpdate = MockUpdateArticleUseCase();
    mockUpload = MockUploadThumbnailUseCase();
    when(() => mockCreate(params: any(named: 'params')))
        .thenAnswer((_) async => DataSuccess(testArticle(id: 'id')));
    when(() => mockUpdate(params: any(named: 'params')))
        .thenAnswer((_) async => DataSuccess(testArticle(id: 'id')));

    if (sl.isRegistered<CreateArticleBloc>()) {
      sl.unregister<CreateArticleBloc>();
    }
    sl.registerFactory<CreateArticleBloc>(
      () => CreateArticleBloc(
        mockCreate,
        mockUpdate,
        mockUpload,
        authorId: 'uid',
        authorName: 'Tester',
      ),
    );
  });

  tearDown(() {
    if (sl.isRegistered<CreateArticleBloc>()) {
      sl.unregister<CreateArticleBloc>();
    }
  });

  testWidgets('CreateArticlePage lays out and accepts typing without throwing',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CreateArticlePage(),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'create-article screen must lay out cleanly');

    await tester.enterText(find.byType(TextFormField).first, 'fregarfasfafa');
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'typing in the title must not trip parentDataDirty');

    // Drain the autosave debounce timer (2s) so it doesn't outlive the test.
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);

    handle.dispose();
  });
}
