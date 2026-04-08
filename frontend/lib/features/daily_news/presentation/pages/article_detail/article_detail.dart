import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../widgets/article_detail_app_bar.dart';
import '../../widgets/article_detail_body.dart';
import '../../widgets/save_article_fab.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        appBar: const ArticleDetailAppBar(),
        body: ArticleDetailBody(article: article!),
        floatingActionButton: SaveArticleFab(article: article!),
      ),
    );
  }
}
