import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';

class NewsFilterState extends Equatable {
  final NewsSection selectedSection;
  final String searchQuery;

  const NewsFilterState({
    this.selectedSection = NewsSection.todos,
    this.searchQuery = '',
  });

  NewsFilterState copyWith({
    NewsSection? selectedSection,
    String? searchQuery,
  }) {
    return NewsFilterState(
      selectedSection: selectedSection ?? this.selectedSection,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [selectedSection, searchQuery];
}
