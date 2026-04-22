import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Elegant Imports (Barrels)
import 'package:news_app_clean_architecture/core/core.dart';
import 'package:news_app_clean_architecture/config/config.dart';
import 'package:news_app_clean_architecture/features/auth/auth.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/daily_news_presentation.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reward/reward_cubit.dart';
import 'injection_container.dart';
import 'package:news_app_clean_architecture/core/util/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  Bloc.observer = SimpleBlocObserver();
  
  try {
    await dotenv.load(fileName: ".env");
    developer.log('Dotenv cargado correctamente', name: 'SymmetryMain');
  } catch (e) {
    developer.log('Error al cargar .env: $e', name: 'SymmetryMain', error: e);
  }

  try {
    await Firebase.initializeApp();
    developer.log('Firebase inicializado', name: 'SymmetryMain');
  } catch (e) {
    developer.log('Error al inicializar Firebase: $e', name: 'SymmetryMain', error: e);
  }

  await initializeDependencies();
  await probeBackendHealth(sl);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => sl<AuthCubit>()),
        BlocProvider<RemoteArticlesBloc>(create: (context) => sl()..add(const GetArticles())),
        BlocProvider<RewardCubit>(create: (context) => sl<RewardCubit>()),
      ],
      child: MaterialApp(
          title: 'Symmetry News',
          debugShowCheckedModeBanner: false,
          theme: theme(),
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          home: const LoginPage()),
    );
  }
}
