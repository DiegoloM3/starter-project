import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/widgets/markdown_auto_preview.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/text_field_type.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class BaseMarkdownTextField extends StatefulWidget {
  const BaseMarkdownTextField({
    super.key,
    required this.hint,
    this.enabled = true,
    this.textType = TextFieldType.initial,
    this.controller,
    this.textStyle,
    this.maxLines,
    this.errorText,
  });

  final String hint;
  final bool enabled;
  final TextFieldType textType;

  final TextEditingController? controller;
  final TextStyle? textStyle;
  final int? maxLines;
  final String? errorText;

  @override
  State<BaseMarkdownTextField> createState() => _BaseMarkdownTextFieldState();
}

class _BaseMarkdownTextFieldState extends State<BaseMarkdownTextField> {
  static const _borderSize = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.textType.getStyle(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: Dimens.m,
            horizontal: Dimens.buttonPadding,
          ),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            border: style.borderColor != Colors.transparent
                ? Border.all(color: style.borderColor, width: _borderSize)
                : null,
            borderRadius: BorderRadius.circular(
              Dimens.cardRadius,
            ),
          ),
          child: MarkdownAutoPreview(
            controller: widget.controller,
            minLines: !widget.textType.isNone ? 3 : 1,
            maxLines: widget.maxLines,
            style: widget.textStyle,
            hintText: widget.hint,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              enabled: widget.enabled,
              border: InputBorder.none,
            ),
          ),
        ),
        if (widget.errorText?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: Dimens.m,
              top: Dimens.xs,
            ),
            child: Text(
              widget.errorText ?? '',
              maxLines: 6,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        Text(AppLocalizations.of(context).tap_to_start_typing),
      ],
    );
  }
}
