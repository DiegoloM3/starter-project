import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/search_history_entity.dart';

/// Stored with the search text as its key, so searching the same thing again
/// replaces the row (moving it to the top) instead of adding a duplicate.
@Entity(tableName: 'search_history', primaryKeys: ['text'])
class SearchHistoryModel extends SearchHistoryEntity {
  /// Milliseconds since epoch, only to order the list: SQLite has no date
  /// type, and the domain only needs the order.
  final int searchedAt;

  const SearchHistoryModel({required super.text, required this.searchedAt});

  factory SearchHistoryModel.fromRawData(Map<String, dynamic> row) {
    return SearchHistoryModel(
      text: row['text'] as String,
      searchedAt: row['searchedAt'] as int,
    );
  }

  SearchHistoryEntity toEntity() => SearchHistoryEntity(text: text);
}
