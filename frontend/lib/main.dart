import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'config/locale/locale_cubit.dart';
import 'config/navigation/main_shell.dart';
import 'config/theme/app_themes.dart';
import 'config/theme/theme_cubit.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'shared/account/presentation/bloc/account_cubit.dart';
import 'shared/account/presentation/screens/welcome_screen.dart';
import 'shared/connectivity/presentation/bloc/connectivity_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before anything that could need newsAPIKey (constants.dart). Missing
  // .env isn't fatal here -- News just won't load until one's added,
  // rather than the whole app failing to start.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Anonymous Auth: every install gets a stable, unforgeable UID so
  // firestore.rules can enforce real ownership of user_articles without a
  // login screen. See backend/docs/DB_SCHEMA.md for the full reasoning.
  // No saved user means a fresh install (or cleared app data): the one
  // moment to offer signing in before the app starts as a guest.
  final isFirstLaunch = FirebaseAuth.instance.currentUser == null;
  if (isFirstLaunch) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  await initializeDependencies();

  runApp(MyApp(showWelcome: isFirstLaunch));
}

class MyApp extends StatelessWidget {
  final bool showWelcome;

  const MyApp({super.key, this.showWelcome = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
        // App-wide (not one per screen) so saving/removing an article from
        // the detail screen is instantly reflected in the Saved tab and
        // vice versa -- they're the same bloc instance, not two independent
        // ones each reading their own stale snapshot.
        BlocProvider<LocalArticleBloc>(
          create: (context) => sl()..add(const GetSavedArticles()),
        ),
        // App-wide, above the Navigator, so every screen's AppBar can offer
        // the same light/dark toggle and see the same current mode.
        BlocProvider<ThemeCubit>(create: (_) => sl()),
        BlocProvider<LocaleCubit>(create: (_) => sl()),
        // App-wide too: the one live OS subscription started at launch, so
        // a connection dropping is noticed no matter which screen is open.
        BlocProvider<ConnectivityCubit>(create: (_) => sl()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          // DateFormat's default, so every date on screen follows the
          // chosen language without each screen passing it along.
          Intl.defaultLocale = locale.languageCode;
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme(),
              darkTheme: darkTheme(),
              themeMode: mode,
              locale: locale,
              supportedLocales: LocaleCubit.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              onGenerateRoute: AppRoutes.onGenerateRoutes,
              home: showWelcome ? _buildWelcome() : const MainShell(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcome() {
    return BlocProvider<AccountCubit>(
      create: (_) => sl(),
      child: WelcomeScreen(
        onDone: (context) => Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (_) => const MainShell()),
        ),
      ),
    );
  }
}
