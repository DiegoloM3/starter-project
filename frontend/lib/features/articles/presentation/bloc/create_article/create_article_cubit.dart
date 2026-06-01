import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';
import 'package:tortutip/features/articles/domain/use_cases/publish_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/update_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/upload_article_image_use_case.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';

import 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final PublishArticleUseCase _publishArticle;
  final UpdateArticleUseCase _updateArticle;
  final UploadArticleImageUseCase _uploadArticleImage;
  final GetAllCategoriesUseCase _getAllCategories;

  // Accumulated form state
  String? _coverVerticalUrl;
  String? _coverHorizontalUrl;
  String _title = '';
  String _categoryId = '';
  String _bodyJson = '';
  List<CategoryEntity> _categories = [];
  String? _editingArticleId;

  bool get isEditing => _editingArticleId != null;

  CreateArticleCubit(
    this._publishArticle,
    this._updateArticle,
    this._uploadArticleImage,
    this._getAllCategories,
  ) : super(const CreateArticleInitial());

  CreateArticleFormUpdated get _currentFormState => CreateArticleFormUpdated(
        coverVerticalUrl: _coverVerticalUrl,
        coverHorizontalUrl: _coverHorizontalUrl,
        title: _title,
        categoryId: _categoryId,
        bodyJson: _bodyJson,
        categories: _categories,
      );

  Future<void> uploadCoverImage(File imageFile, bool isVertical, String userId) async {
    emit(CreateArticleImageUploading(isVertical: isVertical));
    final params = UploadArticleImageParams(
      userId: userId,
      imageFile: imageFile,
      isVertical: isVertical,
    );
    final result = await _uploadArticleImage(params);
    if (result.isSuccess) {
      if (isVertical) {
        _coverVerticalUrl = result.data;
      } else {
        _coverHorizontalUrl = result.data;
      }
      emit(_currentFormState);
    } else {
      emit(CreateArticleError(_mapErrorToMessage(result.error!)));
      emit(_currentFormState);
    }
  }

  void updateTitle(String title) {
    _title = title;
    emit(_currentFormState);
  }

  void selectCategory(String categoryId) {
    _categoryId = categoryId;
    emit(_currentFormState);
  }

  void updateBody(String bodyJson) {
    _bodyJson = bodyJson;
    emit(_currentFormState);
  }

  void initForEdit(ArticleEntity article) {
    _editingArticleId = article.id;
    _title = article.title;
    _categoryId = article.categoryId;
    _bodyJson = article.body;
    _coverVerticalUrl = article.coverVerticalUrl.isNotEmpty
        ? article.coverVerticalUrl
        : null;
    _coverHorizontalUrl = article.coverHorizontalUrl.isNotEmpty
        ? article.coverHorizontalUrl
        : null;
    emit(_currentFormState);
  }

  Future<void> publish(PublishArticleParams params) async {
    emit(const CreateArticleLoading());
    final result = await _publishArticle(params);
    if (result.isSuccess) {
      emit(CreateArticleSuccess(result.data!));
    } else {
      emit(CreateArticleError(_mapErrorToMessage(result.error!)));
    }
  }

  Future<void> publishFromForm(
      String authorId, {
      String authorName = '',
      String authorAvatarUrl = '',
  }) async {
    emit(const CreateArticlePublishing());
    final readTime = _calculateReadTime(_bodyJson);
    if (_editingArticleId != null) {
      final params = UpdateArticleParams(
        articleId: _editingArticleId!,
        categoryId: _categoryId,
        title: _title,
        body: _extractPlainText(_bodyJson),
        coverVerticalUrl: _coverVerticalUrl ?? '',
        coverHorizontalUrl: _coverHorizontalUrl ?? '',
        readTimeMinutes: readTime,
      );
      final result = await _updateArticle(params);
      if (result.isSuccess) {
        emit(CreateArticlePublished(result.data!));
      } else {
        emit(CreateArticleError(_mapErrorToMessage(result.error!)));
      }
    } else {
      final params = PublishArticleParams(
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        categoryId: _categoryId,
        title: _title,
        body: _extractPlainText(_bodyJson),
        coverVerticalUrl: _coverVerticalUrl ?? '',
        coverHorizontalUrl: _coverHorizontalUrl ?? '',
        readTimeMinutes: readTime,
      );
      final result = await _publishArticle(params);
      if (result.isSuccess) {
        emit(CreateArticlePublished(result.data!));
      } else {
        emit(CreateArticleError(_mapErrorToMessage(result.error!)));
      }
    }
  }

  String _extractPlainText(String bodyJson) {
    try {
      final ops = jsonDecode(bodyJson) as List<dynamic>;
      return ops
          .map((op) => op is Map && op['insert'] is String ? op['insert'] as String : '')
          .join()
          .trim();
    } catch (_) {
      return bodyJson;
    }
  }

  int _calculateReadTime(String bodyJson) {
    final plain = _extractPlainText(bodyJson);
    final wordCount = plain.trim().split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 999);
  }

  String _mapErrorToMessage(Exception error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('permission-denied') || msg.contains('unauthorized')) {
      return 'No tienes permiso para realizar esta acción';
    }
    if (msg.contains('unavailable') || msg.contains('network')) {
      return 'Sin conexión. Inténtalo de nuevo';
    }
    return 'Algo salió mal. Inténtalo de nuevo';
  }

  Future<void> loadCategories() async {
    final result = await _getAllCategories(const NoParams());
    if (result.isSuccess) {
      _categories = result.data ?? [];
      emit(_currentFormState);
    }
  }
}
