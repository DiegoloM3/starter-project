import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Shown instead of the image of an article that has no image or whose image
/// cannot be loaded. It fills the space given by its parent.
class ArticleImagePlaceholder extends StatelessWidget {
  static const Color backgroundColor = AppColors.lilac;

  const ArticleImagePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Article without image',
      child: const ColoredBox(
        color: backgroundColor,
        child: Center(
          child: Icon(Ionicons.newspaperOutline, size: 40, color: AppColors.darkText),
        ),
      ),
    );
  }
}
