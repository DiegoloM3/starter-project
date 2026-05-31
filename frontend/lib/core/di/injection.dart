import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final sl = GetIt.instance;

@InjectableInit(throwOnMissingDependencies: true)
Future<void> configureDependencies() async => sl.init();
