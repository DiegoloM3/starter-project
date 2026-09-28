import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';

/// Reusable row rendering one [CommentEntity] with delete affordance.
class CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final bool isOwn;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.isOwn = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 10),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = _displayName.isNotEmpty
        ? _displayName.characters.first.toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFEEEEEE),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 4),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _displayName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOwn)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Ionicons.trashOutline,
                size: 16,
                color: Colors.black45,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.black87,
      ),
      child: GptMarkdown(
        comment.content,
        onLinkTap: (url, _) => debugPrint('open $url'),
      ),
    );
  }

  String get _displayName {
    final name = comment.authorDisplayName?.trim() ?? '';
    return name.isEmpty ? 'Anonymous' : name;
  }
}
