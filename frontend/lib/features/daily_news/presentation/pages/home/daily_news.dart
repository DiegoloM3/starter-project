import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../../../injection_container.dart';
import '../../../../auth/domain/usecases/get_current_user.dart';
import '../../../../auth/domain/usecases/sign_out.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  _buildAppbar(BuildContext context) {
    return AppBar(
      leading: FutureBuilder(
        future: sl<GetCurrentUserUseCase>()(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _onSignOutTapped(context),
          );
        },
      ),
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () => _onShowMyArticlesTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.person, color: Colors.black),
          ),
        ),
      ],
    );
  }

  _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: Icon(Icons.refresh)));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    List<Widget> articleWidgets = [];
    for (var article in articles) {
      articleWidgets.add(ArticleWidget(
        article: article,
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ));
    }

    return Scaffold(
      appBar: _buildAppbar(context),
      body: ListView(
        children: articleWidgets,
      ),
      floatingActionButton: FutureBuilder(
        future: sl<GetCurrentUserUseCase>()(),
        builder: (context, snapshot) {
          if (snapshot.data == null) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _onCreateArticleTapped(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  Future<void> _onShowMyArticlesTapped(BuildContext context) async {
    final user = await sl<GetCurrentUserUseCase>()();
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }
    Navigator.pushNamed(context, '/MyArticles');
  }

  Future<void> _onCreateArticleTapped(BuildContext context) async {
    final getCurrentUser = sl<GetCurrentUserUseCase>();
    final user = await getCurrentUser();
    if (user == null) {
      // Navegar a login; al autenticarse, podrá volver y crear artículos
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    await Navigator.pushNamed(context, '/CreateArticle');
    if (!context.mounted) return;
    context.read<RemoteArticlesBloc>().add(const GetArticles());
  }

  Future<void> _onSignOutTapped(BuildContext context) async {
    await sl<SignOutUseCase>()();
    if (!context.mounted) return;
    context.read<RemoteArticlesBloc>().add(const GetArticles());
  }
}
