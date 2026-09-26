import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/presentation/formatters/article_date_formatter.dart';
import '../../../../../injection_container.dart';
import '../../../data/models/article.dart' show articleBookmarkKey;
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import 'article_detail_content.dart';

typedef CopySourceLink = Future<void> Function(String url);
typedef OpenSourceLink = Future<bool> Function(Uri url);
typedef LaunchSourceUrl = Future<bool> Function(
  Uri url, {
  required LaunchMode mode,
  String? webOnlyWindowName,
});

String? sourceLinkWindowName({required bool isWeb}) => isWeb ? '_self' : null;

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;
  final LocalArticleBloc? localArticleBloc;
  final CopySourceLink? copySourceLink;
  final OpenSourceLink? openSourceLink;
  final LaunchSourceUrl? launchSourceUrl;

  const ArticleDetailsView({
    super.key,
    this.article,
    this.localArticleBloc,
    this.copySourceLink,
    this.openSourceLink,
    this.launchSourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    final content = _ArticleDetailsContent(
      article: article,
      copySourceLink: copySourceLink,
      openSourceLink: openSourceLink,
      launchSourceUrl: launchSourceUrl,
    );
    final bloc = localArticleBloc;
    if (bloc != null) {
      return BlocProvider.value(value: bloc, child: content);
    }
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: content,
    );
  }
}

class _ArticleDetailsContent extends StatefulWidget {
  final ArticleEntity? article;
  final CopySourceLink? copySourceLink;
  final OpenSourceLink? openSourceLink;
  final LaunchSourceUrl? launchSourceUrl;

  const _ArticleDetailsContent({
    required this.article,
    required this.copySourceLink,
    required this.openSourceLink,
    required this.launchSourceUrl,
  });

  @override
  State<_ArticleDetailsContent> createState() => _ArticleDetailsContentState();
}

class _ArticleDetailsContentState extends State<_ArticleDetailsContent> {
  bool _isSaved = false;
  bool _isBookmarkBusy = true;
  _BookmarkAction? _pendingAction;

  @override
  void initState() {
    super.initState();
    context.read<LocalArticleBloc>().add(const GetSavedArticles());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocalArticleBloc, LocalArticlesState>(
      listener: _onLocalArticlesChanged,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  void _onLocalArticlesChanged(
    BuildContext context,
    LocalArticlesState state,
  ) {
    if (state is LocalArticlesDone) {
      final pendingAction = _pendingAction;
      final article = widget.article;
      final saved = article != null &&
          (state.articles ?? const <ArticleEntity>[]).any(
            (savedArticle) =>
                articleBookmarkKey(savedArticle) == articleBookmarkKey(article),
          );
      setState(() {
        _isSaved = saved;
        _isBookmarkBusy = false;
        _pendingAction = null;
      });
      if (pendingAction != null) {
        _showMessage(
          state.warning ??
              (pendingAction == _BookmarkAction.save
                  ? 'Article saved successfully.'
                  : 'Article removed from saved articles.'),
        );
      }
    } else if (state is LocalArticlesFailure) {
      final pendingAction = _pendingAction;
      setState(() {
        _isBookmarkBusy = false;
        _pendingAction = null;
      });
      _showMessage(
        pendingAction == _BookmarkAction.remove
            ? 'Unable to remove the saved article.'
            : state.message,
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final article = widget.article;
    if (article == null) {
      return const Center(child: Text('Article unavailable.'));
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(article),
          _buildArticleImage(article),
          _buildArticleDescription(article),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate(ArticleEntity article) {
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
                formatStandardDate(article.publishedAt),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage(ArticleEntity article) {
    final imageUrl = article.urlToImage ?? '';
    if (imageUrl.isEmpty) {
      return Container(
        width: double.maxFinite,
        height: 250,
        margin: const EdgeInsets.only(top: 14),
        color: const Color(0xFFF0ECFA),
        alignment: Alignment.center,
        child: const Icon(Icons.article_outlined),
      );
    }
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: Image.network(imageUrl, fit: BoxFit.cover),
    );
  }

  Widget _buildArticleDescription(ArticleEntity article) {
    final detailContent = composeArticleDetailContent(article);
    final sourceUrl = _trustedSourceUrl(article.url);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detailContent.text,
            style: const TextStyle(fontSize: 16, height: 1.45),
          ),
          if (detailContent.isExcerpt) ...[
            const SizedBox(height: 14),
            Text(
              sourceUrl == null
                  ? 'Publisher excerpt. The full article is not included in this feed.'
                  : 'Publisher excerpt. Use the source link for the full article.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (sourceUrl != null)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.icon(
                    onPressed: () => _openSourceLink(Uri.parse(sourceUrl)),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Read full article'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copySourceLink(sourceUrl),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Copy source link'),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  String? _trustedSourceUrl(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (uri.userInfo.isNotEmpty) return null;
    return uri.toString();
  }

  Future<void> _openSourceLink(Uri url) async {
    try {
      final openSourceLink = widget.openSourceLink;
      final didOpen = openSourceLink == null
          ? await (widget.launchSourceUrl ?? _launchSourceUrl)(
              url,
              mode: LaunchMode.externalApplication,
              webOnlyWindowName: sourceLinkWindowName(isWeb: kIsWeb),
            )
          : await openSourceLink(url);
      if (!didOpen && mounted) {
        _showMessage('Unable to open the source article.');
      }
    } catch (_) {
      if (mounted) _showMessage('Unable to open the source article.');
    }
  }

  Future<bool> _launchSourceUrl(
    Uri url, {
    required LaunchMode mode,
    String? webOnlyWindowName,
  }) {
    return launchUrl(
      url,
      mode: mode,
      webOnlyWindowName: webOnlyWindowName,
    );
  }

  Future<void> _copySourceLink(String url) async {
    try {
      final copySourceLink = widget.copySourceLink;
      if (copySourceLink == null) {
        await Clipboard.setData(ClipboardData(text: url));
      } else {
        await copySourceLink(url);
      }
      if (mounted) _showMessage('Source link copied.');
    } catch (_) {
      if (mounted) _showMessage('Unable to copy source link.');
    }
  }

  Widget _buildFloatingActionButton() {
    final pendingAction = _pendingAction;
    final buttonLabel = _isBookmarkBusy
        ? pendingAction == _BookmarkAction.remove
            ? 'Removing'
            : pendingAction == _BookmarkAction.save
                ? 'Saving'
                : 'Loading'
        : _isSaved
            ? 'Saved'
            : 'Save';
    final buttonTooltip = _isBookmarkBusy
        ? '$buttonLabel article'
        : _isSaved
            ? 'Saved article. Remove bookmark'
            : 'Save article';

    return Semantics(
      button: true,
      enabled: !_isBookmarkBusy && widget.article != null,
      label: buttonTooltip,
      child: FloatingActionButton(
        tooltip: buttonTooltip,
        onPressed:
            _isBookmarkBusy || widget.article == null ? null : _toggleBookmark,
        backgroundColor: const Color(0xFFE1BEDE),
        foregroundColor: Colors.black,
        child: _isBookmarkBusy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Icon(_isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded),
      ),
    );
  }

  void _toggleBookmark() {
    final article = widget.article;
    if (article == null || _isBookmarkBusy) return;
    final action = _isSaved ? _BookmarkAction.remove : _BookmarkAction.save;
    setState(() {
      _isBookmarkBusy = true;
      _pendingAction = action;
    });
    context.read<LocalArticleBloc>().add(
          action == _BookmarkAction.save
              ? SaveArticle(article)
              : RemoveArticle(article),
        );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _BookmarkAction { save, remove }
