import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'config/theme/app_themes.dart';
import 'l10n/l10n.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(create: (context) => sl()..add(const GetArticles())),
        BlocProvider<PublishedArticlesCubit>(create: (context) => sl()..loadArticles()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          darkTheme: darkTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          home: const DailyNews()),
    );
  }
}
