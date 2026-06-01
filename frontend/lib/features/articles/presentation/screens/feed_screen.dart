import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/presentation/bloc/feed/feed_cubit.dart';
import 'package:tortutip/features/articles/presentation/bloc/feed/feed_state.dart';
import 'package:tortutip/features/articles/presentation/widgets/feed_card_stack.dart';
import 'package:tortutip/features/articles/presentation/widgets/feed_para_ti_chip.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_app_bar.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final FeedCubit _cubit;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<FeedCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _userId = authState.user.id;
        _cubit.loadFeed(_userId!);
      }
    });
  }

  // Llamado por AppShell cuando este tab vuelve a ser visible
  void refreshIfNeeded() => _cubit.refresh();

  @override
  void dispose() {
    // FeedCubit es singleton — no se cierra aquí
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: TortuAppBar(
          title: AppLocalizations.of(context).feedTitle,
          avatarUrl: context.select<AuthBloc, String?>(
            (b) => b.state is AuthAuthenticated
                ? (b.state as AuthAuthenticated).user.avatarUrl
                : null,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              const Center(child: FeedParaTiChip()),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: BlocBuilder<FeedCubit, FeedState>(
                  builder: (context, state) {
                    final l10n = AppLocalizations.of(context);
                    if (state is FeedInitial || state is FeedLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is FeedLoaded) {
                      if (state.articles.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.feedNoArticles,
                            style: AppTypography.body
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      if (state.currentIndex >= state.articles.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.feedReadAll,
                                  style: AppTypography.h3,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  l10n.feedReadAllSubtitle,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                TortuPrimaryButton(
                                  label: l10n.feedStartOver,
                                  onTap: _cubit.shuffleAndRestart,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: FeedCardStack(
                          articles: state.articles,
                          currentIndex: state.currentIndex,
                          savedArticleIds: state.savedArticleIds,
                          categoryNameResolver: state.categoryName,
                          onSwipe: _cubit.onSwipe,
                          onBookmark: _cubit.toggleBookmark,
                        ),
                      );
                    }

                    if (state is FeedLoadingMore) {
                      return Center(
                        child: FeedCardStack(
                          articles: state.articles,
                          currentIndex: state.currentIndex,
                          savedArticleIds: const {},
                          categoryNameResolver: (_) => '',
                          onSwipe: () {},
                          onBookmark: (_) {},
                        ),
                      );
                    }

                    if (state is FeedError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              style: AppTypography.body
                                  .copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenHorizontal,
                              ),
                              child: TortuSecondaryButton(
                                label: l10n.feedRetry,
                                onTap: _userId != null
                                    ? () => _cubit.loadFeed(_userId!)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
