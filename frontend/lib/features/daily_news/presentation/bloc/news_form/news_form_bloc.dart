import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_state.dart';
import 'package:news_app_clean_architecture/core/resources/image_item.dart';

class NewsFormBloc extends Bloc<NewsFormEvent, NewsFormState> {
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final String _authorName;
  final String? _existingDescription;

  NewsFormBloc({
    required CreateArticleUseCase createArticleUseCase,
    required UpdateArticleUseCase updateArticleUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
    required String authorName,
    ArticleEntity? existingArticle,
    NewsSection? existingSection,
  })  : _createArticleUseCase = createArticleUseCase,
        _updateArticleUseCase = updateArticleUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        _authorName = authorName,
        _existingDescription = existingArticle?.description,
        super(_buildInitialState(existingArticle, existingSection)) {
    on<NewsFormTitleChanged>(_onTitleChanged);
    on<NewsFormBodyChanged>(_onBodyChanged);
    on<NewsFormSectionChanged>(_onSectionChanged);
    on<NewsFormImageAdded>(_onImageAdded);
    on<NewsFormImageRemoved>(_onImageRemoved);
    on<NewsFormSubmitted>(_onSubmitted);
    on<NewsFormDeleted>(_onDeleted);
  }

  static NewsFormState _buildInitialState(
    ArticleEntity? article,
    NewsSection? section,
  ) {
    if (article == null) return const NewsFormState();

    final images = article.images
        .map((url) => ImageItem(url: url))
        .toList();

    return NewsFormState(
      title: article.title ?? '',
      body: article.content ?? '',
      selectedSection: section ?? article.section,
      isEditing: true,
      articleId: article.documentId,
      images: images,
      originalTitle: article.title ?? '',
      originalBody: article.content ?? '',
      originalSection: section ?? article.section,
      originalImages: List.unmodifiable(images),
    );
  }

  void _onTitleChanged(
    NewsFormTitleChanged event,
    Emitter<NewsFormState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onBodyChanged(
    NewsFormBodyChanged event,
    Emitter<NewsFormState> emit,
  ) {
    emit(state.copyWith(body: event.body));
  }

  void _onSectionChanged(
    NewsFormSectionChanged event,
    Emitter<NewsFormState> emit,
  ) {
    emit(state.copyWith(selectedSection: event.section));
  }

  void _onImageAdded(
    NewsFormImageAdded event,
    Emitter<NewsFormState> emit,
  ) {
    if (!state.canAddMoreImages) return;
    final updatedImages = List<ImageItem>.from(state.images)
      ..add(ImageItem(file: event.image));
    emit(state.copyWith(images: updatedImages));
  }

  void _onImageRemoved(
    NewsFormImageRemoved event,
    Emitter<NewsFormState> emit,
  ) {
    if (event.index < 0 || event.index >= state.images.length) return;
    final updatedImages = List<ImageItem>.from(state.images)
      ..removeAt(event.index);
    emit(state.copyWith(images: updatedImages));
  }

  Future<void> _onSubmitted(
    NewsFormSubmitted event,
    Emitter<NewsFormState> emit,
  ) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final article = _buildArticleFromState();
    final newImagePaths = _extractNewImagePaths();

    final DataState result;
    if (state.isEditing) {
      result = await _updateArticleUseCase(
        params: UpdateArticleParams(
          article: article,
          newImagePaths: newImagePaths,
          existingImageUrls: _extractExistingImageUrls(),
        ),
      );
    } else {
      result = await _createArticleUseCase(
        params: CreateArticleParams(
          article: article,
          imagePaths: newImagePaths,
        ),
      );
    }

    _emitResultStatus(result, emit);
  }

  ArticleEntity _buildArticleFromState() {
    return ArticleEntity(
      documentId: state.articleId,
      title: state.title.trim(),
      description: _existingDescription,
      content: state.body.trim(),
      section: state.selectedSection,
      author: _authorName,
    );
  }

  List<String> _extractNewImagePaths() {
    return state.images
        .where((img) => img.file != null)
        .map((img) => img.file!.path)
        .toList();
  }

  List<String> _extractExistingImageUrls() {
    return state.images
        .where((img) => img.url != null && img.file == null)
        .map((img) => img.url!)
        .toList();
  }

  void _emitResultStatus(DataState result, Emitter<NewsFormState> emit) {
    if (result is DataSuccess) {
      emit(state.copyWith(status: FormStatus.success));
    } else {
      emit(state.copyWith(
        status: FormStatus.failure,
        errorType: result.failure?.type,
      ));
    }
  }

  Future<void> _onDeleted(
    NewsFormDeleted event,
    Emitter<NewsFormState> emit,
  ) async {
    if (state.articleId == null) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final result = await _deleteArticleUseCase(params: state.articleId);
    _emitResultStatus(result, emit);
  }
}
