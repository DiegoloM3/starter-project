import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'features/settings/presentation/bloc/appearance/appearance_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';

  final appearanceCubit = sl<AppearanceCubit>();
  await appearanceCubit.load();

  runApp(SymmetryNewsApp(appearanceCubit: appearanceCubit));
}
