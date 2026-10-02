import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/config/navigation/auth_gate.dart';
import 'package:toastification/toastification.dart';
import 'config/theme/app_themes.dart';
import 'config/theme/app_toasts.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/auth/presentation/bloc/session/session_cubit.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/presentation/bloc/theme/app_theme_mode.dart';
import 'features/settings/presentation/bloc/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  // Loaded before the first frame, so the app never flashes with the other theme.
  await sl<ThemeCubit>().loadTheme();
  // Waits for the session Firebase kept on the phone, so a signed-in journalist goes straight to the news.
  await sl<SessionCubit>().watchSession();

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
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<SessionCubit>.value(value: sl<SessionCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, AppTheme>(
        builder: (context, selectedTheme) => ToastificationConfigProvider(
          config: appToastificationConfig,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: selectedTheme.themeMode,
            onGenerateRoute: AppRoutes.onGenerateRoutes,
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
