import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/repository/author_signature_repository.dart';
import '../data_sources/local/author_signature_local_data_source.dart';

class AuthorSignatureRepositoryImpl implements AuthorSignatureRepository {
  final AuthorSignatureLocalDataSource _authorSignatureLocalDataSource;

  AuthorSignatureRepositoryImpl(this._authorSignatureLocalDataSource);

  @override
  Future<DataState<String?>> getSavedAuthorName() async {
    return DataSuccess(_authorSignatureLocalDataSource.readAuthorName());
  }

  @override
  Future<DataState<void>> saveAuthorName(String authorName) async {
    try {
      await _authorSignatureLocalDataSource.writeAuthorName(authorName);
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
