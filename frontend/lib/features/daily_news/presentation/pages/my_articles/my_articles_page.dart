import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../injection_container.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/my/my_articles_cubit.dart';
import '../../bloc/article/my/my_articles_state.dart';
import '../../widgets/article_tile.dart';

class MyArticlesPage extends StatelessWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyArticlesCubit>(
      create: (_) => sl<MyArticlesCubit>()..load(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.chevron_back, color: Colors.black),
      ),
      title: const Text(
        'My Articles',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MyArticlesCubit, MyArticlesState>(
      builder: (context, state) {
        if (state is MyArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is MyArticlesError) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        }
        if (state is MyArticlesUnauthenticated) {
          return _buildUnauthenticated(context);
        }
        if (state is MyArticlesDone) {
          return _buildList(state.articles ?? []);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildList(List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          'YOU HAVE NOT PUBLISHED ANY ARTICLES YET',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: articles[index],
          isRemovable: true,
          onRemove: (article) => _onRemoveArticle(context, article),
          onArticlePressed: (article) => Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: article,
          ),
        );
      },
    );
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) async {
    await context.read<MyArticlesCubit>().delete(article);
  }

  Widget _buildUnauthenticated(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Sign in to see your published articles',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
