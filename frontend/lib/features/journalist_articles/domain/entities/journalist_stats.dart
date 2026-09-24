import 'package:equatable/equatable.dart';

import 'journalist_article.dart';

/// What a journalist has to show for their work.
///
/// It is derived from their articles rather than stored, so it can never
/// disagree with the list those articles appear in.
class JournalistStatsEntity extends Equatable {
  /// Everything they have written, drafts included.
  final int articleCount;

  /// Readers reached, across everything they have published.
  final int totalViews;

  const JournalistStatsEntity({
    this.articleCount = 0,
    this.totalViews = 0,
  });

  /// Counts up a journalist's body of work.
  ///
  /// Drafts count towards [articleCount] because "My articles" opens onto
  /// them too, and they contribute nothing to [totalViews] because nobody has
  /// been able to read them.
  factory JournalistStatsEntity.of(List<JournalistArticleEntity> articles) {
    return JournalistStatsEntity(
      articleCount: articles.length,
      totalViews: articles.fold(
        0,
        (total, article) => total + article.viewCount,
      ),
    );
  }

  bool get hasArticles => articleCount > 0;

  @override
  List<Object?> get props => [articleCount, totalViews];
}
