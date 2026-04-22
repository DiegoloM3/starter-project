import '../../features/daily_news/domain/entities/article.dart';

abstract class AnalyticsRepository {
  /// Track when an article is viewed, including duration for data-driven decisions.
  Future<void> trackArticleView(ArticleEntity article);

  /// Track chatbot interactions for tokenomics (usage) and quality analysis.
  Future<void> trackChatInteraction({
    required String prompt,
    required String response,
    required int estimatedTokens,
  });

  /// Track feature usage to identify what drives value in the app.
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties);

  /// Track app launch and session start.
  Future<void> trackSessionStart();
}
