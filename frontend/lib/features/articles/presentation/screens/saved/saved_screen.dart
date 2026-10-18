import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../bloc/saved_articles/saved_articles_cubit.dart';
import '../../bloc/saved_articles/saved_articles_state.dart';
import '../../widgets/article_list.dart';
import '../../widgets/status_message.dart';

/// Saved tab: the articles the user saved, most recent first.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardados')),
      body: BlocBuilder<SavedArticlesCubit, SavedArticlesState>(
        builder: (context, state) => _buildContent(context, state),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SavedArticlesState state) {
    if (state.articles.isNotEmpty) {
      return ArticleList(
        articles: state.articles,
        featureFirstArticle: false,
        onArticleTap: (article) => Navigator.of(context).pushNamed(AppRoutes.articleDetail, arguments: article),
      );
    }
    return switch (state.status) {
      SavedArticlesStatus.initial || SavedArticlesStatus.loading => const Center(child: CircularProgressIndicator()),
      SavedArticlesStatus.failure => StatusMessage(
        icon: Icons.wifi_off,
        message: 'No se pudieron cargar tus guardados.',
        actionLabel: 'Reintentar',
        onAction: context.read<SavedArticlesCubit>().load,
      ),
      SavedArticlesStatus.success || SavedArticlesStatus.toggleFailure => const StatusMessage(
        icon: Icons.bookmark_border,
        message: 'Guarda artículos con el marcador para leerlos más tarde.',
      ),
    };
  }
}
