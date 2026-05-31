import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/community_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/article_image_picker_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/create_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/delete_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_article_by_id.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/pick_cover_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/update_community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/watch_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/detail/community_article_detail_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/detail/community_article_detail_event.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/detail/community_article_detail_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/editor/community_article_editor_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/editor/community_article_editor_event.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/editor/community_article_editor_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/articles/community_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/articles/community_articles_event.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/articles/community_articles_state.dart';

void main() {
  group('Community article blocs', () {
    final article = CommunityArticleEntity(
      id: 'article-1',
      authorId: 'user-1',
      authorName: 'Elena Rostova',
      title: 'Community headline',
      content: 'Community body',
      description: 'Community lede',
      category: 'Community',
      publishedAt: DateTime(2026, 5, 30),
    );

    blocTest<CommunityArticlesBloc, CommunityArticlesState>(
      'loads the first page of community articles',
      build: () {
        final repository = _FakeCommunityArticleRepository(articles: [article]);
        return CommunityArticlesBloc(
          GetCommunityArticlesUseCase(repository),
          WatchCommunityArticlesUseCase(repository),
        );
      },
      act: (bloc) => bloc.add(const CommunityArticlesRequested()),
      expect: () => [
        const CommunityArticlesState(status: CommunityArticlesStatus.loading),
        CommunityArticlesState(
          status: CommunityArticlesStatus.success,
          articles: [article],
          hasMore: false,
        ),
      ],
    );

    blocTest<CommunityArticleDetailBloc, CommunityArticleDetailState>(
      'deletes the loaded article',
      build: () {
        final repository = _FakeCommunityArticleRepository(articles: [article]);
        return CommunityArticleDetailBloc(
          GetCommunityArticleByIdUseCase(repository),
          DeleteCommunityArticleUseCase(repository),
        );
      },
      seed: () => CommunityArticleDetailState(
        status: CommunityArticleDetailStatus.success,
        article: article,
      ),
      act: (bloc) => bloc.add(const CommunityArticleDeleteRequested()),
      expect: () => [
        CommunityArticleDetailState(
          status: CommunityArticleDetailStatus.deleting,
          article: article,
        ),
        CommunityArticleDetailState(
          status: CommunityArticleDetailStatus.deleted,
          article: article,
        ),
      ],
    );

    blocTest<CommunityArticleEditorBloc, CommunityArticleEditorState>(
      'publishes a community article',
      build: () {
        final repository = _FakeCommunityArticleRepository(articles: [article]);
        return CommunityArticleEditorBloc(
          CreateCommunityArticleUseCase(repository),
          UpdateCommunityArticleUseCase(repository),
          PickCoverImageUseCase(_FakeArticleImagePickerRepository()),
        );
      },
      act: (bloc) => bloc.add(
        const CommunityArticlePublishRequested(
          CreateArticleParams(
            title: 'Community headline',
            content: 'Community body',
            authorId: 'user-1',
            authorName: 'Elena Rostova',
            description: 'Community lede',
            category: 'Community',
          ),
        ),
      ),
      expect: () => [
        const CommunityArticleEditorState(
          status: CommunityArticleEditorStatus.submitting,
        ),
        CommunityArticleEditorState(
          status: CommunityArticleEditorStatus.success,
          article: article,
        ),
      ],
    );
  });
}

class _FakeCommunityArticleRepository implements CommunityArticleRepository {
  _FakeCommunityArticleRepository({
    required List<CommunityArticleEntity> articles,
  }) : _articles = articles;

  final List<CommunityArticleEntity> _articles;

  @override
  Future<DataState<PaginatedResult<CommunityArticleEntity>>>
  getCommunityArticles({required CommunityArticleParams params}) async {
    return DataSuccess(
      PaginatedResult(
        page: 1,
        pageSize: params.pageSize,
        totalResults: _articles.length,
        articles: _articles,
      ),
    );
  }

  @override
  Stream<DataState<List<CommunityArticleEntity>>> watchCommunityArticles({
    required CommunityArticleParams params,
  }) {
    return Stream.value(DataSuccess(_articles.take(params.pageSize).toList()));
  }

  @override
  Future<DataState<CommunityArticleEntity>> getCommunityArticleById({
    required String id,
  }) async {
    return DataSuccess(_articles.firstWhere((article) => article.id == id));
  }

  @override
  Future<DataState<List<CommunityArticleEntity>>> getUserArticles({
    required String userId,
  }) async {
    return DataSuccess(
      _articles.where((article) => article.authorId == userId).toList(),
    );
  }

  @override
  Future<DataState<CommunityArticleEntity>> createCommunityArticle({
    required CreateArticleParams params,
  }) async {
    return DataSuccess(_articles.first);
  }

  @override
  Future<DataState<CommunityArticleEntity>> updateCommunityArticle({
    required UpdateArticleParams params,
  }) async {
    return DataSuccess(_articles.first);
  }

  @override
  Future<DataState<void>> deleteCommunityArticle({required String id}) async {
    return const DataSuccess(null);
  }
}

class _FakeArticleImagePickerRepository
    implements ArticleImagePickerRepository {
  @override
  Future<DataState<File?>> pickCoverImage() async {
    return const DataSuccess(null);
  }
}
