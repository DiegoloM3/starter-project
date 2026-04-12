import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/helpers/article_section_helper.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/dialogs/edit_profile_dialog.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_icon_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
        ),
        BlocProvider.value(value: sl<UserProfileCubit>()),
      ],
      child: Scaffold(
        backgroundColor: context.colors.bgPage,
        body: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.pop(context)),
              const Expanded(child: _ProfileContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing8,
        AppDimensions.spacing24,
        AppDimensions.spacing16,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.chevron_left,
            onPressed: onBack,
          ),
          const SizedBox(width: AppDimensions.spacing14),
          Text(
            l10n.profileTitle,
            style: AppTypography.sectionTitle.copyWith(
              color: context.colors.textPrimary,
              letterSpacing: AppDimensions.letterSpacingTight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late Future<DraftArticle?> _draftFuture;

  @override
  void initState() {
    super.initState();
    _draftFuture = sl<DraftService>().loadDraft();
  }

  void _refreshDraft() {
    setState(() {
      _draftFuture = sl<DraftService>().loadDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        final articles = state is LocalArticlesDone
            ? (state.articles ?? [])
            : <ArticleEntity>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacing24,
            AppDimensions.spacing8,
            AppDimensions.spacing24,
            AppDimensions.spacing24,
          ),
          child: Column(
            children: [
              const _AvatarSection(),
              const SizedBox(height: AppDimensions.spacing24),
              _DraftsSection(
                draftFuture: _draftFuture,
                onDraftDeleted: _refreshDraft,
                onDraftTapped: _refreshDraft,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              _ArticleListSection(
                icon: LucideIcons.bookmark,
                iconColor: AppColors.accentGreen,
                title: AppLocalizations.of(context)!.savedSection,
                count: articles.length,
                articles: articles,
                actionIcon: LucideIcons.bookmark,
                actionIconColor: AppColors.accentGreen,
                onRemoveArticle: (article) => _removeArticle(context, article),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeArticle(BuildContext context, ArticleEntity article) {
    context.read<LocalArticleBloc>().add(RemoveArticle(article));
  }
}

class _DraftsSection extends StatelessWidget {
  final Future<DraftArticle?> draftFuture;
  final VoidCallback onDraftDeleted;
  final VoidCallback onDraftTapped;

  const _DraftsSection({
    required this.draftFuture,
    required this.onDraftDeleted,
    required this.onDraftTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<DraftArticle?>(
      future: draftFuture,
      builder: (context, snapshot) {
        final draft = snapshot.data;
        final count = draft != null ? 1 : 0;

        return Column(
          children: [
            _SectionHeader(
              icon: LucideIcons.fileEdit,
              iconColor: AppColors.coral,
              title: l10n.draftsSection,
              count: count,
            ),
            const SizedBox(height: AppDimensions.spacing14),
            if (draft != null)
              _DraftCard(
                draft: draft,
                onTap: () => _openDraft(context),
                onDelete: () => _deleteDraft(context),
              )
            else
              _EmptyDrafts(message: l10n.noDrafts),
          ],
        );
      },
    );
  }

  Future<void> _openDraft(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.addNews);
    onDraftTapped();
  }

  Future<void> _deleteDraft(BuildContext context) async {
    await sl<DraftService>().clearDraft();
    onDraftDeleted();
  }
}

class _DraftCard extends StatelessWidget {
  final DraftArticle draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final sectionLabel = _resolveSectionLabel(draft.section, l10n);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: AppShadows.cardSubtle,
        ),
        child: Row(
          children: [
            Container(
              width: AppDimensions.cardImageCompact,
              height: AppDimensions.cardImageCompact,
              decoration: BoxDecoration(
                color: colors.bgInput,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(
                LucideIcons.fileEdit,
                color: colors.textPlaceholder,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    draft.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.compactTitle
                        .copyWith(color: colors.textPrimary),
                  ),
                  if (sectionLabel != null) ...[
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      sectionLabel,
                      style: AppTypography.footnote
                          .copyWith(color: colors.textPlaceholder),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                LucideIcons.trash2,
                size: AppDimensions.iconMd,
                color: AppColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveSectionLabel(String? sectionName, AppLocalizations l10n) {
    if (sectionName == null) return null;
    final match = NewsSection.values.where((s) => s.name == sectionName);
    if (match.isEmpty) return null;
    return match.first.label(l10n);
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, profile) {
        final displayName =
            profile.displayName ?? l10n.guestName;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: AppShadows.cardStandard,
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.profileAvatarSize,
                height: AppDimensions.profileAvatarSize,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _avatarInitial(displayName),
                    style: AppTypography.sectionTitle
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.userName
                          .copyWith(color: colors.textPrimary),
                    ),
                    if (profile.displayEmail.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        profile.displayEmail,
                        style: AppTypography.subtitle
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showEditProfileDialog(context, profile),
                child: Icon(
                  LucideIcons.pencil,
                  size: AppDimensions.iconLg,
                  color: colors.textPlaceholder,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _avatarInitial(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  void _showEditProfileDialog(
      BuildContext context, UserProfileState currentProfile) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        currentName: currentProfile.name ?? '',
        currentEmail: currentProfile.email ?? '',
        onSave: (name, email) {
          context.read<UserProfileCubit>().updateProfile(
                name: name,
                email: email,
              );
        },
      ),
    );
  }
}

class _EmptyDrafts extends StatelessWidget {
  final String message;

  const _EmptyDrafts({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileEdit,
            size: AppDimensions.iconSm,
            color: colors.textPlaceholder,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Text(
            message,
            style:
                AppTypography.subtitle.copyWith(color: colors.textPlaceholder),
          ),
        ],
      ),
    );
  }
}

class _ArticleListSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;
  final List<ArticleEntity> articles;
  final IconData actionIcon;
  final Color actionIconColor;
  final ValueChanged<ArticleEntity> onRemoveArticle;

  const _ArticleListSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.articles,
    required this.actionIcon,
    required this.actionIconColor,
    required this.onRemoveArticle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          icon: icon,
          iconColor: iconColor,
          title: title,
          count: count,
        ),
        const SizedBox(height: AppDimensions.spacing14),
        ...articles.map((article) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing14),
            child: _ProfileCompactCard(
              title: article.title ?? '',
              date: article.publishedAt ?? '',
              imageUrl: article.urlToImage,
              actionIcon: actionIcon,
              actionIconColor: actionIconColor,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.articleDetails,
                arguments: article,
              ),
              onActionTap: () => onRemoveArticle(article),
            ),
          );
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconMd, color: iconColor),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: Text(
            title,
            style: AppTypography.buttonLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacing4,
            horizontal: AppDimensions.spacing10,
          ),
          decoration: BoxDecoration(
            color: colors.accentGreenLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            '$count',
            style: AppTypography.badge.copyWith(
              color: AppColors.accentGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileCompactCard extends StatelessWidget {
  final String title;
  final String date;
  final String? imageUrl;
  final IconData actionIcon;
  final Color actionIconColor;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const _ProfileCompactCard({
    required this.title,
    required this.date,
    this.imageUrl,
    required this.actionIcon,
    required this.actionIconColor,
    this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: AppShadows.cardSubtle,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: SizedBox(
                width: AppDimensions.cardImageCompact,
                height: AppDimensions.cardImageCompact,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: colors.bgInput,
                          child: Icon(Icons.image_outlined,
                              color: colors.textPlaceholder),
                        ),
                      )
                    : Container(
                        color: colors.bgInput,
                        child: Icon(Icons.image_outlined,
                            color: colors.textPlaceholder),
                      ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.compactTitle
                        .copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    date,
                    style: AppTypography.footnote
                        .copyWith(color: colors.textPlaceholder),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            GestureDetector(
              onTap: onActionTap,
              child: Icon(
                actionIcon,
                size: AppDimensions.iconMd,
                color: actionIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
