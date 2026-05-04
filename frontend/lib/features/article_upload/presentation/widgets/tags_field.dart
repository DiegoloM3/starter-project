import 'package:flutter/material.dart';

class TagsField extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final int maxTags;

  const TagsField({
    super.key,
    required this.tags,
    required this.onChanged,
    this.maxTags = 10,
  });

  @override
  State<TagsField> createState() => _TagsFieldState();
}

class _TagsFieldState extends State<TagsField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
      _addTag(_controller.text);
    }
  }

  void _addTag(String input) {
    final parts =
        input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final current = List<String>.from(widget.tags);
    var changed = false;
    for (final tag in parts) {
      if (current.length >= widget.maxTags) break;
      if (!current.contains(tag)) {
        current.add(tag);
        changed = true;
      }
    }
    if (changed) {
      widget.onChanged(current);
    }
    _controller.clear();
  }

  void _onTextChanged(String value) {
    if (value.endsWith(',')) {
      _addTag(value);
    }
  }

  void _removeTag(String tag) {
    final updated = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final atMax = widget.tags.length >= widget.maxTags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.tags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _removeTag(tag),
            );
          }).toList(),
        ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !atMax,
          decoration: InputDecoration(
            hintText: atMax
                ? 'Max ${widget.maxTags} tags reached'
                : 'Add tags (comma-separated)',
            helperText: 'At least one tag required',
          ),
          onChanged: _onTextChanged,
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
