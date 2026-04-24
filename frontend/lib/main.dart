import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
=======
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
>>>>>>> fbce432 (Finish PR (project setup))
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
<<<<<<< HEAD
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  runApp(const MyApp());
=======
import 'firebase_options.dart';
import 'injection_container.dart';

const bool _useEmulator =
    bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show spinner immediately — proves Flutter/Dart is alive before Firebase init.
  runApp(const MaterialApp(
    home: Scaffold(body: Center(child: CircularProgressIndicator())),
  ));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (_useEmulator) await _connectToEmulators();
    await _ensureAuthenticated();
    await initializeDependencies();
    runApp(const MyApp());
  } catch (e, st) {
    runApp(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text('Init error:\n$e\n\n$st',
              style: const TextStyle(color: Colors.red)),
        ),
      ),
    ));
  }
}

Future<void> _ensureAuthenticated() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    // Auth failure is non-fatal: reads still work; uploads will be
    // rejected by Firestore rules until the user authenticates.
    debugPrint('[Auth] sign-in skipped: $e');
  }
}

Future<void> _connectToEmulators() async {
  final host = _resolveEmulatorHost();
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
}

String _resolveEmulatorHost() {
  if (kIsWeb) return 'localhost';
  if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
  return 'localhost';
>>>>>>> fbce432 (Finish PR (project setup))
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (context) => sl()..add(const GetArticles()),
      child: MaterialApp(
<<<<<<< HEAD
          debugShowCheckedModeBanner: false,
          theme: theme(),
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          home: const DailyNews()),
    );
  }
}
=======
        debugShowCheckedModeBanner: false,
        theme: theme(),
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const DailyNews(),
      ),
    );
  }
}
>>>>>>> fbce432 (Finish PR (project setup))
