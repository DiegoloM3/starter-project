import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:news_app_clean_architecture/config/locale/locale_provider.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/remote/auth_session.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/screens/login_screen.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/screens/onboarding_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();

  final showOnboarding = await OnboardingScreen.shouldShow();
  final isAuthenticated = sl<AuthSession>().isSignedIn;
  final localeProvider = await LocaleProvider.load();

  final Widget home;
  if (showOnboarding) {
    home = const OnboardingScreen();
  } else if (!isAuthenticated) {
    home = const LoginScreen();
  } else {
    home = const DailyNews();
  }

  runApp(MyApp(home: home, localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  final Widget home;
  final LocaleProvider localeProvider;
  const MyApp({super.key, required this.home, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: localeProvider,
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) {
          return BlocProvider<RemoteArticlesBloc>(
            create: (context) => sl()..add(const GetArticles()),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme(),
              darkTheme: darkTheme(),
              themeMode: ThemeMode.system,
              locale: locale.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              onGenerateRoute: AppRoutes.onGenerateRoutes,
              home: home,
            ),
          );
        },
      ),
    );
  }
}
