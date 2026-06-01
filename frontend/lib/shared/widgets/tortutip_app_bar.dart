import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';
import '../../features/bookmarks/presentation/bloc/bookmarks_cubit.dart';
import '../../features/bookmarks/presentation/bloc/bookmarks_state.dart';

class TortuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showTitle;
  final String? avatarUrl;
  final bool? centerTitle; 
  


  const TortuAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showTitle = true,
    this.avatarUrl,
    this.centerTitle = true,
  });

  factory TortuAppBar.main({List<Widget>? actions, String? avatarUrl}) {
    return TortuAppBar(
      title: 'TortuTip',
      actions: actions,
      avatarUrl: avatarUrl,
    );
  }

  factory TortuAppBar.detail({required String title, List<Widget>? actions}) {
    return TortuAppBar(
      title: title,
      actions: actions,
    );
  }

  bool get _isMain => title == 'TortuTip';

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      titleSpacing: _isMain ? AppSpacing.md : NavigationToolbar.kMiddleSpacing,
      leading: _isMain
          ? Center(
              child: BlocBuilder<BookmarksCubit, BookmarksState>(
                builder: (context, bookmarksState) {
                  final hasSaved = bookmarksState is BookmarksLoaded;
                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.bookmarks),
                    child: Container(
                      width: AppSpacing.avatarSizeSm,
                      height: AppSpacing.avatarSizeSm,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: AppColors.textPrimary,
                        size: AppSpacing.iconMd,
                      ),
                    ),
                  );
                },
              ),
            )
          : leading,
      title: showTitle
          ? Text(
              title ?? 'TortuTip',
              style: _isMain
                  ? AppTypography.brand
                  : AppTypography.h2,
            )
          : null,
      actions: _isMain
          ? [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: _ProfileCircle(avatarUrl: avatarUrl),
              ),
              ),
            ]
          : actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProfileCircle extends StatelessWidget {
  final String? avatarUrl;

  const _ProfileCircle({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    return CircleAvatar(
      radius: AppSpacing.avatarSizeSm / 2,
      backgroundColor: AppColors.surface,
      backgroundImage: hasImage ? NetworkImage(avatarUrl!) : null,
      child: !hasImage
          ? const Icon(
              Icons.person_outline,
              size: AppSpacing.iconMd,
              color: AppColors.textSecondary,
            )
          : null,
    );
  }
}
