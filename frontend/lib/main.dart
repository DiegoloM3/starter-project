import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'firebase_options.dart';
import 'config/theme/app_themes.dart';
import 'config/theme/theme_cubit.dart';
import 'config/theme/theme_state.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/user_articles/presentation/bloc/user_articles/user_articles_bloc.dart';
import 'injection_container.dart';
import 'core/config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Debug: Print environment configuration status
  if (kDebugMode) {
    print('=== Environment Configuration ===');
    print(
        'NEWS_API_KEY: ${EnvConfig.newsApiKey.isNotEmpty ? "✓ Loaded (${EnvConfig.newsApiKey.substring(0, 8)}...)" : "✗ NOT SET"}');
    print(
        'CLOUDINARY_CLOUD_NAME: ${EnvConfig.cloudinaryCloudName.isNotEmpty ? "✓ Loaded" : "✗ NOT SET"}');
    print(
        'CLOUDINARY_UPLOAD_PRESET: ${EnvConfig.cloudinaryUploadPreset.isNotEmpty ? "✓ Loaded" : "✗ NOT SET"}');
    print('================================');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check - fail gracefully in development if network unavailable
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    if (kDebugMode) {
      print('App Check initialization failed (continuing anyway): $e');
    }
  }

  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => sl<ThemeCubit>()..init(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        BlocProvider<RemoteArticlesBloc>(
          create: (context) =>
              sl<RemoteArticlesBloc>()..add(const GetArticles()),
        ),
        BlocProvider<UserArticlesBloc>(
          create: (context) => sl<UserArticlesBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: themeState.materialThemeMode,
            onGenerateRoute: AppRoutes.onGenerateRoutes,
          );
        },
      ),
    );
  }
}
