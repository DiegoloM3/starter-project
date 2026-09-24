import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/sign_up.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/update_display_name.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/screens/account/account_screen.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_journalist_stats.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_articles_byline.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_byline/article_byline_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_cubit.dart';

import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_auth_repository.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeAuthRepository authRepository;
  late FakeJournalistArticleRepository articleRepository;
  late SessionCubit session;
  late JournalistStatsCubit stats;
  late ArticleBylineCubit byline;

  setUp(() {
    authRepository = FakeAuthRepository();
    articleRepository = FakeJournalistArticleRepository();
  });

  tearDown(() async {
    await session.close();
    await stats.close();
    await byline.close();
  });

  // Built inside the test body, not in setUp: a cubit created in setUp runs
  // against the real clock and never advances under `tester.pump()`.
  Future<void> pumpScreen(WidgetTester tester, {required bool signedIn}) async {
    session = SessionCubit(
      GetCurrentUserUseCase(authRepository),
      SignUpUseCase(authRepository),
      SignInUseCase(authRepository),
      SignOutUseCase(authRepository),
      UpdateDisplayNameUseCase(authRepository),
    );
    stats = JournalistStatsCubit(GetJournalistStatsUseCase(articleRepository));
    byline = ArticleBylineCubit(UpdateArticlesBylineUseCase(articleRepository));

    if (signedIn) {
      authRepository.currentUserResult =
          const DataSuccess(FakeAuthRepository.anyUser);
    }
    await session.loadSession();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SessionCubit>.value(value: session),
            BlocProvider<JournalistStatsCubit>.value(value: stats),
            BlocProvider<ArticleBylineCubit>.value(value: byline),
          ],
          child: const AccountScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('invites a reader with no account, without demanding one',
      (tester) async {
    await pumpScreen(tester, signedIn: false);

    expect(find.text('Write your own stories'), findsOneWidget);
    expect(find.textContaining('Reading is always free'), findsOneWidget);
    expect(
        find.widgetWithText(FilledButton, 'Create an account'), findsOneWidget);
  });

  testWidgets('shows who is signed in', (tester) async {
    await pumpScreen(tester, signedIn: true);

    // The name appears twice on purpose: as the heading, and as the current
    // value of the row that changes it.
    expect(find.text('Alex Rivera'), findsWidgets);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('My articles'), findsOneWidget);
    expect(find.text('Name readers see'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sign out'), findsOneWidget);
  });

  testWidgets('the byline can be changed after signing up', (tester) async {
    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'A. Rivera');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(authRepository.updateDisplayNameCallCount, 1);
    expect(authRepository.lastDisplayName, 'A. Rivera');
    expect(find.text('A. Rivera'), findsWidgets);
  });

  /// The byline is copied onto each article as it is saved, so renaming the
  /// account used to apply only to the next one: everything already
  /// published kept the name it was written under, and nothing on the screen
  /// admitted it.
  testWidgets('a new name reaches the articles already published',
      (tester) async {
    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'A. Rivera');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(articleRepository.updateAuthorNameCallCount, 1);
    expect(articleRepository.lastRenamedUserId, FakeAuthRepository.anyUser.id);
    expect(articleRepository.lastAuthorName, 'A. Rivera');
  });

  /// Renaming reaches back over work that is already public, which a dialog
  /// asking only for a name does not suggest.
  testWidgets('says what the rename did to the published work', (tester) async {
    articleRepository.updateAuthorNameResult = const DataSuccess(3);

    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'A. Rivera');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.textContaining('3 published articles now carry the new name'),
      findsOneWidget,
    );
  });

  /// Somebody who has not published yet does not need to be told that
  /// nothing was republished.
  testWidgets('stays quiet when there was nothing to rename', (tester) async {
    articleRepository.updateAuthorNameResult = const DataSuccess(0);

    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'A. Rivera');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertBanner), findsNothing);
  });

  /// A name the account itself refused must not be written onto the
  /// catalogue: that would leave the articles signed with something the
  /// person is not called.
  testWidgets('a rejected name never reaches the articles', (tester) async {
    authRepository.updateDisplayNameResult = const DataFailed(
      CredentialsValidationException(
        [CredentialsValidationError.displayNameInvalid],
      ),
    );

    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(articleRepository.updateAuthorNameCallCount, 0);
  });

  /// It used to be a snack bar: four seconds at the bottom of the screen,
  /// well away from the row that had just been rejected.
  testWidgets('a rejected name is said here, and stays said', (tester) async {
    authRepository.updateDisplayNameResult = const DataFailed(
      CredentialsValidationException(
        [CredentialsValidationError.displayNameInvalid],
      ),
    );

    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertBanner), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // Long after a snack bar would have taken itself back.
    await tester.pump(const Duration(seconds: 10));
    expect(find.byType(AlertBanner), findsOneWidget);
  });

  /// The chevron marks the right edge of the row, and the value belongs
  /// against it.
  ///
  /// Making both the label and the value flexible split the free space
  /// between them by flex factor, so a short value took less than its share
  /// and the leftover was left at the *end* of the row — pushing the value and
  /// the chevron visibly away from the edge.
  testWidgets('a row value sits against the right edge', (tester) async {
    articleRepository.userArticlesResult = DataSuccess([
      publishableArticle(id: 'a-1'),
      publishableArticle(id: 'a-2'),
    ]);

    await pumpScreen(tester, signedIn: true);
    await tester.pump(const Duration(milliseconds: 50));

    for (final label in ['My articles', 'Name readers see']) {
      final row = find.ancestor(
        of: find.text(label),
        matching: find.byType(Row),
      );
      final chevron = find.descendant(
        of: row,
        matching: find.byIcon(Icons.chevron_right),
      );

      // The chevron is the last thing in the row, so nothing should sit
      // between its right edge and the row's.
      expect(
        tester.getBottomRight(chevron).dx,
        moreOrLessEquals(tester.getBottomRight(row.first).dx, epsilon: 1),
        reason: 'the $label row leaves a gap after the chevron',
      );
    }
  });

  /// 50 characters is a name the rules allow, and this is a phone.
  testWidgets('a name at the length limit does not overflow the row',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    authRepository.currentUserResult = DataSuccess(
      FakeAuthRepository.anyUser.copyWith(
        displayName: 'Maria Alejandra Fernandez de la Torre y Quiroga',
      ),
    );

    await pumpScreen(tester, signedIn: true);

    // A RenderFlex overflow is reported as an exception by the test binding,
    // which is what the yellow-and-black stripes are in the app.
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling changes nothing', (tester) async {
    await pumpScreen(tester, signedIn: true);

    await tester.tap(find.text('Name readers see'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Someone else');
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(authRepository.updateDisplayNameCallCount, 0);
  });

  testWidgets('summarises the work once there is some', (tester) async {
    articleRepository.userArticlesResult = DataSuccess([
      publishableArticle(id: 'a-1').copyWith(viewCount: 3400),
      publishableArticle(id: 'a-2').copyWith(viewCount: 0),
    ]);

    await pumpScreen(tester, signedIn: true);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('2 articles  ·  3.4K views'), findsOneWidget);
  });

  testWidgets('says nothing rather than boasting of zero', (tester) async {
    await pumpScreen(tester, signedIn: true);
    await tester.pump(const Duration(milliseconds: 50));

    // "0 articles · 0 views" is a worse welcome than no chip at all.
    expect(find.textContaining('articles  ·'), findsNothing);
  });
}
