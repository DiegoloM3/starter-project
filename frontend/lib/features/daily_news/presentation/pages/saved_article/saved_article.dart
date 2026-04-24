import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
<<<<<<< HEAD
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_tile.dart';

class SavedArticles extends HookWidget {
  const SavedArticles({Key ? key}) : super(key: key);
=======
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class SavedArticles extends HookWidget {
  const SavedArticles({Key? key}) : super(key: key);
>>>>>>> fbce432 (Finish PR (project setup))

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
<<<<<<< HEAD
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
=======
      create: (_) => sl<LocalArticlesBloc>()..add(const GetSavedArticles()),
>>>>>>> fbce432 (Finish PR (project setup))
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
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      title: const Text('Saved Articles', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildBody() {
<<<<<<< HEAD
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
=======
    return BlocBuilder<LocalArticlesBloc, LocalArticlesState>(
>>>>>>> fbce432 (Finish PR (project setup))
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is LocalArticlesDone) {
<<<<<<< HEAD
          return _buildArticlesList(state.articles!);
        }
        return Container();
=======
          return _buildArticlesList(context, state.articles);
        }
        return const SizedBox.shrink();
>>>>>>> fbce432 (Finish PR (project setup))
      },
    );
  }

<<<<<<< HEAD
  Widget _buildArticlesList(List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return const Center(
          child: Text(
        'NO SAVED ARTICLES',
        style: TextStyle(color: Colors.black),
      ));
=======
  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          'No saved articles',
          style: TextStyle(color: Colors.black),
        ),
      );
>>>>>>> fbce432 (Finish PR (project setup))
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: articles[index],
          isRemovable: true,
          onRemove: (article) => _onRemoveArticle(context, article),
          onArticlePressed: (article) => _onArticlePressed(context, article),
        );
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
<<<<<<< HEAD
    BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article));
=======
    BlocProvider.of<LocalArticlesBloc>(context).add(RemoveArticle(article));
>>>>>>> fbce432 (Finish PR (project setup))
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
