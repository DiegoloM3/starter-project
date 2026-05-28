import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthAuthenticated,
      listener: (context, state) {
        context
            .read<PublishedArticlesBloc>()
            .add(const PublishedArticlesSubscriptionRequested());
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const DailyNews();
        }
        if (state is AuthUnauthenticated || state is AuthFailure) {
          return const LoginPage();
        }
        return const Scaffold(
          body: Center(child: CupertinoActivityIndicator()),
        );
      },
    );
  }
}
