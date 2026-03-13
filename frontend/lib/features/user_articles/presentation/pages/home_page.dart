import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/domain/entities/feed_item.dart';
import '../bloc/user_articles/user_articles_bloc.dart';
import '../bloc/user_articles/user_articles_event.dart';
import '../bloc/user_articles/user_articles_state.dart';
import '../widgets/featured_article_card.dart';
import '../widgets/article_list_card.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import '../../../daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  bool _showAllNews = false;

  @override
  void initState() {
    super.initState();
    // Load published articles
    context.read<UserArticlesBloc>().add(const LoadPublishedArticles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildHomeFeed(),
            _buildMyArticlesPlaceholder(),
            _buildProfilePlaceholder(),
          ],
        ),
      ),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ArticleEditor');
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeFeed() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
            builder: (context, remoteState) {
              return BlocBuilder<UserArticlesBloc, UserArticlesState>(
                builder: (context, userState) {
                  // Check loading states
                  final isLoading = userState is UserArticlesLoading ||
                      remoteState is RemoteArticlesLoading;

                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Gather articles from both sources
                  final List<FeedItem> feedItems = [];

                  // Add NewsAPI articles (labeled as "Trending")
                  if (remoteState is RemoteArticlesDone &&
                      remoteState.articles != null) {
                    for (final article in remoteState.articles!) {
                      feedItems.add(FeedItem.fromNewsArticle(article));
                    }
                  }

                  // Add user articles (only published ones)
                  if (userState is UserArticlesLoaded &&
                      userState.articles != null) {
                    for (final article in userState.articles!) {
                      if (article.isDraft == false) {
                        feedItems.add(FeedItem.fromUserArticle(article));
                      }
                    }
                  }

                  // Handle errors
                  if (userState is UserArticlesError &&
                      remoteState is RemoteArticlesError) {
                    return _buildErrorState('Failed to load articles');
                  }

                  if (feedItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildBlendedFeed(feedItems);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final primaryColor = Theme.of(context).primaryColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Daily News',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),
          BlocBuilder<AuthBloc, auth.AuthState>(
            builder: (context, state) {
              if (state is auth.Authenticated && state.user?.photoUrl != null) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/Profile'),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(
                      state.user!.photoUrl!,
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/Profile'),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF5C9A0),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlendedFeed(List<FeedItem> feedItems) {
    // Separate news and user articles
    final newsItems = feedItems.where((f) => f.isFromNewsApi).toList();
    final userItems = feedItems.where((f) => f.isUserArticle).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserArticlesBloc>().add(const LoadPublishedArticles());
      },
      child: CustomScrollView(
        slivers: [
          // Trending News Section (from NewsAPI)
          if (newsItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Breaking News',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllNews = !_showAllNews;
                        });
                      },
                      child: Text(
                        _showAllNews ? 'Show Less' : 'See All',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showAllNews)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= newsItems.length) return null;
                    final item = newsItems[index];
                    return _buildNewsListTile(item);
                  },
                  childCount: newsItems.length,
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: newsItems.length > 10 ? 10 : newsItems.length,
                    itemBuilder: (context, index) {
                      final item = newsItems[index];
                      return _buildNewsCard(item);
                    },
                  ),
                ),
              ),
          ],
          // Community Articles Header
          if (userItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Community Stories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/MyArticles');
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Featured community article
            if (userItems.isNotEmpty)
              SliverToBoxAdapter(
                child: FeaturedArticleCard(
                  article: userItems.first.userArticle!,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/UserArticleDetail',
                      arguments: userItems.first.userArticle,
                    );
                  },
                ),
              ),
            // Community article list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final articleIndex = index + 1;
                  if (articleIndex >= userItems.length) {
                    return null;
                  }
                  final item = userItems[articleIndex];
                  return Column(
                    children: [
                      ArticleListCard(
                        article: item.userArticle!,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/UserArticleDetail',
                            arguments: item.userArticle,
                          );
                        },
                      ),
                      if (articleIndex < userItems.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                },
                childCount: userItems.length > 1 ? userItems.length - 1 : 0,
              ),
            ),
          ],
          // If only news articles, show them in a list too
          if (userItems.isEmpty && newsItems.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= newsItems.length) return null;
                  final item = newsItems[index];
                  return _buildNewsListTile(item);
                },
                childCount: newsItems.length,
              ),
            ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(FeedItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).cardTheme.color : Colors.white;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        if (item.newsArticle != null) {
          Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: item.newsArticle,
          );
        }
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      height: 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.article, size: 40),
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.source.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsListTile(FeedItem item) {
    return ListTile(
      onTap: () {
        if (item.newsArticle != null) {
          Navigator.pushNamed(
            context,
            '/ArticleDetails',
            arguments: item.newsArticle,
          );
        }
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: item.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: item.imageUrl!,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              )
            : Container(
                width: 80,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.article),
              ),
      ),
      title: Text(
        item.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.authorName,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No articles yet',
            style: TextStyle(
              fontSize: 18,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to publish an article!',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context
                  .read<UserArticlesBloc>()
                  .add(const LoadPublishedArticles());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyArticlesPlaceholder() {
    // This will be replaced by actual navigation
    return const Center(
      child: Text('My Articles - Use navigation'),
    );
  }

  Widget _buildProfilePlaceholder() {
    // This will be replaced by actual navigation
    return const Center(
      child: Text('Profile - Use navigation'),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.bookmark_outline, 'My Articles', 1),
              _buildNavItem(Icons.person_outline, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    final primaryColor = Theme.of(context).primaryColor;
    final inactiveColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.pushNamed(context, '/MyArticles');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/Profile');
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _getFilledIcon(icon) : icon,
              color: isSelected ? primaryColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData icon) {
    if (icon == Icons.home) return Icons.home;
    if (icon == Icons.bookmark_outline) return Icons.bookmark;
    if (icon == Icons.person_outline) return Icons.person;
    return icon;
  }
}
