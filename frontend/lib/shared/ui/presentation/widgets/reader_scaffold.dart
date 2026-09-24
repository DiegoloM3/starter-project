import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';

/// The frame both article readers share: a full bleed cover, a circular back
/// button floating over it, and the article itself on a rounded sheet that
/// rises over the image.
///
/// It lives in `core/shared` because the two readers belong to different
/// features — one reads world news, the other reads what the community wrote
/// — and neither should have to import the other to look the same.
class ReaderScaffold extends StatelessWidget {
  final String? coverUrl;

  /// The article, laid out inside the sheet.
  final List<Widget> children;

  /// Pinned above the content, out of the way of the scroll: the one action
  /// this reader offers, if it offers one.
  final Widget? bottomAction;

  const ReaderScaffold({
    super.key,
    required this.coverUrl,
    required this.children,
    this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _Cover(url: coverUrl),
          CustomScrollView(
            slivers: [
              // Leaves the top of the cover visible before the sheet starts.
              const SliverToBoxAdapter(child: SizedBox(height: 220)),
              SliverToBoxAdapter(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height - 220,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.sheet),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.huge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
          const _BackButton(),
        ],
      ),
      bottomNavigationBar: bottomAction == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: bottomAction,
              ),
            ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
      left: AppSpacing.lg,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          // 48dp, so the one way out of this screen is never a tiny target.
          child: const SizedBox(
            height: 48,
            width: 48,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;

  const _Cover({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: url == null || url!.isEmpty
          ? _placeholder(context)
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(context),
              errorWidget: (_, __, ___) => _placeholder(context),
            ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).dividerColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: Theme.of(context).textTheme.labelSmall?.color,
        ),
      ),
    );
  }
}

/// The author's initials in a circle.
///
/// Neither articles nor accounts carry a photograph, so rather than show an
/// empty grey disc the reader gets something that identifies the writer.
class AuthorAvatar extends StatelessWidget {
  final String name;
  final double size;

  /// A tinted circle with the initials in the accent colour, instead of a
  /// solid one. Used where the avatar is the subject of the screen rather
  /// than a byline next to it.
  final bool soft;

  const AuthorAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color:
            soft ? AppColors.accent.withValues(alpha: 0.12) : AppColors.accent,
        shape: BoxShape.circle,
        border: soft
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initialsOf(name),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: soft ? AppColors.accent : Colors.white,
              fontSize: size * 0.36,
            ),
      ),
    );
  }

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);

    if (words.isEmpty) {
      return '?';
    }
    if (words.length == 1) {
      return words.first.characters.first.toUpperCase();
    }

    return (words.first.characters.first + words.last.characters.first)
        .toUpperCase();
  }
}
