import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/session/session_cubit.dart';
import '../../features/auth/presentation/bloc/session/session_state.dart';
import '../../features/auth/presentation/screens/welcome/welcome_screen.dart';
import '../../features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import '../../injection_container.dart';
import 'app_navigation_shell.dart';

/// Shows the app to a signed-in journalist and the welcome screen to everyone else.
/// It follows the session, so signing in, registering or logging out switches the screen by itself.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is! SessionSignedIn) return const WelcomeScreen();
        // Created for each session, because only signed-in journalists can read the articles.
        return BlocProvider<PublishedArticlesCubit>(
          create: (_) => sl()..loadArticles(),
          child: const AppNavigationShell(),
        );
      },
    );
  }
}
