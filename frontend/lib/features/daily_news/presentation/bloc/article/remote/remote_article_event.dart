import 'package:equatable/equatable.dart';

import '../../../../domain/entities/news_category.dart';

abstract class RemoteArticlesEvent extends Equatable {
  const RemoteArticlesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the headlines of one section.
class GetArticles extends RemoteArticlesEvent {
  final NewsCategory category;

  const GetArticles({this.category = NewsCategory.general});

  @override
  List<Object?> get props => [category];
}
