import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class ArticleAvatar extends StatelessWidget {
  final double radius;
  final String text;

  const ArticleAvatar({
    super.key,
    this.radius = 20,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final String initial =
        text.isNotEmpty ? text.substring(0, 2).toUpperCase() : 'AU';
    return CircleAvatar(
      radius: radius,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
