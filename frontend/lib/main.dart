import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/bootstrap_auth.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_articles_migration.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_bloc.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_event.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_state.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  assert(
    newsAPIKey.isNotEmpty,
    'NEWS_API_KEY is empty. Pass --dart-define=NEWS_API_KEY=<key>. '
    'See frontend/README.md for instructions.',
  );

  await initializeDependencies();

  // One-shot auth bootstrap, BEFORE runApp:
  //   - validates the locally-cached user against the server (recovers from
  //     dev workflows that wipe Firebase data),
  //   - signs in anonymously if no valid user remains.
  // Centralising this here is the canonical FlutterFire pattern; doing it
  // inside the bloc would let widget rebuilds re-trigger sign-in and create
  // duplicate anonymous users (FlutterFire #3053).
  try {
    await sl<BootstrapAuthUseCase>().call(params: const NoParams());
  } catch (e) {
    // Swallow: app still boots into AuthUnauthenticated and the user can
    // sign in via /login. Common cause: Anonymous provider disabled in
    // Firebase Console or device offline.
    debugPrint('Auth bootstrap failed: $e');
  }

  // Must run after the auth bootstrap so we have a uid to write under.
  await sl<SavedArticlesMigration>().run();

  runApp(const MyApp());
}

/// App root widget.
///
/// Owns the lifecycle of the app-wide [AuthBloc]: dispatches
/// [WatchAuthStateEvent] **once** in [initState] and reuses the same
/// [GoRouter] across rebuilds. Doing this in [build] would re-issue the
/// event on every rebuild and spawn duplicate stream subscriptions.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final LocaleBloc _localeBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _authBloc.add(WatchAuthStateEvent());
    _localeBloc = sl<LocaleBloc>()..add(const LocaleInitialized());
    _router = AppRouter.create(_authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<LocaleBloc>.value(value: _localeBloc),
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
        BlocProvider<FeedBloc>.value(value: sl<FeedBloc>()),
      ],
      // Rebuild MaterialApp when the user picks a different language so the
      // whole tree (including localized strings inside descendants) refreshes
      // without an app restart.
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          final pref = localeState.preference;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: theme(),
            routerConfig: _router,
            // null `locale` => follow device locale per Flutter convention.
            locale: pref == LocalePreference.system
                ? null
                : Locale(pref.languageCode!),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          );
        },
      ),
    );
  }
}
