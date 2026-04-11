import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class ExpandableSearchHeader extends StatefulWidget {
  final String title;
  final TextStyle? titleStyle;
  final Widget actions;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final String cancelLabel;
  final String searchButtonLabel;

  const ExpandableSearchHeader({
    super.key,
    required this.title,
    required this.actions,
    required this.onSearchChanged,
    required this.searchHint,
    required this.cancelLabel,
    required this.searchButtonLabel,
    this.titleStyle,
  });

  @override
  State<ExpandableSearchHeader> createState() => _ExpandableSearchHeaderState();
}

class _ExpandableSearchHeaderState extends State<ExpandableSearchHeader> {
  bool _isSearching = false;
  final _controller = TextEditingController();
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 300);
  static const _animationDuration = Duration(milliseconds: 200);

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      widget.onSearchChanged(text);
    });
  }

  void _openSearch() {
    setState(() => _isSearching = true);
  }

  void _cancelSearch() {
    _debounce?.cancel();
    _controller.clear();
    widget.onSearchChanged('');
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing8,
        AppDimensions.spacing24,
        AppDimensions.spacing16,
      ),
      child: AnimatedCrossFade(
        duration: _animationDuration,
        crossFadeState:
            _isSearching ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _buildDefaultHeader(colors),
        secondChild: _buildSearchHeader(colors),
      ),
    );
  }

  Widget _buildDefaultHeader(AppColorsExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: widget.titleStyle ??
              AppTypography.screenTitle.copyWith(color: colors.textPrimary),
        ),
        Row(
          children: [
            _SearchButton(
              onTap: _openSearch,
              semanticLabel: widget.searchButtonLabel,
            ),
            const SizedBox(width: AppDimensions.spacing10),
            widget.actions,
          ],
        ),
      ],
    );
  }

  Widget _buildSearchHeader(AppColorsExtension colors) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppDimensions.avatarDefault,
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchTextChanged,
              autofocus: true,
              style: AppTypography.label.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle:
                    AppTypography.label.copyWith(color: colors.textPlaceholder),
                prefixIcon: Icon(
                  Icons.search,
                  size: AppDimensions.iconMd,
                  color: colors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacing10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing12),
        GestureDetector(
          onTap: _cancelSearch,
          child: Text(
            widget.cancelLabel,
            style: AppTypography.pillLabel.copyWith(
              color: AppColors.accentGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;
  final String semanticLabel;

  const _SearchButton({
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppDimensions.avatarDefault,
          height: AppDimensions.avatarDefault,
          decoration: BoxDecoration(
            color: colors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Center(
            child: Icon(
              Icons.search,
              size: AppDimensions.iconMd,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
