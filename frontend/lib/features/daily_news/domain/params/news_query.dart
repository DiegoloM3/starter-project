import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Filters for the provider's top-headlines feed. The app is US/English-only
/// by design, so the only filter a reader controls is the category.
class NewsQuery extends Equatable {
  final NewsCategory category;

  const NewsQuery({this.category = NewsCategory.general});

  @override
  List<Object?> get props => [category];
}
