import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Wraps [child] in a `MultiBlocProvider` with every app-wide bloc.
///
/// Keeping this out of `app.dart` gives us a single place to add cross-feature
/// providers (user_articles cubits arrive in F7) without rewriting the
/// `MaterialApp` wiring.
class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (_) => sl<RemoteArticlesBloc>()..add(const GetArticles()),
        ),
      ],
      child: child,
    );
  }
}
