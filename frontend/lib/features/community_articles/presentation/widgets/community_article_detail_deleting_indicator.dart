import 'package:flutter/material.dart';

class CommunityArticleDetailDeletingIndicator extends StatelessWidget {
  const CommunityArticleDetailDeletingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
