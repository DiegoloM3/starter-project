import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/articles/domain/entities/article.dart';
import '../../features/articles/domain/entities/topic_trend.dart';
import '../../features/articles/presentation/bloc/article_detail/article_detail_cubit.dart';
import '../../features/articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import '../../features/articles/presentation/screens/article_detail/article_detail_screen.dart';
import '../../features/articles/presentation/screens/article_editor/article_editor_screen.dart';
import '../../features/articles/presentation/screens/topic_articles/topic_articles_screen.dart';
import '../../features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import '../../features/auth/presentation/screens/delete_account/delete_account_screen.dart';
import '../../features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import '../../features/comments/presentation/bloc/comments/comments_cubit.dart';
import '../../features/profiles/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import '../../features/profiles/presentation/bloc/user_profile/user_profile_cubit.dart';
import '../../features/profiles/presentation/screens/edit_profile/edit_profile_screen.dart';
import '../../features/profiles/presentation/screens/user_profile/user_profile_screen.dart';
import '../../features/settings/presentation/bloc/notifications/notifications_cubit.dart';
import '../../features/settings/presentation/screens/legal/legal_documents.dart';
import '../../features/settings/presentation/screens/legal/legal_screen.dart';
import '../../features/settings/presentation/screens/settings/settings_screen.dart';
import '../../injection_container.dart';
import '../../shared/users/domain/entities/user.dart';

class AppRoutes {
  static const String signUp = '/sign-up';

  static const String settings = '/settings';

  /// Expects the [LegalDocument] to show as argument.
  static const String legal = '/settings/legal';

  static const String deleteAccount = '/settings/delete-account';

  /// Expects the [TopicTrend] to show as argument.
  static const String topicArticles = '/topic';

  /// Expects the [UserEntity] of the signed in user as argument.
  static const String editProfile = '/profile/edit';

  /// Expects the uid of the user to show as argument.
  static const String userProfile = '/profile';

  /// Expects the [ArticleEntity] to show as argument.
  static const String articleDetail = '/article';

  /// Expects the [ArticleEntity] to edit as argument, or nothing to publish a new one.
  static const String articleEditor = '/article/editor';

  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    return switch (settings.name) {
      signUp => _materialRoute(BlocProvider(create: (_) => sl<AuthFormCubit>(), child: const SignUpScreen())),
      AppRoutes.settings => _materialRoute(
        BlocProvider(create: (_) => sl<NotificationsCubit>()..load(), child: const SettingsScreen()),
      ),
      legal => _materialRoute(LegalScreen(document: settings.arguments as LegalDocument)),
      deleteAccount => _materialRoute(
        BlocProvider(create: (_) => sl<AuthFormCubit>(), child: const DeleteAccountScreen()),
      ),
      topicArticles => _materialRoute(TopicArticlesScreen(trend: settings.arguments as TopicTrend)),
      editProfile => _materialRoute(
        BlocProvider(
          create: (_) => sl<EditProfileCubit>(),
          child: EditProfileScreen(user: settings.arguments as UserEntity),
        ),
      ),
      userProfile => _materialRoute(_buildUserProfile(settings.arguments as String)),
      articleDetail => _materialRoute(_buildArticleDetail(settings.arguments as ArticleEntity)),
      articleEditor => _materialRoute(
        _buildArticleEditor(settings.arguments as ArticleEntity?),
        fullscreenDialog: true,
      ),
      _ => throw ArgumentError('Unknown route: ${settings.name}'),
    };
  }

  static Widget _buildArticleDetail(ArticleEntity article) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ArticleDetailCubit>(param1: article)..recordView()),
        BlocProvider(create: (_) => sl<CommentsCubit>(param1: article.id)..load()),
      ],
      child: const ArticleDetailScreen(),
    );
  }

  static Widget _buildUserProfile(String uid) {
    return BlocProvider(create: (_) => sl<UserProfileCubit>(param1: uid)..load(), child: UserProfileScreen(uid: uid));
  }

  static Widget _buildArticleEditor(ArticleEntity? original) {
    return BlocProvider(create: (_) => sl<ArticleEditorCubit>(), child: ArticleEditorScreen(original: original));
  }

  static Route<dynamic> _materialRoute(Widget view, {bool fullscreenDialog = false}) {
    return MaterialPageRoute(builder: (_) => view, fullscreenDialog: fullscreenDialog);
  }
}
