import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/extensions/context_extensions.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_scaffold.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/articles_list.dart';

class SavedArticles extends StatelessWidget {
  const SavedArticles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold.withBackNavigation(
      text: AppLocalizations.of(context).saved_articles,
      body: BlocConsumer<LocalArticleBloc, LocalArticlesState>(
        listenWhen: (previous, current) =>
            current is LocalArticlesDone &&
            current.status != LocalArticleStatus.none,
        listener: (context, state) {
          switch (state.status) {
            case LocalArticleStatus.savedSuccess:
              context.showSnackBar(
                message: AppLocalizations.of(context).saved_article,
                backgroundColor: Colors.black,
              );
            case LocalArticleStatus.deletedSuccess:
              context.showSnackBar(
                message: AppLocalizations.of(context).deleted_article,
                backgroundColor: Colors.black,
              );
            case LocalArticleStatus.genericError:
              context.showSnackBar(
                message: AppLocalizations.of(context).generic_error,
                backgroundColor: Colors.red,
              );
            case LocalArticleStatus.none:
              break;
          }
        },
        builder: (context, state) => switch (state) {
          LocalArticlesLoading() => const Center(
              child: CupertinoActivityIndicator(),
            ),
          LocalArticlesDone() => ArticlesList(
              articles: state.articles ?? [],
              isLast: true,
              isRemovable: true,
              onRemove: (article) => context.read<LocalArticleBloc>().add(
                    RemoveArticle(article),
                  ),
            ),
          LocalArticleEmpty() => Center(
              child: Text(
                AppLocalizations.of(context).no_saved_articles,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          LocalArticlesError() => Center(
              child: Text(
                AppLocalizations.of(context).error,
                style: const TextStyle(color: Colors.black),
              ),
            ),
        },
      ),
    );
  }
}
