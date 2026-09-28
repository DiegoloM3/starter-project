import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_user_articles.dart';

part 'user_articles_event.dart';
part 'user_articles_state.dart';

@injectable
/// UI state machine for one author's articles.
class UserArticlesBloc extends Bloc<UserArticlesEvent, UserArticlesState> {
  final GetUserArticles _getUserArticles;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  UserArticlesBloc(this._getUserArticles, this._getCurrentUserUseCase)
      : super(const UserArticlesLoading()) {
    on<LoadUserArticles>(_onLoadUserArticles);
  }

  Future<void> _onLoadUserArticles(
    LoadUserArticles event,
    Emitter<UserArticlesState> emit,
  ) async {
    emit(const UserArticlesLoading());

    final user = await _getCurrentUserUseCase();
    if (user is! DataSuccess || user.data == null) {
      emit(const UserArticlesError('Please log in to see your articles.'));
      return;
    }

    final result = await _getUserArticles(
      params: GetUserArticlesParams(userId: user.data!.id),
    );

    if (result is DataSuccess) {
      emit(UserArticlesDone(result.data ?? const <ArticleEntity>[]));
    } else {
      emit(UserArticlesError(
        result.errorMessage ?? result.error?.toString() ?? 'Unknown error.',
      ));
    }
  }
}
