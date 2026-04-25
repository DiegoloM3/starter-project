import 'package:equatable/equatable.dart';

abstract class RemoteAddArticleState extends Equatable {
  const RemoteAddArticleState();

  @override
  List<Object?> get props => [];
}

class RemoteAddArticleInitial extends RemoteAddArticleState {}

class AIImageLoading extends RemoteAddArticleState {}

class AIImageSuccess extends RemoteAddArticleState {
  final String imageUrl;
  const AIImageSuccess(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class AIImageError extends RemoteAddArticleState {
  final String message;
  const AIImageError(this.message);

  @override
  List<Object?> get props => [message];
}
