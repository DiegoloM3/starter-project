import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    required this.body,
    this.text,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.onTapGoBack,
  });

  final String? text;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final FloatingActionButton? floatingActionButton;
  final VoidCallback? onTapGoBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        onTapGoBack?.call();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            text ?? '',
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          leading: leading,
          actions: actions,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }

  factory BaseScaffold.withBackNavigation({
    required Widget body,
    String? text,
    VoidCallback? onTapGoBack,
    List<Widget>? actions,
    FloatingActionButton? floatingActionButton,
  }) =>
      BaseScaffold(
        text: text,
        actions: actions,
        onTapGoBack: () => onTapGoBack != null ? onTapGoBack() : null,
        leading: Builder(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.chevron_left, color: Colors.black),
          ),
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      );
}
