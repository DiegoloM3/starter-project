import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';

/// The `brief` / `plain` answer of the assistant function.
class ArticleLensResultModel extends ArticleLensResult {
  const ArticleLensResultModel({required super.lens, super.bullets, super.text});

  factory ArticleLensResultModel.fromRawData(ArticleLens lens, Map<String, dynamic> raw) {
    final bullets = raw['bullets'];
    return ArticleLensResultModel(
      lens: lens,
      bullets: bullets is List
          ? bullets.whereType<String>().map((b) => b.trim()).where((b) => b.isNotEmpty).toList()
          : const [],
      text: raw['text'] is String ? (raw['text'] as String).trim() : '',
    );
  }

  bool get isEmpty => bullets.isEmpty && text.isEmpty;

  ArticleLensResult toEntity() => ArticleLensResult(lens: lens, bullets: bullets, text: text);
}
