import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/articles_upload/di/articles_upload_module.dart';
import 'package:news_app_clean_architecture/features/daily_news/di/daily_news_module.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await registerDailyNewsModule(sl);
  await registerArticlesUploadModule(sl);
}
