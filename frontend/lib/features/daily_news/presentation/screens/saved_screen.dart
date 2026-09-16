import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Bookmarks kept on this device. Swipe a row left to remove it; the
/// snackbar offers Undo for a few seconds.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<SavedArticlesCubit>();
    if (cubit.state.status == SavedStatus.initial) cubit.load();
  }

  Future<void> _remove(ArticleEntity article) async {
    final cubit = context.read<SavedArticlesCubit>();
    await cubit.remove(article);
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Removed from Saved',
      actionLabel: 'Undo',
      onAction: cubit.undoRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final userId = context.select((SessionCubit cubit) => cubit.state.user?.id);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<SavedArticlesCubit, SavedArticlesState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text('SAVED', style: AppTypography.tabTitle.copyWith(color: palette.ink))),
                      Text(
                        '${state.articles.length}'.padLeft(2, '0'),
                        style: AppTypography.numeral(34, weight: FontWeight.w900).copyWith(color: palette.primary, height: 0.9),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.articles.isEmpty
                      ? const SingleChildScrollView(
                          child: EmptyState(
                            icon: Icons.bookmark_rounded,
                            title: 'Keep stories for later',
                            message: "When you're reading an article, tap Save at the bottom "
                                'of the screen. It will appear here.',
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.xxl),
                            itemCount: state.articles.length,
                            separatorBuilder: (_, _) => const Divider(),
                            itemBuilder: (context, index) {
                              final article = state.articles[index];
                              return Dismissible(
                                key: ValueKey('saved-${article.id}'),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _remove(article),
                                background: Container(
                                  color: palette.primary,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: AppSpacing.screenMargin),
                                  child: Text('REMOVE', style: AppTypography.navLabel.copyWith(color: palette.background, fontSize: 11)),
                                ),
                                child: ColoredBox(
                                  color: palette.background,
                                  child: FeedItem(
                                    article: article,
                                    isOwn: article.isOwnedBy(userId),
                                    thumbnailLeft: true,
                                    onTap: () => context.pushReader(article),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
