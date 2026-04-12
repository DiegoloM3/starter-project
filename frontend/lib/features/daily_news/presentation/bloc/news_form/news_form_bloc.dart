import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_state.dart';
import 'package:news_app_clean_architecture/core/resources/image_item.dart';

class NewsFormBloc extends Bloc<NewsFormEvent, NewsFormState> {
  NewsFormBloc({
    ArticleEntity? existingArticle,
    NewsSection? existingSection,
  }) : super(_buildInitialState(existingArticle, existingSection)) {
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

    final images = <ImageItem>[];
    if (article.urlToImage != null) {
      images.add(ImageItem(url: article.urlToImage));
    }

    return NewsFormState(
      title: article.title ?? '',
      body: article.content ?? '',
      selectedSection: section,
      isEditing: true,
      articleId: article.id?.toString(),
      images: images,
      originalTitle: article.title ?? '',
      originalBody: article.content ?? '',
      originalSection: section,
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
    // TODO: Integrate with add/edit use cases when domain layer is implemented
    emit(state.copyWith(
      status: FormStatus.failure,
      errorMessage: 'Submit not yet implemented',
    ));
  }

  Future<void> _onDeleted(
    NewsFormDeleted event,
    Emitter<NewsFormState> emit,
  ) async {
    // TODO: Integrate with delete use case when domain layer is implemented
    emit(state.copyWith(
      status: FormStatus.failure,
      errorMessage: 'Delete not yet implemented',
    ));
  }
}
