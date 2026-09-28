import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/author_avatar.dart';

/// Shared article author row: live avatar plus display name.
///
/// Deduplicates the identical row previously inlined in both the article
/// tile and the article detail view. Pure presentation: all data arrives
/// via constructor (3.4.2), no business logic, no service location.
/// Reusable author row with avatar, name, and date for article views.
class ArticleAuthorRow extends StatelessWidget {
  final String? authorId;
  final String? authorDisplayName;
  final double avatarRadius;
  final double spacing;
  final TextStyle? nameStyle;
  final AuthorAvatarCubit Function()? avatarCubitFactory;

  const ArticleAuthorRow({
    super.key,
    this.authorId,
    this.authorDisplayName,
    this.avatarRadius = 10,
    this.spacing = 6,
    this.nameStyle,
    this.avatarCubitFactory,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = authorDisplayName?.isNotEmpty == true;
    return Row(
      children: [
        AuthorAvatar(
          authorId: authorId,
          radius: avatarRadius,
          cubitFactory: avatarCubitFactory,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            hasName ? authorDisplayName! : 'Unknown author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nameStyle ??
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
          ),
        ),
      ],
    );
  }
}
