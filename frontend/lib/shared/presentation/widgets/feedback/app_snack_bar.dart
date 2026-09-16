import 'dart:async';

import 'package:flutter/material.dart';

/// Shows the app's snackbar: ink background, floating above the bottom bar,
/// optional action in the accent colour. It leaves on its own after three
/// seconds; nothing in the app needs a notice to linger.
///
/// Material keeps a snackbar with an action on screen for as long as an
/// accessibility service is running (`accessibleNavigation`), which many
/// phones report even when nobody uses one, so the app closes it itself.
void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
  if (actionLabel != null) {
    final timer = Timer(duration, controller.close);
    controller.closed.then((_) => timer.cancel());
  }
}
