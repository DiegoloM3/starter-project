abstract class ArticleSearchService {
  Future<List<String>> searchArticles(String query, {int limit = 10});
}
