import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Blocks the screen while a long operation is running.
class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xB3FFFFFF),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.darkText),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontFamily: AppFonts.inter, fontSize: 18, color: AppColors.darkText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
