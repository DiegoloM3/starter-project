import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reading_time_badge.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/status_change_dialog.dart';

class ArticlePreviewPage extends StatelessWidget {
  final CreateArticleState articleState;

  const ArticlePreviewPage({Key? key, required this.articleState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context, false),
          child: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Preview',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildThumbnail(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildMetadata(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildPublishBar(context),
    );
  }

  Widget _buildThumbnail() {
    if (articleState.selectedImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(articleState.selectedImagePath!),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    if (articleState.thumbnailUrl != null &&
        articleState.thumbnailUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          articleState.thumbnailUrl!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        ),
      );
    }

    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
    );
  }

  Widget _buildTitle() {
    return Text(
      articleState.title.isNotEmpty ? articleState.title : 'Untitled',
      style: const TextStyle(
        fontFamily: 'Butler',
        fontWeight: FontWeight.w900,
        fontSize: 24,
        color: Colors.black87,
        height: 1.3,
      ),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        ReadingTimeBadge(minutes: articleState.readingTimeMinutes),
        const SizedBox(width: 16),
        Icon(Icons.circle, size: 4, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          _formatDate(DateTime.now()),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (articleState.description.isEmpty) return const SizedBox.shrink();

    return Text(
      articleState.description,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      articleState.content.isNotEmpty
          ? articleState.content
          : 'No content yet.',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.7,
      ),
    );
  }

  Widget _buildPublishBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Keep Editing'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _onPublish(context),
              icon: const Icon(Icons.publish, color: Colors.white, size: 20),
              label: const Text(
                'Publish',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPublish(BuildContext context) async {
    final confirmed =
        await StatusChangeDialog.showPublishConfirmation(context);
    if (confirmed && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
