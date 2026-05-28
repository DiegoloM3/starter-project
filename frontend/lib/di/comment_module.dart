import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_comment_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/comment_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_comments.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_bloc.dart';

void registerCommentModule(GetIt sl) {
  // Data Source
  sl.registerSingleton<FirestoreCommentDataSource>(
      FirestoreCommentDataSource(sl()));

  // Repository
  sl.registerSingleton<CommentRepository>(CommentRepositoryImpl(sl()));

  // Use Cases
  sl.registerSingleton<AddCommentUseCase>(AddCommentUseCase(sl()));
  sl.registerSingleton<GetCommentsUseCase>(GetCommentsUseCase(sl()));
  sl.registerSingleton<DeleteCommentUseCase>(DeleteCommentUseCase(sl()));

  // BLoCs
  sl.registerFactory<CommentBloc>(
      () => CommentBloc(sl(), sl(), sl()));
}
