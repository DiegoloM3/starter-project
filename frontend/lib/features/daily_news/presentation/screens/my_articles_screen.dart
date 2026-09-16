import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/delete_article_dialog.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/my_article_row.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

/// Everything the signed-in journalist has published, with Edit and Delete.
class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<MyArticlesCubit>();
    if (cubit.state.status == MyArticlesStatus.initial) cubit.load();
  }

  Future<void> _delete(ArticleEntity article) async {
    final myArticles = context.read<MyArticlesCubit>();
    final feed = context.read<FeedCubit>();
    final confirmed = await DeleteArticleDialog.show(context, title: article.title);
    if (!confirmed) return;
    final deleted = await myArticles.delete(article);
    if (!mounted) return;
    if (deleted) {
      showAppSnackBar(context, 'Article deleted');
      feed.refresh();
    } else if (myArticles.state.failure case final failure?) {
      showAppSnackBar(context, FailureMessageFormatter.of(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final authorName = context.select((SessionCubit cubit) => cubit.state.user?.preferredName ?? '');
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushPublish(),
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text('WRITE'),
      ),
      body: SafeArea(
        child: BlocBuilder<MyArticlesCubit, MyArticlesState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: LabeledIconButton.back(onPressed: () => Navigator.of(context).pop()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.sm, AppSpacing.screenMargin, AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text('MY ARTICLES', style: AppTypography.tabTitle.copyWith(color: palette.ink))),
                      if (state.status == MyArticlesStatus.loaded)
                        Text(
                          '${state.articles.length}'.padLeft(2, '0'),
                          style: AppTypography.numeral(34, weight: FontWeight.w900).copyWith(color: palette.primary, height: 0.9),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _body(context, state, authorName)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, MyArticlesState state, String authorName) {
    final palette = context.palette;
    return switch (state.status) {
      MyArticlesStatus.initial || MyArticlesStatus.loading => const SkeletonArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenMargin),
            child: Column(
              children: [
                SkeletonBox(height: 96),
                SizedBox(height: AppSpacing.lg),
                SkeletonBox(height: 96),
              ],
            ),
          ),
        ),
      MyArticlesStatus.failure => SingleChildScrollView(
          child: EmptyState(
            glyph: '!',
            title: "Couldn't load your articles",
            message: FailureMessageFormatter.of(state.failure!),
            action: PrimaryButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: context.read<MyArticlesCubit>().load,
            ),
          ),
        ),
      MyArticlesStatus.loaded when state.articles.isEmpty => SingleChildScrollView(
          child: EmptyState(
            glyph: '¶',
            title: 'Your byline starts here',
            message: 'Everything you publish appears in the feed under the name $authorName.',
            action: PrimaryButton(
              label: 'Write your first article',
              icon: Icons.edit_rounded,
              onPressed: () => context.pushPublish(),
            ),
          ),
        ),
      MyArticlesStatus.loaded => Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: state.articles.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final article = state.articles[index];
              return MyArticleRow(
                article: article,
                number: index + 1,
                now: DateTime.now(),
                onTap: () => context.pushReader(article),
                onEdit: () => context.pushPublish(article: article),
                onDelete: () => _delete(article),
              );
            },
          ),
        ),
    };
  }
}
