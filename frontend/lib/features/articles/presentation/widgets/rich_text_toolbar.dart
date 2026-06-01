import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:tortutip/config/theme/app_colors.dart';

class RichTextToolbar extends StatelessWidget {
  final QuillController controller;

  const RichTextToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              showBoldButton: true,
              showItalicButton: true,
              showListBullets: true,
              showLink: true,
              showQuote: true,
              showUnderLineButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: false,
              showHeaderStyle: false,
              showListNumbers: false,
              showListCheck: false,
              showCodeBlock: false,
              showIndent: false,
              showRedo: false,
              showUndo: false,
              showFontFamily: false,
              showFontSize: false,
              showDirection: false,
              showDividers: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  iconTheme: QuillIconTheme(
                    iconButtonSelectedData: IconButtonData(
                      color: AppColors.primary,
                    ),
                    iconButtonUnselectedData: IconButtonData(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
