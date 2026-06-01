class AppRoutes {
  AppRoutes._();

  static const landing              = '/landing';
  static const login                = '/login';
  static const onboardingCategories = '/onboarding/categories';
  static const onboardingRole       = '/onboarding/role';
  static const onboardingDetails    = '/onboarding/details';
  static const feed                 = '/feed';
  static const explore              = '/explore';
  static const editProfile          = '/explore/edit';
  static const profile              = '/profile';

  static String articleDetailPath(String id) => '/article/$id';
  static String articlePath(String id) => '/article/$id';

  static String exploreCategoryPath(String categoryId) =>
      '/explore/category/$categoryId';

  static const search = '/search';

  static const bookmarks = '/bookmarks';

  static const editArticle = '/article/edit/:articleId';
  static String editArticlePath(String id) => '/article/edit/$id';
}
