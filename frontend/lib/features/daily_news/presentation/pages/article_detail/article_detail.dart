import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../../../user_articles/presentation/bloc/article_detail/tts_cubit.dart';
import '../../../../user_articles/presentation/bloc/article_detail/tts_state.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content =
        '${article?.description ?? ''}\n\n${article?.content ?? ''}';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LocalArticleBloc>()),
        BlocProvider(create: (_) => sl<TtsCubit>()..prepareText(content)),
      ],
      child: _ArticleDetailContent(article: article),
    );
  }
}

class _ArticleDetailContent extends StatelessWidget {
  final ArticleEntity? article;

  const _ArticleDetailContent({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildArticleHeader(context),
                    _buildAuthorSection(context),
                    _buildContent(context),
                    const SizedBox(height: 100), // Space for TTS player
                  ],
                ),
              ),
            ],
          ),
          _buildTtsPlayer(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link, color: Colors.white, size: 20),
          ),
          onPressed: () => _openSourceUrl(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            article?.urlToImage != null
                ? CachedNetworkImage(
                    imageUrl: article!.urlToImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.image, size: 64, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // News badge
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEWS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeader(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Text(
        article?.title ?? '',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    final readTime = _calculateReadTime(article?.content);
    final publishedDate = _formatDate(article?.publishedAt);
    final authorName = article?.author;
    final authorInitial = (authorName != null && authorName.isNotEmpty)
        ? authorName.substring(0, 1).toUpperCase()
        : 'N';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF5C9A0),
            child: Text(
              authorInitial,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (authorName != null && authorName.isNotEmpty)
                      ? authorName
                      : 'News Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$readTime min read • $publishedDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final primaryColor = Theme.of(context).primaryColor;

    final description = article?.description ?? '';
    final content = article?.content ?? '';
    final fullContent = '$description\n\n$content';

    if (fullContent.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No content available',
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      );
    }

    // Split content into paragraphs
    final paragraphs = fullContent.split('\n\n');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: paragraphs.asMap().entries.map((entry) {
          final index = entry.key;
          final paragraph = entry.value.trim();

          if (paragraph.isEmpty) return const SizedBox.shrink();

          // Check if it's a quote (starts with "")
          if (paragraph.startsWith('"') && paragraph.endsWith('"')) {
            return _buildQuote(paragraph, textColor, primaryColor);
          }

          // First paragraph with drop cap
          if (index == 0) {
            return _buildFirstParagraph(paragraph, textColor);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              paragraph,
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: textColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFirstParagraph(String text, Color textColor) {
    if (text.isEmpty) return const SizedBox.shrink();

    final firstLetter = text.substring(0, 1);
    final restOfText = text.substring(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: firstLetter,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 0.8,
              ),
            ),
            TextSpan(
              text: restOfText,
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuote(String text, Color textColor, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          height: 1.6,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTtsPlayer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final progressBgColor = isDark ? Colors.grey[700] : Colors.grey[200];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: BlocBuilder<TtsCubit, TtsState>(
        builder: (context, state) {
          if (!state.isAvailable) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
            child: Row(
              children: [
                // Play/Pause button
                GestureDetector(
                  onTap: () {
                    context.read<TtsCubit>().togglePlayPause();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Voice reading label and progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VOICE READING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: progressBgColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Time display
                Text(
                  '${state.formattedPosition} / ${state.formattedDuration}',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                // Close button
                IconButton(
                  icon: Icon(Icons.close, color: secondaryTextColor, size: 20),
                  onPressed: () {
                    context.read<TtsCubit>().stop();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateReadTime(String? content) {
    if (content == null || content.isEmpty) return 1;
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 99);
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final currentYear = DateTime.now().year;
      final formattedDate = '${months[dateTime.month - 1]} ${dateTime.day}';

      if (dateTime.year != currentYear) {
        return '$formattedDate, ${dateTime.year}';
      }
      return formattedDate;
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _openSourceUrl(BuildContext context) async {
    final sourceUrl = article?.url;
    if (sourceUrl == null || sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No source URL available for this article'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final uri = Uri.parse(sourceUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
