enum Paths {
  initial('/'),
  savedArticles('/saved-articles'),
  articleDetails('/article-details'),
  dailyNews('/daily-news'),
  login('/login'),
  register('/register');

  final String path;

  const Paths(this.path);
}
