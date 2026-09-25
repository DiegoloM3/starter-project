import 'package:news_app_clean_architecture/core/resources/data_state.dart';

/// Everything the current user created elsewhere in the app, which has to go
/// when their account does. Declared here and implemented by the feature
/// that owns that content (user_articles), so deleting an account can reach
/// it without shared/account importing any feature.
abstract class AccountContentRepository {
  Future<DataState<void>> deleteAllContent();
}
