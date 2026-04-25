import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/models/article_presentation_model.dart';
import 'package:news_app_clean_architecture/core/models/home_category.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/widgets/article_card.dart';
import 'package:news_app_clean_architecture/core/widgets/article_card_skeleton.dart';
import 'package:news_app_clean_architecture/core/widgets/empty_state.dart';
import 'package:news_app_clean_architecture/core/widgets/home_layout.dart';
import 'package:news_app_clean_architecture/core/widgets/skeleton_loader.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart'
    as art;
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ArticlesCubit>(
          create: (_) => sl<ArticlesCubit>()..loadArticles(),
        ),
        BlocProvider<RemoteArticlesBloc>(
          create: (_) => sl<RemoteArticlesBloc>()..add(const GetArticles()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  String _selectedCategory = 'top_stories';
  int _expandedIndex = 0;

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _expandedIndex = 0;
    });
    final filterCategory = category == 'top_stories' ? null : category;
    context.read<ArticlesCubit>().loadArticles(category: filterCategory);
    context.read<RemoteArticlesBloc>().add(const GetArticles());
  }

  Future<void> _refresh() async {
    final filterCategory =
        _selectedCategory == 'top_stories' ? null : _selectedCategory;
    context.read<ArticlesCubit>().loadArticles(category: filterCategory);
    context.read<RemoteArticlesBloc>().add(const GetArticles());
  }

  // ── Mappers ─────────────────────────────────────────────────────────────

  ArticlePresentationModel _fromFirebase(art.ArticleEntity a) {
    return ArticlePresentationModel(
      id: a.id,
      title: a.title,
      excerpt: a.excerpt,
      thumbnailURL: a.thumbnailURL,
      category: a.category,
      authorName: a.authorName,
      authorPhotoURL: a.authorPhotoURL,
      publishedAt: a.createdAt.toIso8601String(),
      readTime: a.readTime,
      isFirebaseArticle: true,
    );
  }

  ArticlePresentationModel _fromNewsApi(ArticleEntity a) {
    final words = (a.content?.split(' ').length ?? 0);
    final readTime = (words / 200).ceil().clamp(1, 99);
    return ArticlePresentationModel(
      id: 'news_${a.id ?? a.title.hashCode}',
      title: a.title ?? 'Untitled',
      excerpt: a.description ?? '',
      thumbnailURL: a.urlToImage,
      category: null,
      authorName: a.author ?? 'Unknown',
      publishedAt: a.publishedAt ?? '',
      readTime: readTime,
    );
  }

  List<ArticlePresentationModel> _firebaseArticles(ArticlesState state) {
    if (state is ArticlesLoaded) {
      return state.articles.map(_fromFirebase).toList();
    }
    if (state is ArticleMutationSuccess) {
      return state.articles.map(_fromFirebase).toList();
    }
    if (state is ArticleMutationError) {
      return state.articles.map(_fromFirebase).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isWriter = authState is AuthAuthenticated &&
            (authState).user.role == 'writer';

        return HomeLayout(
          categories: kHomeCategories,
          selectedCategory: _selectedCategory,
          onCategoryChanged: _onCategoryChanged,
          onSearchTap: () {},
          onBookmarkTap: () =>
              Navigator.pushNamed(context, AppRoutes.savedArticles),
          showFAB: isWriter,
          onFABTap: () =>
              Navigator.pushNamed(context, AppRoutes.createArticle),
          body: BlocBuilder<ArticlesCubit, ArticlesState>(
            builder: (context, articlesState) {
              return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                builder: (context, remoteState) {
                  final firebaseList = _firebaseArticles(articlesState);
                  final newsList = remoteState is RemoteArticlesDone
                      ? (remoteState.articles
                              ?.map(_fromNewsApi)
                              .toList() ??
                          const <ArticlePresentationModel>[])
                      : const <ArticlePresentationModel>[];

                  final isLoading = articlesState is ArticlesLoading ||
                      remoteState is RemoteArticlesLoading;

                  final bothFailed = articlesState is ArticlesError &&
                      remoteState is RemoteArticlesError;

                  final merged = <ArticlePresentationModel>[
                    ...firebaseList,
                    ...newsList,
                  ];

                  // ── Loading ──
                  if (isLoading && merged.isEmpty) {
                    return ShimmerScope(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: AppMetrics.w(16)),
                        itemCount: 5,
                        itemBuilder: (_, __) =>
                            const ArticleCardSkeleton(),
                      ),
                    );
                  }

                  // ── Error ──
                  if (bothFailed && merged.isEmpty) {
                    return EmptyState(
                      icon: Icons.wifi_off_outlined,
                      title: "Couldn't load news",
                      subtitle: 'Check your connection',
                      actionLabel: 'Try again',
                      onAction: _refresh,
                    );
                  }

                  // ── Empty ──
                  if (!isLoading && merged.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No articles found',
                      subtitle: 'Try a different category',
                    );
                  }

                  // ── Loaded ──
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: AppMetrics.w(16)),
                      itemCount: merged.length,
                      itemBuilder: (_, index) {
                        final article = merged[index];
                        return ArticleCard(
                          article: article,
                          isExpanded: index == _expandedIndex,
                          onTap: () => setState(() {
                            _expandedIndex =
                                index == _expandedIndex ? -1 : index;
                          }),
                          onReadTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.articleDetails,
                            arguments: article,
                          ),
                          onBookmarkTap: () {},
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
