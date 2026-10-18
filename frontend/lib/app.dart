import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'config/routes/routes.dart';
import 'config/theme/app_themes.dart';
import 'features/articles/presentation/bloc/articles/articles_cubit.dart';
import 'features/articles/presentation/bloc/saved_articles/saved_articles_cubit.dart';
import 'features/articles/presentation/screens/home/home_screen.dart';
import 'features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth/auth_state.dart';
import 'features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import 'features/auth/presentation/screens/sign_in/sign_in_screen.dart';
import 'features/auth/presentation/screens/splash/splash_screen.dart';
import 'features/settings/domain/entities/appearance.dart';
import 'features/settings/presentation/bloc/appearance/appearance_cubit.dart';
import 'injection_container.dart';

/// [appearanceCubit] arrives already loaded, so the first frame uses the saved appearance.
class SymmetryNewsApp extends StatelessWidget {
  final AppearanceCubit appearanceCubit;

  const SymmetryNewsApp({super.key, required this.appearanceCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: appearanceCubit), BlocProvider(create: (_) => sl<AuthCubit>())],
      child: BlocBuilder<AppearanceCubit, Appearance>(builder: (_, appearance) => _buildApp(appearance)),
    );
  }

  Widget _buildApp(Appearance appearance) {
    return MaterialApp(
      title: 'Symmetry News',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: appearance == Appearance.dark ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      onGenerateRoute: AppRoutes.onGenerateRoutes,
      builder: (_, navigator) => _SessionScope(child: navigator!),
      home: const _AuthGate(),
    );
  }
}

/// Provides the cubits that belong to the signed in user to every screen. They are created
/// again when the user changes, so the data of one session never shows up in the next one.
/// They are lazy: they load their data the first time a screen of the signed in user reads them.
class _SessionScope extends StatelessWidget {
  final Widget child;

  const _SessionScope({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => _userIdOf(previous) != _userIdOf(current),
      builder:
          (context, state) => MultiBlocProvider(
            key: ValueKey(_userIdOf(state)),
            providers: [
              BlocProvider(create: (_) => sl<ArticlesCubit>()..load()),
              BlocProvider(create: (_) => sl<SavedArticlesCubit>()..load()),
            ],
            child: child,
          ),
    );
  }

  String? _userIdOf(AuthState state) => state is AuthAuthenticated ? state.user.uid : null;
}

/// Shows the screen that matches the session and closes the open screens when it changes.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, _) => Navigator.of(context).popUntil((route) => route.isFirst),
      builder:
          (context, state) => switch (state) {
            AuthUnknown() => const SplashScreen(),
            AuthUnauthenticated() => BlocProvider(create: (_) => sl<AuthFormCubit>(), child: const SignInScreen()),
            AuthAuthenticated(:final user) => HomeScreen(key: ValueKey(user.uid), user: user),
          },
    );
  }
}
