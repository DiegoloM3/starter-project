import 'package:flutter/material.dart';

/// Markdown composer for comments. Mirrors the article editor's content
/// field: raw markdown in, stored untouched, rendered by `GptMarkdown`
/// in [CommentTile].
/// Reusable input row for posting a comment.
class CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isPosting;
  final ValueChanged<String> onPost;

  const CommentComposer({
    super.key,
    required this.controller,
    required this.onPost,
    this.isPosting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          enabled: !isPosting,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: const InputDecoration(
            hintText: 'Write a comment... (markdown supported)',
            hintStyle: TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 14,
            ),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLines: null,
          minLines: 2,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: isPosting ? null : () => onPost(controller.text),
            child: isPosting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ),
      ],
    );
  }
}
