import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Square "+" button of the home screen that opens the publishing screen.
class AddArticleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddArticleButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Publish an article',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.lilac,
          borderRadius: AppRadius.standard,
          boxShadow: AppShadows.floatingButton,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.standard,
            onTap: onPressed,
            // An icon instead of the "+" character of the font, whose glyph
            // sits below the center of its line.
            child: const Center(
              child: Icon(Icons.add, size: 30, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
