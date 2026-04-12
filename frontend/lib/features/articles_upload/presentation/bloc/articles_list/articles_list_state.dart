import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';

abstract class ArticlesListState extends Equatable {
  const ArticlesListState();

  @override
  List<Object?> get props => [];
}

class ArticlesListInitial extends ArticlesListState {
  const ArticlesListInitial();
}

class ArticlesListLoading extends ArticlesListState {
  const ArticlesListLoading();
}

class ArticlesListLoaded extends ArticlesListState {
  final List<ArticleUploadEntity> allArticles;
  final String query;
  final bool hasMore;

  const ArticlesListLoaded(
    this.allArticles, {
    this.query = '',
    this.hasMore = true,
  });

  List<ArticleUploadEntity> get visibleArticles {
    if (query.trim().isEmpty) return allArticles;
    final needle = query.trim().toLowerCase();
    return allArticles.where((a) {
      return a.title.toLowerCase().contains(needle) ||
          a.description.toLowerCase().contains(needle) ||
          a.author.toLowerCase().contains(needle);
    }).toList();
  }

  ArticlesListLoaded copyWith({
    List<ArticleUploadEntity>? allArticles,
    String? query,
    bool? hasMore,
  }) {
    return ArticlesListLoaded(
      allArticles ?? this.allArticles,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [allArticles, query, hasMore];
}

class ArticlesListError extends ArticlesListState {
  final String message;
  const ArticlesListError(this.message);

  @override
  List<Object?> get props => [message];
}
