import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/helpers/article_section_helper.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_badge.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailsView({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Scaffold(
        backgroundColor: context.colors.bgPage,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(imageUrl: article.urlToImage),
                _ArticleContent(article: article),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String? imageUrl;

  const _HeroSection({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _HeroImage(imageUrl: imageUrl),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _OverlayButtons(),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imageUrl;

  const _HeroImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.heroImageHeight,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _imagePlaceholder(colors),
            )
          : _imagePlaceholder(colors),
    );
  }

  Widget _imagePlaceholder(AppColorsExtension colors) {
    return Container(
      color: colors.bgInput,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: AppDimensions.iconHero,
          color: colors.textPlaceholder,
        ),
      ),
    );
  }
}

class _OverlayButtons extends StatelessWidget {
  const _OverlayButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FrostedButton(
            icon: LucideIcons.chevronLeft,
            onTap: () => Navigator.pop(context),
          ),
          _FrostedButton(
            icon: LucideIcons.share2,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _FrostedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FrostedButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.blurSigmaFrosted,
            sigmaY: AppDimensions.blurSigmaFrosted,
          ),
          child: Container(
            width: AppDimensions.backButtonSize,
            height: AppDimensions.backButtonSize,
            decoration: BoxDecoration(
              color: colors.frostedGlass,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: AppDimensions.iconDefault,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleContent extends StatelessWidget {
  final ArticleEntity article;

  const _ArticleContent({required this.article});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final section = article.section;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(text: section.label(l10n)),
          const SizedBox(height: AppDimensions.spacing18),
          Text(
            article.title ?? '',
            style: AppTypography.sectionTitle.copyWith(
              color: colors.textPrimary,
              letterSpacing: AppDimensions.letterSpacingTight,
              height: AppDimensions.lineHeightTitle,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing18),
          _MetaRow(article: article),
          const SizedBox(height: AppDimensions.spacing18),
          _ActionRow(article: article),
          const SizedBox(height: AppDimensions.spacing18),
          Container(
            height: AppDimensions.dividerHeight,
            color: colors.borderSubtle,
          ),
          const SizedBox(height: AppDimensions.spacing18),
          Text(
            '${article.description ?? ''}\n\n${article.content ?? ''}',
            style: AppTypography.body.copyWith(
              color: colors.textSecondary,
              height: AppDimensions.lineHeightLoose,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final ArticleEntity article;

  const _MetaRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: AppDimensions.authorAvatarSize,
          height: AppDimensions.authorAvatarSize,
          decoration: const BoxDecoration(
            color: AppColors.accentGreen,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Text(
          article.author ?? '',
          style: AppTypography.subtitle.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Container(
          width: AppDimensions.metaDotSize,
          height: AppDimensions.metaDotSize,
          decoration: BoxDecoration(
            color: colors.textPlaceholder,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Icon(
          LucideIcons.calendar,
          size: AppDimensions.iconXs,
          color: colors.textPlaceholder,
        ),
        const SizedBox(width: AppDimensions.spacing6),
        Text(
          article.publishedAt ?? '',
          style: AppTypography.subtitle.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final ArticleEntity article;

  const _ActionRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        final isSaved = _isArticleSaved(state);

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ActionPill(
              icon: LucideIcons.heart,
              label: l10n.favoriteAction,
              isActive: isSaved,
              activeStyle: ActionPillStyle(
                iconColor: AppColors.white,
                textColor: AppColors.white,
                backgroundColor: AppColors.coral,
              ),
              inactiveStyle: ActionPillStyle(
                iconColor: AppColors.coral,
                textColor: AppColors.coral,
                backgroundColor: colors.bgCard,
                borderColor: colors.borderSubtle,
              ),
              onTap: () => _toggleSaved(context, isSaved),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            _ActionPill(
              icon: LucideIcons.bookmark,
              label: l10n.saveAction,
              isActive: isSaved,
              activeStyle: const ActionPillStyle(
                iconColor: AppColors.white,
                textColor: AppColors.white,
                backgroundColor: AppColors.accentGreen,
              ),
              inactiveStyle: ActionPillStyle(
                iconColor: AppColors.accentGreen,
                textColor: AppColors.accentGreen,
                backgroundColor: colors.accentGreenLight,
              ),
              onTap: () => _toggleSaved(context, isSaved),
            ),
          ],
        );
      },
    );
  }

  bool _isArticleSaved(LocalArticlesState state) {
    if (state is! LocalArticlesDone) return false;
    final saved = state.articles ?? [];
    return saved.any((a) => a.url == article.url);
  }

  void _toggleSaved(BuildContext context, bool currentlySaved) {
    final bloc = context.read<LocalArticleBloc>();
    if (currentlySaved) {
      bloc.add(RemoveArticle(article));
    } else {
      bloc.add(SaveArticle(article));
    }
  }
}

class ActionPillStyle {
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color? borderColor;

  const ActionPillStyle({
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    this.borderColor,
  });
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final ActionPillStyle activeStyle;
  final ActionPillStyle inactiveStyle;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeStyle,
    required this.inactiveStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = isActive ? activeStyle : inactiveStyle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing10,
          horizontal: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: style.borderColor != null
              ? Border.all(color: style.borderColor!)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.iconSm, color: style.iconColor),
            const SizedBox(width: AppDimensions.spacing8),
            Text(
              label,
              style: AppTypography.pillLabel.copyWith(color: style.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
