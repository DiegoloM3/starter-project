import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_uploaded_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_uploaded_articles_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MyArticlesPage extends StatelessWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyUploadedArticlesCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Articles', style: TextStyle(color: Colors.black)),
        ),
        body: BlocBuilder<MyUploadedArticlesCubit, MyUploadedArticlesState>(
          builder: (context, state) {
            if (state is MyUploadedArticlesLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is MyUploadedArticlesError) {
              return Center(child: Text(state.message));
            }

            if (state is MyUploadedArticlesDone) {
              if (state.articles.isEmpty) {
                return const Center(
                  child: Text('You have not uploaded any articles yet'),
                );
              }

              return ListView.builder(
                itemCount: state.articles.length,
                itemBuilder: (context, index) {
                  final article = state.articles[index];
                  return ArticleWidget(
                    article: article,
                    onArticlePressed: (value) => _onArticlePressed(context, value),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
