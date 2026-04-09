import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/publish_article/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_scaffold.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/articles_list.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RemoteArticlesBloc>()..add(const GetArticles()),
      child: BaseScaffold(
        text: AppLocalizations.of(context).daily_news,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(Paths.savedArticles.name),
            icon: const Icon(Icons.bookmark, color: Colors.black),
          ),
          IconButton(
            onPressed: () => context.read<LoginBloc>().add(SignOutRequested()),
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
        body: const _DailyNewsBody(),
        floatingActionButton: const _DailyNewsFloatingButton(),
      ),
    );
  }
}

class _DailyNewsBody extends StatefulWidget {
  const _DailyNewsBody();

  @override
  State<_DailyNewsBody> createState() => _DailyNewsBodyState();
}

class _DailyNewsBodyState extends State<_DailyNewsBody> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200.0) {
        context.read<RemoteArticlesBloc>().add(const NextPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<RemoteArticlesBloc>().add(
            const GetArticles(),
          ),
      child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) => switch (state) {
          RemoteArticlesLoading() =>
            const Center(child: CupertinoActivityIndicator()),
          RemoteArticlesError() => const Center(child: Icon(Icons.refresh)),
          RemoteArticlesDone() => ArticlesList(
              scrollController: _scrollController,
              articles: state.articles ?? [],
              isLast: state.isLast,
            ),
          RemoteArticleEmpty() =>
            Center(child: Text(AppLocalizations.of(context).no_articles_found)),
        },
      ),
    );
  }
}

class _DailyNewsFloatingButton extends FloatingActionButton {
  const _DailyNewsFloatingButton({super.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final loginState = context.read<LoginBloc>().state;

        if (loginState is LoggedIn) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (modalContext) => PublishArticle(
              onPublishSuccess: () {
                context.read<RemoteArticlesBloc>().add(const GetArticles());
              },
            ),
          );
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
