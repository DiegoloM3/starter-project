import 'package:news_app_clean_architecture/core/resources/data_state.dart';

/// The journalist's signature, remembered on the device between articles.
abstract class AuthorSignatureRepository {
  /// Succeeds with `null` when no article has been published from this device yet.
  Future<DataState<String?>> getSavedAuthorName();

  Future<DataState<void>> saveAuthorName(String authorName);
}
