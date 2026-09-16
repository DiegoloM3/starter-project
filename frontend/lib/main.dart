// coverage:ignore-file
// Entry point: initialises Firebase and the service locator on a real device.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/app.dart';
import 'package:news_app_clean_architecture/firebase_options.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();

  runApp(DailyNewsApp(
    sessionCubit: sl(),
    settingsCubit: sl(),
    savedArticlesCubit: sl(),
    feedCubit: sl(),
    myArticlesCubit: sl(),
    briefCubit: sl(),
    listenCubit: sl(),
  ));
}
