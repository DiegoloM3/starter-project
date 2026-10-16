import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Buttons to format the text of an article: bold and subheading. A button
/// is highlighted while the cursor is on text with its format.
class FormattingToolbar extends StatelessWidget {
  final bool isBoldActive;
  final bool isSubheadingActive;
  final VoidCallback onBoldPressed;
  final VoidCallback onSubheadingPressed;

  const FormattingToolbar({
    Key? key,
    required this.onBoldPressed,
    required this.onSubheadingPressed,
    this.isBoldActive = false,
    this.isSubheadingActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          FormattingButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            isActive: isBoldActive,
            onPressed: onBoldPressed,
          ),
          const SizedBox(width: 8),
          FormattingButton(
            icon: Icons.title,
            tooltip: 'Subheading',
            isActive: isSubheadingActive,
            onPressed: onSubheadingPressed,
          ),
        ],
      ),
    );
  }
}

class FormattingButton extends StatelessWidget {
  static const double size = 36;

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  const FormattingButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.standard,
      side: BorderSide(color: isActive ? AppColors.lilac : AppColors.inputBorder),
    );
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        toggled: isActive,
        child: Material(
          color: isActive ? AppColors.lilac : Colors.transparent,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, size: 20, color: AppColors.darkText),
            ),
          ),
        ),
      ),
    );
  }
}
