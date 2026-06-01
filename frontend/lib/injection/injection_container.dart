import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_injection.dart';
import 'articles_injection.dart';
import 'tortu_feed_injection.dart';
import 'bookmarks_injection.dart';
import 'categories_injection.dart';
import 'explore_injection.dart';
import 'profile_injection.dart';
import 'search_injection.dart';
import 'user_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Firebase (base de todo, se registra primero) ──────────────
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  sl.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );
  sl.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );
  // google_sign_in 7.x: serverClientId = Web OAuth client ID de Firebase
  // (type 3 en google-services.json) — necesario para obtener idToken en Android
  await GoogleSignIn.instance.initialize(
    serverClientId: '560559933172-ue4ejk15ld7v5bvv76452ccp37hqtvbv.apps.googleusercontent.com',
  );
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // ── Features (cada uno se registra solo) ──────────────────────
  initAuthDependencies();       // auth no depende de otros features
  initUserDependencies();       // user depende de Firebase
  initCategoriesDependencies(); // categories depende de Firebase
  initTortuFeedDependencies();  // tortu_feed depende de Firebase — antes de articles
  initArticlesDependencies();   // articles depende de Firebase + user + tortu_feed
  initProfileDependencies();    // profile depende de user + articles
  initExploreDependencies();    // explore depende de articles + categories
  initBookmarksDependencies(); // bookmarks depende de profile + articles
  initSearchDependencies();    // search depende de Firebase
}
