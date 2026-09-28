

part of 'remote_article_bloc.dart';


@immutable
sealed class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticlesEvent extends RemoteArticlesEvent {
  const GetArticlesEvent();
}
