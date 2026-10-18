import 'package:flutter/material.dart';

import '../../../domain/entities/article_topic.dart';
import '../topic_names.dart';
import 'field_error_text.dart';

/// Chips to choose up to [maxTopics] topics. Once the limit is reached, the rest are disabled.
class TopicSelector extends StatelessWidget {
  final Set<ArticleTopic> selectedTopics;
  final int maxTopics;
  final ValueChanged<Set<ArticleTopic>> onChanged;
  final String? errorText;

  const TopicSelector({
    super.key,
    required this.selectedTopics,
    required this.maxTopics,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temas (máximo $maxTopics)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: ArticleTopic.values.map(_buildChip).toList()),
        if (errorText != null) FieldErrorText(errorText!),
      ],
    );
  }

  Widget _buildChip(ArticleTopic topic) {
    final isSelected = selectedTopics.contains(topic);
    final canSelectMore = selectedTopics.length < maxTopics;
    return FilterChip(
      label: Text(topic.displayName),
      selected: isSelected,
      showCheckmark: false,
      onSelected: isSelected || canSelectMore ? (_) => onChanged(_toggle(topic)) : null,
    );
  }

  Set<ArticleTopic> _toggle(ArticleTopic topic) {
    final topics = {...selectedTopics};
    if (!topics.remove(topic)) topics.add(topic);
    return topics;
  }
}
