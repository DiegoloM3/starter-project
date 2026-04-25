import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/data_sources/remote/ai_image_service.dart';
import '../../../../data/data_sources/remote/firebase_storage_service.dart';
import 'remote_add_article_event.dart';
import 'remote_add_article_state.dart';

class RemoteAddArticleBloc
    extends Bloc<RemoteAddArticleEvent, RemoteAddArticleState> {
  final AIImageService _aiService;
  final FirebaseStorageService _storageService;

  RemoteAddArticleBloc(this._aiService, this._storageService)
      : super(RemoteAddArticleInitial()) {
    on<GenerateAIImageEvent>(_onGenerateImage);
  }

  Future<void> _onGenerateImage(
      GenerateAIImageEvent event, Emitter<RemoteAddArticleState> emit) async {
    emit(AIImageLoading());

    try {
      final url = await _aiService.generateImageFromContent(event.content);

      if (url != null) {
        final permanentUrl = await _storageService.uploadImageFromUrl(url);

        emit(AIImageSuccess(permanentUrl));
      } else {
        emit(const AIImageError("Failed to generate image"));
      }
    } catch (e) {
      emit(AIImageError(e.toString()));
    }
  }
}
