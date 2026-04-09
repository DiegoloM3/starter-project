import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/text_field_type.dart';

enum BaseTextFieldType {
  normal,
  password,
  textArea,
  inlineTextArea;

  bool get isPassword => this == BaseTextFieldType.password;
  bool get isTextArea => this == BaseTextFieldType.textArea;
  bool get isInlineTextArea => this == BaseTextFieldType.inlineTextArea;
}

class BaseTextField extends StatefulWidget {
  const BaseTextField({
    super.key,
    required this.hint,
    this.enabled = true,
    this.isLoading = false,
    this.icon,
    this.errorText,
    this.controller,
    this.textType = BaseTextFieldType.normal,
    this.onSubmitted,
    this.onTapIcon,
    this.type = TextFieldType.initial,
    this.prefixText,
    this.textStyle,
    this.maxLines,
    this.maxLength,
  }) : assert(
          !((textType == BaseTextFieldType.normal ||
                  textType == BaseTextFieldType.password) &&
              maxLines != null),
          'maxLines cannot be used with BaseTextFieldType.textArea or BaseTextFieldType.inlineTextArea',
        );

  final String hint;
  final bool enabled;
  final TextFieldType type;
  final bool isLoading;

  final IconData? icon;
  final String? errorText;
  final TextEditingController? controller;
  final BaseTextFieldType textType;
  final Function(String value)? onSubmitted;
  final VoidCallback? onTapIcon;
  final String? prefixText;
  final TextStyle? textStyle;
  final int? maxLines;
  final int? maxLength;

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}

class _BaseTextFieldState extends State<BaseTextField> {
  bool _isHide = false;
  static const _loadingSize = 20.0;
  static const _loadingPadding = 12.0;
  static const _borderSize = 2.0;

  @override
  void initState() {
    setState(() {
      _isHide = widget.textType.isPassword;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.type.getStyle(Theme.of(context));

    return TextField(
      controller: widget.controller,
      obscureText: _isHide,
      enableSuggestions: !widget.textType.isPassword,
      autocorrect: !widget.textType.isPassword,
      onSubmitted: widget.onSubmitted,
      minLines: widget.textType.isTextArea && !widget.type.isNone ? 3 : 1,
      maxLines: widget.textType.isTextArea || widget.textType.isInlineTextArea
          ? widget.maxLines
          : 1,
      maxLength: widget.maxLength,
      style: widget.textStyle,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixText: widget.prefixText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabled: widget.enabled,
        suffixIcon: widget.isLoading
            ? const Padding(
                padding: EdgeInsets.all(_loadingPadding),
                child: SizedBox(
                  width: _loadingSize,
                  height: _loadingSize,
                  child: CircularProgressIndicator(strokeWidth: _borderSize),
                ),
              )
            : GestureDetector(
                onTap: _onTap,
                child: Icon(_iconData, color: style.iconColor),
              ),
        border: OutlineInputBorder(
          borderSide: style.borderColor != Colors.transparent
              ? BorderSide(color: style.borderColor, width: _borderSize)
              : BorderSide.none,
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.cardRadius),
          ),
        ),
        filled: true,
        fillColor: style.backgroundColor,
        errorText: widget.errorText,
        errorMaxLines: 6,
      ),
    );
  }

  void _onTap() {
    if (widget.textType.isPassword) {
      setState(() {
        _isHide = !_isHide;
      });
    } else {
      widget.onTapIcon?.call();
    }
  }

  IconData? get _iconData {
    if (widget.textType.isPassword) {
      return _isHide ? Icons.visibility_off : Icons.visibility;
    } else {
      return widget.icon;
    }
  }
}
