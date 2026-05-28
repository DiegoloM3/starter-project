import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/di/article_module.dart';
import 'package:news_app_clean_architecture/di/auth_module.dart';
import 'package:news_app_clean_architecture/di/comment_module.dart';
import 'package:news_app_clean_architecture/di/core_module.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await registerCoreModule(sl);
  registerAuthModule(sl);
  registerArticleModule(sl);
  registerCommentModule(sl);
}
