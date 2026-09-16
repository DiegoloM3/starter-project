import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_up/sign_up_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/brief_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_shell_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/my_articles_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/publish_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/reader_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/default_category_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/navigation/glass_nav_bar.dart';

import '../../helpers/feed_harness.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';

void main() {
  final article = buildArticle(imageUrl: null, title: 'Lead story');

  Future<(ShellHarness, GoRouter)> pumpRouter(WidgetTester tester) async {
    final harness = ShellHarness(feed: FeedEntity(articles: [article]));
    sl.registerFactory<SignInCubit>(
      () => SignInCubit(MockSignInWithEmailUseCase(), MockSignInWithGoogleUseCase()),
    );
    sl.registerFactory<SignUpCubit>(
      () => SignUpCubit(MockSignUpWithEmailUseCase(), MockSignInWithGoogleUseCase()),
    );
    sl.registerFactoryParam<EditProfileCubit, UserEntity, void>(
      (u, _) => EditProfileCubit(MockUpdateProfileUseCase(), harness.pickImage, user: u),
    );
    addTearDown(() {
      sl.unregister<SignInCubit>();
      sl.unregister<SignUpCubit>();
      sl.unregister<EditProfileCubit>();
    });
    useScreen(tester, const Size(600, 1400));

    final router = AppRouter.build(harness.session.cubit);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: harness.providers,
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    );
    return (harness, router);
  }

  Future<void> pushAndExpect(WidgetTester tester, GoRouter router, String location, Type screen,
      {Object? extra}) async {
    router.push(location, extra: extra);
    await tester.pumpAndSettle();
    expect(find.byType(screen), findsOneWidget, reason: '$location should open $screen');
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(screen), findsNothing);
  }

  testWidgets('lands on Home once the session is known, every route opens its screen, and sign-out leads to Welcome',
      (tester) async {
    final (harness, router) = await pumpRouter(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeShellScreen), findsOneWidget);
    expect(find.text('Lead story'), findsOneWidget);

    await pushAndExpect(tester, router, AppRoutes.reader, ReaderScreen, extra: article);
    await pushAndExpect(tester, router, AppRoutes.brief, BriefScreen);
    await pushAndExpect(tester, router, AppRoutes.publish, PublishScreen);
    await pushAndExpect(tester, router, AppRoutes.myArticles, MyArticlesScreen);
    await pushAndExpect(tester, router, AppRoutes.editProfile, EditProfileScreen);
    await pushAndExpect(tester, router, AppRoutes.settings, SettingsScreen);
    await pushAndExpect(tester, router, AppRoutes.settingsCategory, DefaultCategoryScreen);

    // The reader needs an article: without one it goes back to Home.
    router.push(AppRoutes.reader);
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsNothing);
    expect(find.byType(HomeShellScreen), findsOneWidget);

    // "?tab=" selects a tab of the shell that is already on screen.
    router.go('${AppRoutes.home}?tab=2');
    await tester.pumpAndSettle();
    expect(tester.widget<GlassNavBar>(find.byType(GlassNavBar)).selectedIndex, 2);

    harness.session.signOutUser();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);

    router.go(AppRoutes.signIn);
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);

    router.go(AppRoutes.signUp);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
