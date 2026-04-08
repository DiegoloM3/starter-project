import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/article/local/local_article_bloc.dart';
import '../bloc/article/local/local_article_state.dart';
import 'saved_articles_list.dart';

class SavedArticlesBody extends StatelessWidget {
  const SavedArticlesBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is LocalArticlesDone) {
          return SavedArticlesList(articles: state.articles!);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
