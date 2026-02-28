import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Keep startup resilient when .env is missing (e.g. CI or fresh clone).
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const bool useEmulators = true;
  if (useEmulators && kDebugMode) {
    final String host = _resolveHost();
    final int firestorePort =
        int.tryParse(_env('FIRESTORE_EMULATOR_PORT').isNotEmpty
                ? _env('FIRESTORE_EMULATOR_PORT')
                : '8080') ??
            8080;
    final int authPort =
        int.tryParse(_env('AUTH_EMULATOR_PORT').isNotEmpty
                ? _env('AUTH_EMULATOR_PORT')
                : '9099') ??
            9099;
    final int storagePort =
        int.tryParse(_env('STORAGE_EMULATOR_PORT').isNotEmpty
                ? _env('STORAGE_EMULATOR_PORT')
                : '9199') ??
            9199;

    FirebaseFirestore.instance.useFirestoreEmulator(host, firestorePort);
    await FirebaseAuth.instance.useAuthEmulator(host, authPort);
    await FirebaseStorage.instance.useStorageEmulator(host, storagePort);

    debugPrint('\x1B[33m[Firebase] Usando emuladores locales en $host\x1B[0m');
  }

  await initializeDependencies();
  runApp(const MyApp());
}

String _env(String key) {
  final value = dotenv.env[key];
  if (value != null && value.isNotEmpty) return value;
  return String.fromEnvironment(key);
}

String _resolveHost() {
  final authHost = _env('AUTH_EMULATOR_HOST');
  if (authHost.isNotEmpty) return authHost;

  if (kIsWeb) return 'localhost';
  return Platform.isAndroid ? '10.0.2.2' : 'localhost';
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (context) => sl()..add(const GetArticles()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme(),
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const DailyNews(),
      ),
    );
  }
}
