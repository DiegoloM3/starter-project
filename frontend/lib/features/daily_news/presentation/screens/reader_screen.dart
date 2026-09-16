import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/listen/listen_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reader_lens/reader_lens_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/delete_article_dialog.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_bottom_bar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_hero.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_lens_bar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_lens_body.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// Full article. Text size follows the Settings preference and the bar's
/// A− / A+ buttons change that same preference.
class ReaderScreen extends StatefulWidget {
  final ArticleEntity article;

  const ReaderScreen({super.key, required this.article});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final ListenCubit _listen;

  @override
  void initState() {
    super.initState();
    _listen = context.read<ListenCubit>();
  }

  @override
  void dispose() {
    // Leaving the article silences the voice; the cubit outlives this screen.
    _listen.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReaderLensCubit>(param1: widget.article),
      child: ReaderView(article: widget.article),
    );
  }
}

class ReaderView extends StatefulWidget {
  final ArticleEntity article;

  const ReaderView({super.key, required this.article});

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  final ScrollController _scroll = ScrollController();

  /// How far down the article the reader is, 0..1, for the red bar on top.
  final ValueNotifier<double> _progress = ValueNotifier(0);

  ArticleEntity get article => widget.article;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    _progress.value = max <= 0 ? 0 : (_scroll.offset / max).clamp(0, 1);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<void> _delete(BuildContext context) async {
    final myArticles = context.read<MyArticlesCubit>();
    final feed = context.read<FeedCubit>();
    final navigator = Navigator.of(context);
    final confirmed = await DeleteArticleDialog.show(context, title: article.title);
    if (!confirmed || !context.mounted) return;
    final deleted = await myArticles.delete(article);
    if (!context.mounted) return;
    if (deleted) {
      feed.refresh();
      navigator.pop();
    } else if (myArticles.state.failure case final failure?) {
      showAppSnackBar(context, FailureMessageFormatter.of(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final userId = context.select((SessionCubit cubit) => cubit.state.user?.id);
    final isOwn = article.isOwnedBy(userId);
    final isSaved = context.select((SavedArticlesCubit cubit) => cubit.isSaved(article.id));
    final speechRate = context.select((SettingsCubit cubit) => cubit.state.settings.speechRate);
    final isListening = context.select((ListenCubit cubit) => cubit.isReading(article.id) && cubit.state.isSpeaking);
    final lens = context.watch<ReaderLensCubit>().state;

    final rule = BorderSide(color: palette.outlineStrong, width: AppRules.strong);
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ListView(
            controller: _scroll,
            padding: EdgeInsets.zero,
            children: [
              ReaderHero(article: article),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CategoryLabel(category: article.category),
                        if (isOwn) const YouBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(article.title, style: AppTypography.readerTitle.copyWith(color: palette.ink)),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(border: Border(bottom: rule)),
                      child: Row(
                        children: [
                          UserAvatar(name: article.author, size: 36, isCurrentUser: true),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOwn ? '${article.author} (you)' : article.author,
                                  style: AppTypography.label.copyWith(
                                    color: palette.ink,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${RelativeTimeFormatter.published(article.publishedAt)} · '
                                          '${article.readingTimeMinutes} min read'
                                      .toUpperCase(),
                                  style: AppTypography.caption.copyWith(color: palette.inkSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ReaderLensBar(
                active: lens.active,
                loading: lens.loading,
                onToggle: context.read<ReaderLensCubit>().toggle,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.xl, AppSpacing.screenMargin, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lens.failure case final failure?) ...[
                      Text(
                        FailureMessageFormatter.of(failure),
                        style: AppTypography.caption.copyWith(color: palette.error),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    ReaderLensBody(
                      original: article.content,
                      result: lens.current,
                      isLoading: lens.isLoading,
                    ),
                    SizedBox(height: AppSizes.readerBar + MediaQuery.paddingOf(context).bottom + AppSpacing.huge),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: AppRules.indicator,
                backgroundColor: palette.outline,
                color: palette.primary,
              ),
            ),
          ),
          if (isOwn)
            Positioned(
              top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
              right: AppSpacing.lg,
              child: MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.pushPublish(article: article),
                    child: const Text('Edit article'),
                  ),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.delete_outline_rounded, color: palette.error),
                    onPressed: () => _delete(context),
                    child: Text('Delete article', style: TextStyle(color: palette.error)),
                  ),
                ],
                builder: (context, controller, _) => LabeledIconButton(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  backgroundColor: palette.glass,
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            left: AppSpacing.lg,
            child: LabeledIconButton.back(
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: palette.glass,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ReaderBottomBar(
        isSaved: isSaved,
        isListening: isListening,
        onListen: () => context.read<ListenCubit>().toggle(
              id: article.id,
              text: '${article.title}. ${lens.current?.spokenText ?? article.content}',
              rate: speechRate.multiplier,
            ),
        onSave: () {
          HapticFeedback.lightImpact();
          context.read<SavedArticlesCubit>().toggle(article);
        },
        onSmallerText: context.read<SettingsCubit>().decreaseTextSize,
        onLargerText: context.read<SettingsCubit>().increaseTextSize,
      ),
    );
  }
}
