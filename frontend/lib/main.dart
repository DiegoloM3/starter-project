import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/localization/app_locales.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'config/navigation/app_shell.dart';
import 'l10n/app_localizations.dart';
import 'config/theme/app_themes.dart';
import 'features/authentication/presentation/bloc/session/session_cubit.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Both guards are for the same situation: main() running a second time on
  // an engine that is still warm, which Android can do when it recreates the
  // activity. Firebase answers a second `initializeApp` with
  // `[core/duplicate-app]` and get_it answers a second registration by
  // throwing, and either one stops this function before `runApp` — leaving
  // the launch screen up with no error and nothing coming after it.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  if (!sl.isRegistered<SessionCubit>()) {
    await initializeDependencies();
  }
  // Resolved before the first frame so the account button and the route
  // guards never flash the signed out state at somebody who is signed in.
  await sl<SessionCubit>().loadSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
        BlocProvider<SessionCubit>.value(value: sl<SessionCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme(),
        darkTheme: darkTheme(),
        // Spanish on a Spanish device, English everywhere else. The rule is
        // spelled out in AppLocales rather than left to Flutter's default,
        // which reads the whole language list the device offers and so kept
        // running in Spanish on a phone that had been switched to French.
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: AppLocales.resolve,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const AppShell(),
      ),
    );
  }
}
