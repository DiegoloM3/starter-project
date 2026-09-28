import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/home/presentation/pages/main_layout.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

final _log = Logger('main');

/// Bootstraps DI, Firebase, emulators, logging, then runs [MyApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up logging — prints every record to the console with level + logger name.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}: ${record.message}'
        '${record.error != null ? '\nERROR: ${record.error}' : ''}'
        '${record.stackTrace != null ? '\n${record.stackTrace}' : ''}');
  });

  await configureDependencies();

  await Firebase.initializeApp();

  // Override at build time with `--dart-define=USE_EMULATOR=false` for
  // production builds so release binaries never point at localhost.
  const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: true,
  );

  if (useEmulator) {
    await FirebaseAuth.instance
        .useAuthEmulator(kEmulatorHost, kEmulatorAuthPort);
    FirebaseFirestore.instance
        .useFirestoreEmulator(kEmulatorHost, kEmulatorFirestorePort);
    await FirebaseStorage.instance
        .useStorageEmulator(kEmulatorHost, kEmulatorStoragePort);
  }

  runApp(const MyApp());
}

/// Application root: provides global blocs and the route table.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme(),
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const MainLayout(),
      ),
    );
  }
}
