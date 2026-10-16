import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Full width "Publish Article" bar anchored to the bottom of the screen.
class PublishArticleBar extends StatelessWidget {
  final VoidCallback onPressed;

  const PublishArticleBar({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lilac,
        borderRadius: AppRadius.standard,
        boxShadow: AppShadows.raisedButton,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.standard,
          onTap: onPressed,
          child: Padding(
            // The bar also covers the system navigation area, so its content
            // is centered in the whole visible bar.
            padding: EdgeInsets.symmetric(vertical: 24 + bottomInset / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/publish_article.svg', width: 36, height: 36),
                const SizedBox(width: 18),
                const Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Publish Article',
                      style: TextStyle(
                        fontFamily: AppFonts.inter,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 32 * 0.04,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
