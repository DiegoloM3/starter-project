import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';

class FieldErrorText extends StatelessWidget {
  final String message;

  const FieldErrorText(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: const TextStyle(fontFamily: AppFonts.inter, fontSize: 14, color: AppColors.error),
      ),
    );
  }
}
