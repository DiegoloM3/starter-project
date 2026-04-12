import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_filter/news_filter_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_tab/news_tab_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'config/theme/app_themes.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (isTestingEnv) {
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
  }
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (_) => sl()..add(const GetArticles()),
        ),
        BlocProvider<LocalArticleBloc>(
          create: (_) => sl()..add(const GetSavedArticles()),
        ),
        BlocProvider<FirestoreArticlesBloc>(
          create: (_) => sl()..add(const GetFirestoreArticles()),
        ),
        BlocProvider<NewsTabCubit>(
          create: (_) => NewsTabCubit(),
        ),
        BlocProvider<NewsFilterCubit>(
          create: (_) => NewsFilterCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightThemeData,
        darkTheme: darkThemeData,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const DailyNews(),
      ),
    );
  }
}
