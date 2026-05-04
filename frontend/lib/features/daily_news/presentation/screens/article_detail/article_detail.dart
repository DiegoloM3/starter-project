import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_article_by_id.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/is_article_saved.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;
  final JournalistArticleEntity? communityArticle;
  final String? communityArticleId;

  const ArticleDetailsView({
    super.key,
    this.article,
    this.communityArticle,
    this.communityArticleId,
  });

  @override
  Widget build(BuildContext context) {
    if (communityArticle != null) {
      return _CommunityArticleDetail(article: communityArticle!);
    }
    if (communityArticleId != null) {
      return _CommunityArticleByIdLoader(articleId: communityArticleId!);
    }
    if (article == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleDetailNotFound),
        ),
      );
    }
    return _NewsArticleDetail(article: article!);
  }

  static final _dateFormat = DateFormat('MMM d, y · h:mm a');

  static String _formatPublishedAt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return _dateFormat.format(parsed.toLocal());
  }
}

class _NewsArticleDetail extends HookWidget {
  final ArticleEntity article;

  const _NewsArticleDetail({required this.article});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isSaved = useState<bool>(false);

    useEffect(() {
      // Anon users always see the FAB; the tap handler bounces them to
      // /login. Skip the existence check for them.
      if (authState is! AuthAuthenticated) {
        isSaved.value = false;
        return null;
      }
      var cancelled = false;
      sl<IsArticleSavedUseCase>().call(params: article).then((value) {
        if (!cancelled) isSaved.value = value;
      });
      return () => cancelled = true;
    }, [article.url, authState.runtimeType]);

    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).articleNewsApiTitle),
          leading: Builder(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              child: const Icon(Ionicons.chevron_back, color: Colors.black),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _TitleAndDate(article: article),
              _ArticleImage(url: article.urlToImage),
              _ArticleDescription(article: article),
            ],
          ),
        ),
        // To unsave, the user goes to /saved and swipes the row.
        floatingActionButton: isSaved.value
            ? null
            : Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () => _onSavePressed(context, isSaved),
                  child:
                      const Icon(Ionicons.bookmark, color: Colors.white),
                ),
              ),
      ),
    );
  }

  void _onSavePressed(BuildContext context, ValueNotifier<bool> isSaved) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final returnTo = Uri.encodeComponent(
        GoRouterState.of(context).uri.toString(),
      );
      context.push('/login?return=$returnTo');
      return;
    }

    context.read<LocalArticleBloc>().add(SaveArticle(article));
    isSaved.value = true; // optimistic

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(AppLocalizations.of(context).articleSavedSuccess),
      ),
    );
  }
}

class _TitleAndDate extends StatelessWidget {
  final ArticleEntity article;
  const _TitleAndDate({required this.article});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title ?? '',
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                ArticleDetailsView._formatPublishedAt(article.publishedAt),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  final String? url;
  const _ArticleImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: Image.network(url ?? '', fit: BoxFit.cover),
    );
  }
}

class _ArticleDescription extends StatelessWidget {
  final ArticleEntity article;
  const _ArticleDescription({required this.article});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        '${article.description ?? ''}\n\n${article.content ?? ''}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class _CommunityArticleByIdLoader extends HookWidget {
  final String articleId;

  const _CommunityArticleByIdLoader({required this.articleId});

  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(
      () => sl<WatchArticleByIdUseCase>().call(params: articleId),
      [articleId],
    );
    final snapshot = useStream(stream);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (snapshot.hasError) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleDetailLoadError),
        ),
      );
    }
    final article = snapshot.data;
    if (article == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).articleDetailNotFound),
        ),
      );
    }
    return _CommunityArticleDetail(article: article);
  }
}

class _CommunityArticleDetail extends StatelessWidget {
  final JournalistArticleEntity article;

  const _CommunityArticleDetail({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).articleCommunityTitle),
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              context.canPop() ? context.pop() : context.go('/'),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              SizedBox(
                width: double.maxFinite,
                height: 250,
                child: Image.network(article.urlToImage, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Butler',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.userDisplayName,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Ionicons.time_outline, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y · h:mm a')
                            .format(article.publishedAt.toLocal()),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${article.description}\n\n${article.content}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
