import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';

/// A short form that sits in the middle of the screen instead of piling up
/// against the top.
///
/// Centred **and** scrollable, which is the whole point: a plain `Center`
/// would look right on the phone it was designed on and clip the moment the
/// keyboard opens or somebody turns their system font up. Here the content is
/// centred while it fits and scrolls the instant it does not.
class CenteredForm extends StatelessWidget {
  final List<Widget> children;

  /// Kept at the bottom of the screen when there is room to spare — the
  /// "New here?" line that belongs out of the way of the form itself.
  final Widget? footer;

  const CenteredForm({super.key, required this.children, this.footer});

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(AppSpacing.xl);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - padding.vertical,
            ),
            // IntrinsicHeight gives the column a definite height, which is
            // what lets the footer be pushed down by a Spacer inside a
            // scroll view.
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  ...children,
                  const Spacer(),
                  if (footer != null) footer!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
