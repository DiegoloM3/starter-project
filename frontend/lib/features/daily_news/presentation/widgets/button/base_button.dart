import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/button_size.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/button_type.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.text,
    required this.onTap,
    this.type = ButtonType.normal,
    this.size = ButtonSize.large,
    this.leftIcon,
    this.leftSvgPath,
  }) : assert(leftIcon == null || leftSvgPath == null,
            'leftIcon and svgPath cannot both be provided');

  final String text;
  final VoidCallback onTap;
  final ButtonType type;
  final ButtonSize size;
  final IconData? leftIcon;
  final String? leftSvgPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = type.getButtonStyle(theme);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: size.isSmall ? null : Alignment.center,
          padding: size.isSmall
              ? const EdgeInsets.symmetric(
                  horizontal: Dimens.l,
                  vertical: Dimens.s,
                )
              : const EdgeInsets.all(Dimens.buttonPadding),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            border: Border.all(width: 2.0, color: style.borderColor),
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
          ),
          child: Row(
            mainAxisSize: size.isSmall ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leftIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: Dimens.s),
                  child: Icon(leftIcon, color: style.textColor),
                ),
              if (leftSvgPath != null)
                Padding(
                  padding: const EdgeInsets.only(right: Dimens.s),
                  child: SvgPicture.asset(
                    leftSvgPath!,
                    colorFilter: ColorFilter.mode(
                      style.textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: style.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
