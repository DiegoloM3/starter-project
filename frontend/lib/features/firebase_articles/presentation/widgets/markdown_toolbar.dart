import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onImageTap;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToolButton(
            icon: Icons.format_bold,
            onTap: () => _wrapSelection('**', '**'),
          ),
          _buildToolButton(
            icon: Icons.format_italic,
            onTap: () => _wrapSelection('_', '_'),
          ),
          _buildToolButton(
            icon: Icons.title,
            onTap: () => _insertAtLineStart('## '),
          ),
          _buildToolButton(
            icon: Icons.format_list_bulleted,
            onTap: () => _insertAtLineStart('- '),
          ),
          const Spacer(),
          _buildToolButton(
            icon: Icons.photo_library_outlined,
            onTap: onImageTap,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(icon, size: 22, color: Colors.grey[800]),
      ),
    );
  }

  void _wrapSelection(String before, String after) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start == selection.end) {
      final newText = '$before$after';
      controller.text =
          text.replaceRange(selection.start, selection.end, newText);
      controller.selection = TextSelection.collapsed(
        offset: selection.start + before.length,
      );
    } else {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = '$before$selectedText$after';
      controller.text =
          text.replaceRange(selection.start, selection.end, newText);
      controller.selection = TextSelection.collapsed(
        offset: selection.start + newText.length,
      );
    }
  }

  void _insertAtLineStart(String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final cursorPos = selection.start;

    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    controller.text = text.replaceRange(lineStart, lineStart, prefix);
    controller.selection = TextSelection.collapsed(
      offset: cursorPos + prefix.length,
    );
  }
}
