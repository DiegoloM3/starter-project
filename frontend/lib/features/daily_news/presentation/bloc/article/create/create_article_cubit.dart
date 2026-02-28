import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../auth/domain/usecases/get_current_user.dart';
import '../../../../domain/entities/article.dart';
import '../../../../domain/usecases/save_article.dart';
import '../../../../domain/usecases/upload_article_image.dart';
import 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final SaveArticleUseCase _saveArticleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UploadArticleImageUseCase _uploadArticleImageUseCase;

  CreateArticleCubit(
    this._saveArticleUseCase,
    this._getCurrentUserUseCase,
    this._uploadArticleImageUseCase,
  ) : super(const CreateArticleInitial());

  Future<void> submit({
    required String title,
    String? description,
    String? content,
    String? imagePath,
  }) async {
    emit(const CreateArticleSubmitting());
    try {
      final user = await _getCurrentUserUseCase();
      if (user == null) {
        emit(const CreateArticleFailure('User not authenticated'));
        return;
      }

      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        imageUrl = await _uploadArticleImageUseCase(
          params: UploadArticleImageParams(
            authorId: user.uid,
            localPath: imagePath,
          ),
        );
      }

      final article = ArticleEntity(
        authorId: user.uid,
        author: user.displayName ?? user.email,
        title: title,
        urlToImage: imageUrl,
        description: description,
        content: content,
      );

      await _saveArticleUseCase(params: article);
      emit(const CreateArticleSuccess());
    } catch (e) {
      emit(CreateArticleFailure('Failed to save article: $e'));
    }
  }
}
