import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:tortutip/features/articles/presentation/screens/create_article_screen.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_event.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_state.dart';
import 'package:tortutip/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/bloc/profile_state.dart';
import 'package:tortutip/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:tortutip/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:tortutip/features/profile/presentation/widgets/published_article_row.dart';
import 'package:get_it/get_it.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_app_bar.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _userId = authState.user.id;
        context.read<ProfileCubit>().loadProfile(_userId!);
      }
    });
  }

  void _openEditProfile(BuildContext context, ProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => GetIt.instance<EditProfileCubit>(),
        child: BlocListener<EditProfileCubit, EditProfileState>(
          listener: (ctx, editState) {
            if (editState is EditProfileSuccess) {
              Navigator.of(ctx).pop();
              if (_userId != null) {
                context.read<ProfileCubit>().loadProfile(_userId!);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).profileUpdated),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (editState is EditProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(editState.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: EditProfileScreen(user: state.user),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TortuAppBar(
        title: AppLocalizations.of(context).profileTitle,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (ctx, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _openEditProfile(context, state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProfileError) {
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
                  TortuSecondaryButton(
                    label: 'Reintentar',
                    onTap: _userId != null
                        ? () => context.read<ProfileCubit>().loadProfile(_userId!)
                        : null,
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _ProfileBody(
              state: state,
              userId: _userId ?? '',
              onDeleteArticle: (articleId) =>
                  context.read<ProfileCubit>().deleteArticle(articleId, _userId ?? ''),
              onViewArticle: (articleId) =>
                  context.push(AppRoutes.articlePath(articleId)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final ProfileLoaded state;
  final String userId;
  final void Function(String articleId) onDeleteArticle;
  final void Function(String articleId) onViewArticle;

  const _ProfileBody({
    required this.state,
    required this.userId,
    required this.onDeleteArticle,
    required this.onViewArticle,
  });

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  static const _pageSize = 5;
  int _visibleCount = _pageSize;

  ProfileLoaded get state => widget.state;
  String get userId => widget.userId;
  void Function(String) get onDeleteArticle => widget.onDeleteArticle;
  void Function(String) get onViewArticle => widget.onViewArticle;

  Future<void> _onRoleToggled(BuildContext context, bool isWriter) async {
    final newRole = isWriter ? 'writer' : 'reader';
    final success = await context.read<ProfileCubit>().toggleRole(userId, newRole);
    if (success && context.mounted) {
      context.read<AuthBloc>().add(const CheckAuthEvent());
      context.read<ProfileCubit>().loadProfile(userId);
    }
  }

  void _openEditArticle(BuildContext context, ArticleEntity article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.dark.withValues(alpha: 0.5),
      builder: (_) => BlocProvider(
        create: (_) => GetIt.instance<CreateArticleCubit>(),
        child: _EditArticleModal(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeaderCard(
            user: state.user,
            totalPublishedCount: state.totalPublishedCount,
            onRoleToggled: (isWriter) => _onRoleToggled(context, isWriter),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: state.publishedArticles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Center(
                        child: Text(
                          'Aún no tienes artículos publicados.',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _ArticlesList(
                      articles: state.publishedArticles,
                      visibleCount: _visibleCount,
                      state: state,
                      onViewArticle: onViewArticle,
                      onEditArticle: (article) =>
                          _openEditArticle(context, article),
                      onDeleteArticle: onDeleteArticle,
                      onShowMore: () => setState(
                        () => _visibleCount += _pageSize,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ArticlesList extends StatelessWidget {
  final List<ArticleEntity> articles;
  final int visibleCount;
  final ProfileLoaded state;
  final void Function(String) onViewArticle;
  final void Function(ArticleEntity) onEditArticle;
  final void Function(String) onDeleteArticle;
  final VoidCallback onShowMore;

  const _ArticlesList({
    required this.articles,
    required this.visibleCount,
    required this.state,
    required this.onViewArticle,
    required this.onEditArticle,
    required this.onDeleteArticle,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final visible = articles.take(visibleCount).toList();
    final hasMore = articles.length > visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
          ),
          child: Text(AppLocalizations.of(context).profileMyTips, style: AppTypography.h4),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: visible.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
            color: AppColors.border,
          ),
          itemBuilder: (_, index) {
            final article = visible[index];
            final category = state.categoryById(article.categoryId);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: PublishedArticleRow(
                article: article,
                categoryName: category?.name ?? article.categoryId,
                onTapView: () => onViewArticle(article.id),
                onTapEdit: () => onEditArticle(article),
                onTapDelete: () => onDeleteArticle(article.id),
              ),
            );
          },
        ),
        if (hasMore)
          InkWell(
            onTap: onShowMore,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppSpacing.radiusXl),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppSpacing.radiusXl),
                ),
              ),
              child: Text(
                'Ver más (${articles.length - visibleCount})',
                style: AppTypography.body.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (!hasMore) const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _EditArticleModal extends StatelessWidget {
  final ArticleEntity article;

  const _EditArticleModal({required this.article});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.9],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Center(
                          child: SizedBox(
                            width: AppSpacing.dragHandleWidth,
                            height: AppSpacing.xs,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.borderStrong,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(AppSpacing.radiusFull),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: AppSpacing.iconMd,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: CreateArticleScreen(article: article)),
              ],
            ),
          ),
        );
      },
    );
  }
}
