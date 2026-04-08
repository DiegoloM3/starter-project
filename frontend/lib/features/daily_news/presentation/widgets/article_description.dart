import 'package:flutter/material.dart';

class ArticleDescription extends StatelessWidget {
  final String description;
  final String content;

  const ArticleDescription({
    Key? key,
    required this.description,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        '$description\n\n$content',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
