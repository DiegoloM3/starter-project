import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/articles/domain/entities/article.dart';
import '../../features/articles/presentation/bloc/article_detail/article_detail_cubit.dart';
import '../../features/articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import '../../features/articles/presentation/screens/article_detail/article_detail_screen.dart';
import '../../features/articles/presentation/screens/article_editor/article_editor_screen.dart';
import '../../features/auth/presentation/bloc/auth_form/auth_form_cubit.dart';
import '../../features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import '../../features/settings/presentation/screens/settings/settings_screen.dart';
import '../../injection_container.dart';

class AppRoutes {
  static const String signUp = '/sign-up';

  static const String settings = '/settings';

  /// Expects the [ArticleEntity] to show as argument.
  static const String articleDetail = '/article';

  /// Expects the [ArticleEntity] to edit as argument, or nothing to publish a new one.
  static const String articleEditor = '/article/editor';

  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    return switch (settings.name) {
      signUp => _materialRoute(BlocProvider(create: (_) => sl<AuthFormCubit>(), child: const SignUpScreen())),
      AppRoutes.settings => _materialRoute(const SettingsScreen()),
      articleDetail => _materialRoute(_buildArticleDetail(settings.arguments as ArticleEntity)),
      articleEditor => _materialRoute(
        _buildArticleEditor(settings.arguments as ArticleEntity?),
        fullscreenDialog: true,
      ),
      _ => throw ArgumentError('Unknown route: ${settings.name}'),
    };
  }

  static Widget _buildArticleDetail(ArticleEntity article) {
    return BlocProvider(create: (_) => sl<ArticleDetailCubit>(param1: article), child: const ArticleDetailScreen());
  }

  static Widget _buildArticleEditor(ArticleEntity? original) {
    return BlocProvider(create: (_) => sl<ArticleEditorCubit>(), child: ArticleEditorScreen(original: original));
  }

  static Route<dynamic> _materialRoute(Widget view, {bool fullscreenDialog = false}) {
    return MaterialPageRoute(builder: (_) => view, fullscreenDialog: fullscreenDialog);
  }
}
