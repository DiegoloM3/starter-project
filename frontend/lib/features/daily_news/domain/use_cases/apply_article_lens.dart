import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';

class ApplyArticleLensParams extends Equatable {
  final ArticleLens lens;
  final ArticleEntity article;

  const ApplyArticleLensParams({required this.lens, required this.article});

  @override
  List<Object?> get props => [lens, article];
}

/// Reads an article through a lens: three bullets, or plain words.
class ApplyArticleLensUseCase implements UseCase<DataState<ArticleLensResult>, ApplyArticleLensParams> {
  final ArticleAssistantRepository _assistant;

  const ApplyArticleLensUseCase(this._assistant);

  @override
  Future<DataState<ArticleLensResult>> call(ApplyArticleLensParams params) {
    return _assistant.apply(params.lens, params.article);
  }
}
