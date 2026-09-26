import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/firebase_options.dart';
import 'config/firebase_runtime.dart';
import 'config/routes/routes.dart';
import 'config/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureFirebaseRuntime();
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
          create: (_) => sl<RemoteArticlesBloc>()..add(const GetArticles()),
        ),
        BlocProvider<CommunityFeedCubit>(
          create: (_) => sl<CommunityFeedCubit>()..load(),
        ),
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Case Study Symmetry',
        theme: theme(),
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        initialRoute: _initialRoute(),
      ),
    );
  }
}

String _initialRoute() {
  final articleId = Uri.base.queryParameters['article']?.trim();
  if (articleId == null || articleId.isEmpty) return '/';
  return '/?article=${Uri.encodeQueryComponent(articleId)}';
}
