import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_filter/news_filter_state.dart';

class NewsFilterCubit extends Cubit<NewsFilterState> {
  NewsFilterCubit() : super(const NewsFilterState());

  void selectSection(NewsSection section) {
    emit(state.copyWith(selectedSection: section));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
