import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/app.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

import 'helpers/feed_harness.dart';
import 'helpers/fixtures.dart';
import 'helpers/pump_app.dart';

void main() {
  late ShellHarness shell;
  late SessionHarness session;
  late SettingsHarness settings;

  void createHarnesses() {
    shell = ShellHarness();
    session = shell.session;
    settings = shell.settings;
    session.signOutUser();
  }

  Future<void> pumpDailyNews(WidgetTester tester) async {
    await tester.pumpWidget(
      DailyNewsApp(
        sessionCubit: session.cubit,
        settingsCubit: settings.cubit,
        savedArticlesCubit: shell.savedCubit,
        feedCubit: shell.feedCubit,
        myArticlesCubit: shell.myArticlesCubit,
        briefCubit: shell.briefCubit,
        listenCubit: shell.listenCubit,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('follows the session: welcome, then home, then welcome again', (tester) async {
    createHarnesses();
    await pumpDailyNews(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    session.signIn(user);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    session.signOutUser();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('applies the stored theme mode and text size', (tester) async {
    createHarnesses();
    await pumpDailyNews(tester);

    settings.settings.add(const AppSettings(
      themeMode: AppThemeMode.dark,
      textSize: TextSizePreference.extraLarge,
    ));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(WelcomeScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      MediaQuery.textScalerOf(context).scale(17),
      closeTo(21, 0.01),
    );
  });

  testWidgets('signing out leaves no bookmarks or own articles for the next account', (tester) async {
    createHarnesses();
    await pumpDailyNews(tester);
    session.signIn(user);
    await tester.pump();
    await tester.pumpAndSettle();
    await shell.savedCubit.save(buildArticle());
    shell.myArticlesCubit.upsert(buildUserArticle(authorId: user.id));
    shell.briefCubit.finish(DateTime.now());
    expect(shell.savedCubit.state.articles, isNotEmpty);
    expect(shell.myArticlesCubit.state.articles, isNotEmpty);

    session.signOutUser();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(shell.savedCubit.state, const SavedArticlesState());
    expect(shell.myArticlesCubit.state, const MyArticlesState());
    expect(shell.briefCubit.state, const BriefState());
  });
}
