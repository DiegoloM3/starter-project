import 'package:equatable/equatable.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final List<ArticleEntity> savedArticles;
  final List<ArticleEntity> publishedArticles;
  final int totalPublishedCount;
  final List<CategoryEntity> categories;

  const ProfileLoaded({
    required this.user,
    required this.savedArticles,
    required this.publishedArticles,
    required this.totalPublishedCount,
    this.categories = const [],
  });

  CategoryEntity? categoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        user,
        savedArticles,
        publishedArticles,
        totalPublishedCount,
        categories,
      ];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileArticleDeleted extends ProfileState {
  final String articleId;

  const ProfileArticleDeleted(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
