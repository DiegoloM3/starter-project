import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page.dart';

class PageModel<T> extends PageEntity<T> {
  const PageModel({
    required super.content,
    required super.page,
    required super.totalPages,
    required super.total,
  });
}
