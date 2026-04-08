import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SavedArticlesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SavedArticlesAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      title: const Text(
        'Saved Articles',
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
