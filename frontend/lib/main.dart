import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/firebase_options.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initializeJournalistSession();
  await initializeDependencies();

  runApp(const MyApp());
}

Future<void> _initializeJournalistSession() async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final credential = auth.currentUser != null
      ? null
      : await auth.signInAnonymously();
  final user = auth.currentUser ?? credential?.user;

  if (user == null) {
    throw Exception('Unable to initialize authenticated journalist session');
  }

  await firestore.collection('users').doc(user.uid).set(
    <String, dynamic>{
      'displayName': 'Journalist (Dev)',
      'email': '',
      'role': 'journalist',
      'photoURL': '',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    SetOptions(merge: true),
  );
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
          home: const DailyNews()),
    );
  }
}
