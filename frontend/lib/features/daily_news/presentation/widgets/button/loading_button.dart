import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/button_type.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.isLoading,
    this.type = ButtonType.normal,
    this.leftIcon,
  });

  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final ButtonType type;
  final IconData? leftIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = type.getButtonStyle(theme);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: Dimens.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(Dimens.s),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            border: Border.all(width: 2.0, color: style.borderColor),
          ),
          child: isLoading
              ? FittedBox(
                  child: CircularProgressIndicator(color: style.textColor),
                )
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leftIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: Dimens.s),
                        child: Icon(leftIcon, color: style.textColor),
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
