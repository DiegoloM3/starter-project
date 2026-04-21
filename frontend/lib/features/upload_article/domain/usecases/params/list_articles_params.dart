enum UserArticlesScope { mine, all }

class ListArticlesParams {
  final UserArticlesScope scope;

  const ListArticlesParams({required this.scope});
}
