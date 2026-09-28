import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/user/user_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Page listing the current user's articles with edit entry points.
class MyArticlesPage extends StatelessWidget {
  const MyArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserArticlesBloc>()..add(const LoadUserArticles()),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevronBack, color: Colors.black),
        ),
      ),
      title: const Text('My Articles', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<UserArticlesBloc, UserArticlesState>(
      builder: (context, state) {
        if (state is UserArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is UserArticlesDone) {
          if (state.articles.isEmpty) {
            return const Center(
              child: Text(
                'YOU HAVE NOT WRITTEN ANY ARTICLES YET',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          return ListView.builder(
            itemCount: state.articles.length,
            itemBuilder: (context, index) {
              final article = state.articles[index];
              return ArticleWidget(
                article: article,
                avatarCubitFactory: () => sl<AuthorAvatarCubit>(),
                onArticlePressed: (pressed) => Navigator.pushNamed(
                  context,
                  '/ArticleDetails',
                  arguments: pressed,
                ),
                trailing: IconButton(
                  icon: const Icon(Ionicons.createOutline,
                      size: 20, color: Colors.black54),
                  tooltip: 'Edit article',
                  onPressed: () => _onEditPressed(context, article),
                ),
              );
            },
          );
        } else if (state is UserArticlesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _onEditPressed(
    BuildContext context,
    ArticleEntity article,
  ) async {
    final result = await Navigator.pushNamed(
      context,
      '/EditArticle',
      arguments: article,
    );
    if (!context.mounted) return;
    if (result == true) {
      context.read<UserArticlesBloc>().add(const LoadUserArticles());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Article updated.'),
        ),
      );
    }
    if (result == 'deleted') {
      context.read<UserArticlesBloc>().add(const LoadUserArticles());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Article deleted.'),
        ),
      );
    }
  }
}
