import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/dimensions.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../../../../firebase_articles/presentation/widgets/article_tile_skeleton.dart';

import '../../../../firebase_articles/presentation/widgets/featured_article_skeleton.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/featured_article_card.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _DailyNewsView();
  }
}

class _DailyNewsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddArticleTapped(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, remoteState) {
        return BlocBuilder<FirebaseArticlesCubit, FirebaseArticlesState>(
          builder: (context, firebaseState) {
            final List<ArticleEntity> allArticles = [];

            if (firebaseState is FirebaseArticlesDone) {
              allArticles.addAll(firebaseState.articles);
            }

            if (remoteState is RemoteArticlesDone) {
              allArticles.addAll(remoteState.articles!);
            }

            final bool isLoading = remoteState is RemoteArticlesLoading &&
                firebaseState is FirebaseArticlesLoading;

            final bool isEmpty = allArticles.isEmpty &&
                (remoteState is RemoteArticlesError ||
                    firebaseState is FirebaseArticlesError);

            if (isLoading || (allArticles.isEmpty && !isEmpty)) {
              return _buildWithAppBar(context, loading: true);
            }

            if (isEmpty) {
              return _buildWithAppBar(context, error: true);
            }

            return _buildArticlesList(context, allArticles);
          },
        );
      },
    );
  }

  Widget _buildWithAppBar(
    BuildContext context, {
    bool loading = false,
    bool error = false,
  }) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context),
        if (loading)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const FeaturedArticleSkeleton(),
                ...List.generate(
                  3,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: ArticleTileSkeleton(),
                  ),
                ),
              ]),
            ),
          ),
        if (error)
          const SliverFillRemaining(
            child: Center(child: Icon(Icons.refresh)),
          ),
      ],
    );
  }

  Widget _buildArticlesList(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FeaturedArticleCard(
                article: articles.first,
                onArticlePressed: (article) => Navigator.pushNamed(
                  context,
                  '/ArticleDetails',
                  arguments: article,
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = articles[index + 1];
                return _AnimatedArticleItem(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ArticleWidget(
                      article: article,
                      onArticlePressed: (article) => Navigator.pushNamed(
                        context,
                        '/ArticleDetails',
                        arguments: article,
                      ),
                    ),
                  ),
                );
              },
              childCount: articles.length - 1,
            ),
          ),
        ),
      ],
    );
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  void _onAddProfileTapped(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthSuccess && !authState.user.isAnonymous) {
      Navigator.pushNamed(context, '/Profile');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: const Text('Sign in to view profile'),
          action: SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/Welcome'),
          ),
        ),
      );
    }
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
  ) {
    const double expandedHeight = 130.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: () => _onAddProfileTapped(context),
          child: UserAvatar(),
        ),
      ),
      centerTitle: false,
      title: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () => _onShowSavedArticlesViewTapped(context),
            child: const Icon(
              Icons.bookmark,
              color: AppColors.titleDark,
              size: 30,
            ),
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final double statusBar = MediaQuery.of(context).padding.top;
          final double minHeight = statusBar + kToolbarHeight;
          final double maxHeight = expandedHeight + statusBar;
          final double progress =
              ((top - minHeight) / (maxHeight - minHeight)).clamp(0.0, 1.0);
          final double leftSize = 82.0;

          // Breaking News: expanded = bottom left big, collapsed = toolbar position small
          final double titleFontSize = 16 + (19 * progress);
          final double titleBottom = 18 + (2 * progress);

          final double titleLeft = AppDimensions.screenPaddingHorizontal +
              ((leftSize - AppDimensions.screenPaddingHorizontal) *
                  (1 - progress));

          return Stack(
            fit: StackFit.expand,
            children: [
              // Date text - fades out on collapse
              Positioned(
                left: leftSize,
                top: statusBar + 14,
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    "Today, ${DateFormatter.format(DateTime.now().toIso8601String())}",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // Breaking News - moves from bottom to toolbar center
              Positioned(
                left: titleLeft,
                bottom: titleBottom,
                child: Text(
                  'Breaking News',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.lerp(
                      FontWeight.w600,
                      FontWeight.w800,
                      progress,
                    ),
                    fontFamily: 'Butler',
                    color: AppColors.titleDark,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onAddArticleTapped(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthSuccess && !authState.user.isAnonymous) {
      Navigator.pushNamed(context, '/AddArticle');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: const Text('Sign in to create articles'),
          action: SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/Welcome'),
          ),
        ),
      );
    }
  }
}

class _AnimatedArticleItem extends StatefulWidget {
  final Widget child;

  const _AnimatedArticleItem({
    required this.child,
  });

  @override
  State<_AnimatedArticleItem> createState() => _AnimatedArticleItemState();
}

class _AnimatedArticleItemState extends State<_AnimatedArticleItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
