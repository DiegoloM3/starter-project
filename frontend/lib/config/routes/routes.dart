import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/onboarding/onboarding_categories_screen.dart';
import '../../features/auth/presentation/pages/onboarding/onboarding_profile_screen.dart';
import '../../features/auth/presentation/pages/onboarding/onboarding_role_screen.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String forgotPassword = '/forgot-password';
  static const String onboardingCategories = '/onboarding/categories';
  static const String onboardingRole = '/onboarding/role';
  static const String onboardingProfile = '/onboarding/profile';
  static const String articleDetails = '/article-details';
  static const String savedArticles = '/saved-articles';

  // Legacy route names used by daily_news feature (do not remove).
  static const String articleDetailsLegacy = '/ArticleDetails';
  static const String savedArticlesLegacy = '/SavedArticles';

  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _materialRoute(const DailyNews());

      case auth:
        return _materialRoute(const AuthScreen());

      case forgotPassword:
        return _materialRoute(const ForgotPasswordScreen());

      case onboardingCategories:
        return _materialRoute(const OnboardingCategoriesScreen());

      case onboardingRole:
        return _materialRoute(const OnboardingRoleScreen());

      case onboardingProfile:
        return _materialRoute(const OnboardingProfileScreen());

      // New lowercase name + legacy name used by daily_news (do not remove)
      case articleDetails:
      case articleDetailsLegacy:
        final article = settings.arguments;
        if (article is! ArticleEntity) return _materialRoute(const DailyNews());
        return _materialRoute(ArticleDetailsView(article: article));

      // New lowercase name + legacy name used by daily_news (do not remove)
      case savedArticles:
      case savedArticlesLegacy:
        return _materialRoute(const SavedArticles());

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
