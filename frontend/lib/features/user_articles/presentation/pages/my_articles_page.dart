import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/user_article.dart';
import '../bloc/user_articles/user_articles_bloc.dart';
import '../bloc/user_articles/user_articles_event.dart';
import '../bloc/user_articles/user_articles_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;

class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUserArticles();
  }

  void _loadUserArticles() {
    final authState = context.read<AuthBloc>().state;
    if (authState is auth.Authenticated && authState.user?.id != null) {
      context.read<UserArticlesBloc>().add(
            LoadUserArticles(userId: authState.user!.id!),
          );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = [
        ArticleFilter.published,
        ArticleFilter.drafts,
      ][_tabController.index];

      context.read<UserArticlesBloc>().add(FilterArticles(filter: filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<UserArticlesBloc, UserArticlesState>(
        listener: (context, state) {
          if (state is UserArticlesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is UserArticlesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserArticlesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserArticlesLoaded ||
              state is UserArticlesActionInProgress) {
            final articles = state.filteredArticles ?? [];
            return _buildArticlesList(articles);
          }

          if (state is UserArticlesError) {
            return _buildErrorState(state.errorMessage);
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/ArticleEditor');
          if (result == true && mounted) {
            context.read<UserArticlesBloc>().add(const RefreshUserArticles());
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Articles',
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: primaryColor,
        unselectedLabelColor: secondaryTextColor,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Published'),
          Tab(text: 'Drafts'),
        ],
      ),
    );
  }

  Widget _buildArticlesList(List<UserArticleEntity> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserArticlesBloc>().add(const RefreshUserArticles());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: articles.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _ArticleListItem(
            article: articles[index],
            onTap: () => _onArticleTap(articles[index]),
            onEdit: () => _onEditArticle(articles[index]),
            onDelete: () => _onDeleteArticle(articles[index]),
            onPublish: articles[index].isDraft
                ? () => _onPublishArticle(articles[index])
                : null,
            onUnpublish: !articles[index].isDraft
                ? () => _onUnpublishArticle(articles[index])
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final primaryColor = Theme.of(context).primaryColor;

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
            'Start writing your first article!',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result =
                  await Navigator.pushNamed(context, '/ArticleEditor');
              if (result == true && mounted) {
                context
                    .read<UserArticlesBloc>()
                    .add(const RefreshUserArticles());
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Article'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              context.read<UserArticlesBloc>().add(const RefreshUserArticles());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _onArticleTap(UserArticleEntity article) async {
    if (article.isDraft) {
      final result = await Navigator.pushNamed(context, '/ArticleEditor',
          arguments: article);
      if (result == true && mounted) {
        context.read<UserArticlesBloc>().add(const RefreshUserArticles());
      }
    } else {
      final result = await Navigator.pushNamed(context, '/UserArticleDetail',
          arguments: article);
      if (result == true && mounted) {
        context.read<UserArticlesBloc>().add(const RefreshUserArticles());
      }
    }
  }

  void _onEditArticle(UserArticleEntity article) async {
    final result = await Navigator.pushNamed(context, '/ArticleEditor',
        arguments: article);
    if (result == true && mounted) {
      context.read<UserArticlesBloc>().add(const RefreshUserArticles());
    }
  }

  void _onDeleteArticle(UserArticleEntity article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserArticlesBloc>().add(
                    DeleteArticle(articleId: article.id!),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onPublishArticle(UserArticleEntity article) {
    context.read<UserArticlesBloc>().add(
          PublishArticle(articleId: article.id!),
        );
  }

  void _onUnpublishArticle(UserArticleEntity article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unpublish Article'),
        content: const Text(
            'This will convert your article back to a draft. It will no longer be visible to others.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserArticlesBloc>().add(
                    UnpublishArticle(articleId: article.id!),
                  );
            },
            child: const Text('Unpublish'),
          ),
        ],
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  final UserArticleEntity article;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onUnpublish;

  const _ArticleListItem({
    required this.article,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
    this.onUnpublish,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
            _buildPopupMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    final secondaryColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: secondaryColor),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          case 'publish':
            onPublish?.call();
            break;
          case 'unpublish':
            onUnpublish?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        if (onPublish != null)
          const PopupMenuItem(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.publish_outlined, size: 20),
                SizedBox(width: 12),
                Text('Publish'),
              ],
            ),
          ),
        if (onUnpublish != null)
          const PopupMenuItem(
            value: 'unpublish',
            child: Row(
              children: [
                Icon(Icons.unpublished_outlined, size: 20),
                SizedBox(width: 12),
                Text('Unpublish'),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final iconColor = isDark ? Colors.grey[600] : Colors.grey[400];

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        color: placeholderColor,
        child: article.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_outlined,
                  color: iconColor,
                ),
              )
            : Icon(
                Icons.image_outlined,
                color: iconColor,
                size: 32,
              ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final primaryColor = Theme.of(context).primaryColor;
    final draftBgColor = isDark ? Colors.grey[700] : Colors.grey[200];
    final draftTextColor = isDark ? Colors.grey[300] : Colors.grey[700];

    final timeAgo = _formatTimeAgo(
        article.updatedAt ?? article.createdAt ?? DateTime.now());
    final readTime = _calculateReadTime(article.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          article.isDraft
              ? 'Edited $timeAgo • Draft'
              : 'Saved $timeAgo • $readTime min read',
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:
                article.isDraft ? draftBgColor : primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            article.isDraft ? 'DRAFT' : 'PUBLISHED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: article.isDraft ? draftTextColor : primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week${difference.inDays > 14 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  int _calculateReadTime(String? content) {
    if (content == null || content.isEmpty) return 1;
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 99);
  }
}
